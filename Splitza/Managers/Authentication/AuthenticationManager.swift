//
//  AuthenticationManager.swift
//  Splitza
//
//  Created by Jeffry Sandy Purnomo on 21/09/25.
//

import RxSwift
import RxRelay
import Foundation

class AuthenticationManager {
	
	static let shared = AuthenticationManager()
	
	let isAuthenticated = BehaviorRelay<Bool>(value: false)
	let currentUser = BehaviorRelay<User?>(value: nil)
	let userSession = BehaviorRelay<Session?>(value: nil)
	
	var userDefaults: UserDefaults = UserDefaults.standard
	
	private let disposeBag = DisposeBag()
	private var currentProvider: Authenticatable?
	
	private let userInitiatedQueue = DispatchQueue.global(qos: .userInitiated)
	
	private init() {
		// Initialize with default provider
		userInitiatedQueue.async { [weak self] in
			self?.setProvider(.manual)
			self?.checkStoredAuthState()
		}
	}
	
	func setProvider(_ providerType: AuthProvider) {
		switch providerType {
		case .manual:
			currentProvider = SupabaseAuth()
		}
	}
	
	func setSession(session: Session) {
		userSession.accept(session)
		
		if let encoded = try? JSONEncoder().encode(session) {
			userDefaults.set(encoded, forKey: "userSession")
		}
	}
	
	func signIn(
		email: String,
		password: String
	) async -> Result<User, AuthError> {
		
		guard let authProvider = currentProvider else {
			return .failure(.providerError)
		}
		
		let signInResult = await authProvider.login(email: email, password: password)
		
		if case .failure(let error) = signInResult {
			return .failure(error)
		}
		
		guard case .success(let user) = signInResult else {
			return .failure(.unknown("-"))
		}
		
		isAuthenticated.accept(true)
		currentUser.accept(user)
		storeAuthState(user: user, provider: authProvider.providerId)
		
		return .success(user)
	}
	
	func signUp(
		email: String,
		password: String
	) async -> Result<User, AuthError> {
		
		guard let authProvider = currentProvider else {
			return .failure(.providerError)
		}
		
		let signupResult = await authProvider.signUp(email: email, password: password)
		
		if case .failure(let error) = signupResult {
			return .failure(error)
		}
		
		guard case .success(let user) = signupResult else {
			return .failure(.unknown("-"))
		}
		
		isAuthenticated.accept(true)
		currentUser.accept(user)
		storeAuthState(user: user, provider: authProvider.providerId)
		
		return .success(user)
	}
	
	func logout() async {
		
		guard let authProvider = currentProvider else {
			performLocalLogout()
			return
		}
		
		_ = await authProvider.logout()
		performLocalLogout()
	}
	
	private func performLocalLogout() {
		clearUserData()
		isAuthenticated.accept(false)
		currentUser.accept(nil)
		userSession.accept(nil)
		
		NotificationCenter.default.post(
			name: .userDidLogout,
			object: nil
		)
	}
	
	private func storeAuthState(
		user: User,
		provider: AuthProvider
	) {
		userDefaults.set(user.id, forKey: "userId")
		userDefaults.set(provider.rawValue, forKey: "authProvider")
		
		if let encoded = try? JSONEncoder().encode(user) {
			userDefaults.set(encoded, forKey: "userObject")
		}
	}
	
	private func clearUserData() {
		userDefaults.removeObject(forKey: "userId")
		userDefaults.removeObject(forKey: "authProvider")
		userDefaults.removeObject(forKey: "userObject")
		userDefaults.removeObject(forKey: "userSession")
	}
	
	private func checkStoredAuthState() {
		
		guard let userId = userDefaults.string(forKey: "userId"),
			  let providerRaw = userDefaults.string(forKey: "authProvider"),
			  let userObject = userDefaults.data(forKey: "userObject"),
			  let userSession = userDefaults.data(forKey: "userSession"),
			  let provider = AuthProvider(rawValue: providerRaw) else {
			return
		}
		
		setProvider(provider)
		
		if let savedSession = try? JSONDecoder().decode(Session.self, from: userSession) {
			setSession(session: savedSession)
		}
		
		if let savedUser = try? JSONDecoder().decode(User.self, from: userObject) {
			currentUser.accept(savedUser)
		}
		
		isAuthenticated.accept(!userId.isEmpty)
	}
}

extension Notification.Name {
	static let userDidLogout = Notification.Name("userDidLogout")
}

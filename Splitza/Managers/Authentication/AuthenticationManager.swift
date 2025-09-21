//
//  AuthenticationManager.swift
//  Splitza
//
//  Created by Jeffry Sandy Purnomo on 21/09/25.
//

import RxSwift
import RxRelay

class AuthenticationManager {
	static let shared = AuthenticationManager()
	
	private let disposeBag = DisposeBag()
	private var currentProvider: AuthenticationProvider?
	
	// Available providers
	private lazy var providers: [AuthProvider: AuthenticationProvider] = [
		.supabase: SupabaseAuthProvider(client: SupabaseClient.shared),
		.facebook: FacebookAuthProvider(),
		.github: GitHubAuthProvider()
	]
	
	// Authentication state
	private let _isAuthenticated = BehaviorRelay<Bool>(value: false)
	private let _currentUser = BehaviorRelay<User?>(value: nil)
	private let _currentAuthProvider = BehaviorRelay<AuthProvider?>(value: nil)
	
	var isAuthenticated: Observable<Bool> {
		return _isAuthenticated.asObservable()
	}
	
	var currentUser: Observable<User?> {
		return _currentUser.asObservable()
	}
	
	var currentAuthProvider: Observable<AuthProvider?> {
		return _currentAuthProvider.asObservable()
	}
	
	private init() {
		checkStoredAuthState()
	}
	
	func setProvider(_ providerType: AuthProvider) {
		currentProvider = providers[providerType]
		_currentAuthProvider.accept(providerType)
	}
	
	func login(
		email: String,
		password: String,
		provider: AuthProvider = .supabase
	) -> Observable<Result<User, AuthError>> {
		setProvider(provider)
		
		guard let authProvider = currentProvider else {
			return Observable.just(.failure(.providerError("Provider not configured")))
		}
		
		return authProvider.login(email: email, password: password)
			.do(onNext: { [weak self] result in
				if case .success(let user) = result {
					self?._isAuthenticated.accept(true)
					self?._currentUser.accept(user)
					self?.storeAuthState(user: user, provider: provider)
				}
			})
	}
	
	func socialLogin(provider: AuthProvider) -> Observable<Result<User, AuthError>> {
		setProvider(provider)
		
		guard let authProvider = currentProvider else {
			return Observable.just(.failure(.providerError("Provider not configured")))
		}
		
		return authProvider.socialLogin()
			.do(onNext: { [weak self] result in
				if case .success(let user) = result {
					self?._isAuthenticated.accept(true)
					self?._currentUser.accept(user)
					self?.storeAuthState(user: user, provider: provider)
				}
			})
	}
	
	func logout() {
		guard let authProvider = currentProvider else {
			performLocalLogout()
			return
		}
		
		authProvider.logout()
			.subscribe(onNext: { [weak self] _ in
				self?.performLocalLogout()
			})
			.disposed(by: disposeBag)
	}
	
	private func performLocalLogout() {
		clearUserData()
		_isAuthenticated.accept(false)
		_currentUser.accept(nil)
		_currentAuthProvider.accept(nil)
		currentProvider = nil
		
		NotificationCenter.default.post(
			name: .userDidLogout,
			object: nil
		)
	}
	
	private func storeAuthState(
		user: User,
		provider: AuthProvider
	) {
		UserDefaults.standard.set(user.id, forKey: "userId")
		UserDefaults.standard.set(provider.rawValue, forKey: "authProvider")
		// Store other user data as needed
	}
	
	private func clearUserData() {
		UserDefaults.standard.removeObject(forKey: "userId")
		UserDefaults.standard.removeObject(forKey: "authProvider")
		// Clear other stored data
	}
	
	private func checkStoredAuthState() {
		guard
			let userId = UserDefaults.standard.string(forKey: "userId"),
			let providerRaw = UserDefaults.standard.string(forKey: "authProvider"),
			let provider = AuthProvider(rawValue: providerRaw)
		else {
			return
		}
		
		setProvider(provider)
		
		// Validate stored session with the provider
		currentProvider?.getCurrentUser()
			.subscribe(onNext: { [weak self] user in
				if let user = user {
					self?._isAuthenticated.accept(true)
					self?._currentUser.accept(user)
				}
			})
			.disposed(by: disposeBag)
	}
}

extension AuthProvider: RawRepresentable {
	public typealias RawValue = String
	
	public init?(rawValue: String) {
		switch rawValue {
		case "supabase": self = .supabase
		case "facebook": self = .facebook
		case "github": self = .github
		case "apple": self = .apple
		default: return nil
		}
	}
	
	public var rawValue: String {
		switch self {
		case .supabase: return "supabase"
		case .facebook: return "facebook"
		case .github: return "github"
		case .apple: return "apple"
		}
	}
}

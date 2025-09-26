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
	
	private let disposeBag = DisposeBag()
	private var currentProvider: Authenticatable
	
	private let _isAuthenticated = BehaviorRelay<Bool>(value: false)
	private let _currentUser = BehaviorRelay<User?>(value: nil)
	private let _session = BehaviorRelay<Session?>(value: nil)
	
	var isAuthenticated: Observable<Bool> {
		return _isAuthenticated.asObservable()
	}
	
	var currentUser: Observable<User?> {
		return _currentUser.asObservable()
	}
	
	var session: Observable<Session?> {
		return _session.asObservable()
	}
	
	private init() {
		
	}
	
	func setSession(session: Session?) {
		_session.accept(session)
	}
	
	func signIn(
		email: String,
		password: String
	) async -> Observable<Result<User, AuthError>> {
		
		return await currentProvider.login(email: email, password: password)
			.do(onNext: { [weak self] result in
				
				guard let self else {
					return
				}
				
				if case .success(let user) = result {
					self._isAuthenticated.accept(true)
					self._currentUser.accept(user)
					self.storeAuthState(user: user, provider: self.currentProvider.providerId)
				}
			})
	}
	
	func signUp(
		email: String,
		password: String
	) async -> Observable<Result<User, AuthError>> {
		
	}
	
	func logout() async {
		
		await currentProvider.logout()
			.subscribe(onNext: { [weak self] _ in
				self?.performLocalLogout()
			})
			.disposed(by: disposeBag)
	}
	
	private func performLocalLogout() {
		clearUserData()
		_isAuthenticated.accept(false)
		_currentUser.accept(nil)
	}
	
	private func storeAuthState(
		user: User,
		provider: AuthProvider
	) {
		UserDefaults.standard.set(user.id, forKey: "userId")
	}
	
	private func clearUserData() {
		UserDefaults.standard.removeObject(forKey: "userId")
		UserDefaults.standard.removeObject(forKey: "authProvider")
	}
}

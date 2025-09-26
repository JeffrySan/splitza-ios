//
//  SupabaseAuth.swift
//  Splitza
//
//  Created by Jeffry Sandy Purnomo on 21/09/25.
//

import RxSwift

final class SupabaseAuth: Authenticatable {
	
	var providerId: AuthProvider = .manual
	
	private let supabaseManager = SupabaseManager.shared
	
	private init() {
		
	}
	
	func login(email: String, password: String) async -> RxSwift.Observable<Result<User, AuthError>> {
		
		do {
			let session = try await supabaseManager.client.auth.signIn(email: email, password: password)
			let mappedUser = User(
				id: session.user.id.uuidString,
				email: session.user.email,
				createdAt: session.user.createdAt,
				lastSignInAt: session.user.lastSignInAt,
				userMetadata: session.user.userMetadata
			)
			let mappedSession = Session(
				accessToken: session.accessToken,
				refreshToken: session.refreshToken,
				expiresAt: session.expiresAt
			)
			
			AuthenticationManager.shared.setSession(session: mappedSession)
			return Observable.just(.success(mappedUser))
		} catch {
			
			print("Error login: \(error), \(error.localizedDescription)")
			return Observable.just(.failure(.networkError))
		}
	}
	
	func signUp(email: String, password: String) async -> RxSwift.Observable<Result<User, AuthError>> {
		do {
			
			let authResponse = try await supabaseManager.client.auth.signUp(email: email, password: password)
			
			guard let session = authResponse.session else {
				return Observable.just(.failure(.invalidCredentials))
			}
			
			let mappedUser = User(
				id: authResponse.user.id.uuidString,
				email: authResponse.user.email,
				createdAt: authResponse.user.createdAt,
				lastSignInAt: authResponse.user.lastSignInAt,
				userMetadata: authResponse.user.userMetadata
			)
			
			let mappedSession = Session(
				accessToken: session.accessToken,
				refreshToken: session.refreshToken,
				expiresAt: session.expiresAt
			)
			
			AuthenticationManager.shared.setSession(session: mappedSession)
			return Observable.just(.success(mappedUser))
			
		} catch {
			return Observable.just(.failure(.networkError))
		}
	}
	
	func logout() async -> RxSwift.Observable<Result<Void, AuthError>> {
		
		do {
			try await supabaseManager.client.auth.signOut()
			return Observable.just(.success(Void()))
			
		} catch {
			return Observable.just(.failure(.networkError))
		}
	}
}

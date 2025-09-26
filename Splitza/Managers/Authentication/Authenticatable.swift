//
//  AuthenticationProvider.swift
//  Splitza
//
//  Created by Jeffry Sandy Purnomo on 21/09/25.
//

import RxSwift
import Foundation

enum AuthProvider {
	case manual
}

enum AuthError: Error {
	case invalidCredentials
	case networkError
	case providerError(String)
	case cancelled
}

struct User {
	let id: String
	let email: String?
	let createdAt: Date
	let lastSignInAt: Date?
	let userMetadata: [String: Any]?
}

struct Session {
	let accessToken: String
	let refreshToken: String
	let expiresAt: TimeInterval
}

protocol Authenticatable {
	
	var providerId: AuthProvider { get }
	
	func login(
		email: String,
		password: String
	) async -> Observable<Result<User, AuthError>>
	
	func signUp(
		email: String,
		password: String
	) async -> Observable<Result<User, AuthError>>
	
	func logout() async -> RxSwift.Observable<Result<Void, AuthError>>
}

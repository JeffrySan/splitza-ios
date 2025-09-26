//
//  AuthenticationProvider.swift
//  Splitza
//
//  Created by Jeffry Sandy Purnomo on 21/09/25.
//

import RxSwift
import Foundation
import Supabase

enum AuthProvider: String {
	case manual = "manual"
}

struct User: Codable {
	let id: String
	let email: String?
	let createdAt: Date
	let lastSignInAt: Date?
	let userMetadata: [String: AnyJSON]?
}

struct Session: Codable {
	let accessToken: String
	let refreshToken: String
	let expiresAt: TimeInterval
}

protocol Authenticatable {
	
	var providerId: AuthProvider { get }
	
	func login(
		email: String,
		password: String
	) async -> Result<User, AuthError>
	
	func signUp(
		email: String,
		password: String
	) async -> Result<User, AuthError>
	
	func logout() async -> Result<Void, AuthError>
}

//
//  LoginViewModel.swift
//  Splitza
//
//  Created by Jeffry Sandy Purnomo on 14/09/25.
//

final class LoginViewModel {
	
	var email: String?
	var password: String?
	
	init(email: String? = nil, password: String? = nil) {
		self.email = email
		self.password = password
	}
}

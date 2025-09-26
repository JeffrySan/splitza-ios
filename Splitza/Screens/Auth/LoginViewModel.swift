//
//  LoginViewModel.swift
//  Splitza
//
//  Created by Jeffry Sandy Purnomo on 14/09/25.
//

import Foundation

final class LoginViewModel {
	
	var onNavigationEvent: ((PreLoginCoordinator.NavigationEvent) -> Void)?
	
	var showPopupMessage: ((_ title: String, _ subtitle: String) -> Void)?
	
	private let authenticationManager: AuthenticationManager
	
	init(authenticationManager: AuthenticationManager = .shared) {
		self.authenticationManager = authenticationManager
	}
	
	func setProvider(_ provider: AuthProvider) {
		authenticationManager.setProvider(provider)
	}
	
	func signIn(email: String, password: String) async {
		let signInResult = await authenticationManager.signIn(email: email, password: password)
		
		if case .success = signInResult {
			showPopupMessage?("Sign In Success!", "")
			print("[Lala] 7")
			DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
				print("Navigating!")
				self?.onNavigationEvent?(.showHomePageScreen)
			}
			return
		}
		
		if case .failure(let failure) = signInResult {
			showPopupMessage?("Login Failed", failure.userMessage)
		}
	}
	
	func signUp(email: String, password: String) async {
		let signUpResult = await authenticationManager.signUp(email: email, password: password)
		
		if case .success = signUpResult {
			showPopupMessage?("Sign Up Success!", "")
			DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
				print("[Lala] 6")
				self?.onNavigationEvent?(.showHomePageScreen)
			}
			return
		}
		
		if case .failure(let failure) = signUpResult {
			showPopupMessage?("Sign Up Failed", failure.localizedDescription)
		}
	}
}

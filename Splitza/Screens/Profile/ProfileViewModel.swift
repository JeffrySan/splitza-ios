//
//  ProfileViewModel.swift
//  Splitza
//
//  Created by Jeffry Sandy Purnomo on 26/09/25.
//

import RxSwift
import RxRelay
import Foundation

final class ProfileViewModel {
	
	// MARK: - Properties
	private let disposeBag = DisposeBag()
	private let authenticationManager: AuthenticationManager
	
	// MARK: - Reactive Properties
	let currentUserRelay = BehaviorRelay<User?>(value: nil)
	let isLoggingOutRelay = BehaviorRelay<Bool>(value: false)
	
	// MARK: - Closures
	var onNavigationEvent: ((NavigationEvent) -> Void)?
	var showMessage: ((_ title: String, _ message: String) -> Void)?
	
	// MARK: - Navigation Events
	enum NavigationEvent {
		case logout
	}
	
	// MARK: - Initialization
	init(authenticationManager: AuthenticationManager = .shared) {
		self.authenticationManager = authenticationManager
		setupBindings()
	}
	
	// MARK: - Setup
	private func setupBindings() {
		// Observe current user changes
		authenticationManager.currentUser
			.bind(to: currentUserRelay)
			.disposed(by: disposeBag)
	}
	
	// MARK: - Public Methods
	func logout() {
		isLoggingOutRelay.accept(true)
		
		Task {
			await authenticationManager.logout()
			
			DispatchQueue.main.async { [weak self] in
				self?.isLoggingOutRelay.accept(false)
				self?.showMessage?("Logout Successful", "You have been logged out successfully.")
				
				// Slight delay for user feedback
				DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
					self?.onNavigationEvent?(.logout)
				}
			}
		}
	}
	
	// MARK: - Computed Properties
	var userName: String {
		return currentUserRelay.value?.email ?? "Unknown User"
	}
	
	var userEmail: String {
		return currentUserRelay.value?.email ?? "No email available"
	}
	
	var userId: String {
		return currentUserRelay.value?.id ?? "No ID available"
	}
	
	var createdAtFormatted: String {
		guard let createdAt = currentUserRelay.value?.createdAt else {
			return "Unknown"
		}
		
		let formatter = DateFormatter()
		formatter.dateStyle = .long
		formatter.timeStyle = .none
		return formatter.string(from: createdAt)
	}
	
	var lastSignInFormatted: String {
		guard let lastSignIn = currentUserRelay.value?.lastSignInAt else {
			return "Never"
		}
		
		let formatter = DateFormatter()
		formatter.dateStyle = .medium
		formatter.timeStyle = .short
		return formatter.string(from: lastSignIn)
	}
}
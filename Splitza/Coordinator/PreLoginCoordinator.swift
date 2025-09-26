//
//  PreLoginCoordinator.swift
//  Splitza
//
//  Created by Jeffry Sandy Purnomo on 26/09/25.
//

import UIKit

final class PreLoginCoordinator: Coordinator {
	
	var onNavigationEvent: ((NavigationEvent) -> Void)?
	
	enum NavigationEvent {
		case showHomePageScreen
	}
	
	private var loginViewController: LoginViewController?
	
	var rootViewController: UIViewController = UINavigationController()
	
	init() { }
	
	func start() {
		showAuthenticationPage()
	}
	
	private func showAuthenticationPage() {
		
		let viewModel = LoginViewModel()
		viewModel.onNavigationEvent = { [weak self] event in
			self?.onNavigationEvent?(event)
		}
		
		let localLoginViewController = LoginViewController(viewModel: viewModel)
		Router.shared.push(localLoginViewController, on: self)
	}
}

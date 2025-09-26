//
//  PreLoginCoordinator.swift
//  Splitza
//
//  Created by Jeffry Sandy Purnomo on 26/09/25.
//

import UIKit

final class PreLoginCoordinator: Coordinator {
	
	private(set) var loginViewController: LoginViewController?
	
	var rootViewController: UIViewController {
		return UINavigationController()
	}
	
	init() { }
	
	func start() {
		showAuthenticationPage()
	}
	
	private func showAuthenticationPage() {
		
		let localLoginViewController = LoginViewController()
		Router.shared.push(localLoginViewController, on: self)
	}
}

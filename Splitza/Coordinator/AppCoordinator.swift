//
//  AppCoordinator.swift
//  Splitza
//
//  Created by Jeffry Sandy Purnomo on 21/09/25.
//

import UIKit
import Foundation

final class AppCoordinator: Coordinator {
	
	var rootViewController: UIViewController
	
	private var tabbarCoordinator: TabbarCoordinator?
	private var preLoginCoordinator: PreLoginCoordinator?
	
	init(rootViewController: UIViewController = UINavigationController()) {
		self.rootViewController = rootViewController
	}
	
	func start() {
		
		if AuthenticationManager.shared.isAuthenticated.value {
			showHomePageScreen()
			return
		}
		
		showPreloginPage()
	}
	
	private func showHomePageScreen() {
		tabbarCoordinator = TabbarCoordinator()
		tabbarCoordinator?.start()
		
		tabbarCoordinator?.onNavigationEvent = { [weak self] event in
			switch event {
			case .showPreLoginPage:
				self?.showPreloginPage()
			}
		}
		
		guard let unwrappedTabbarCoordinator = tabbarCoordinator else {
			return
		}
		
		Router.shared.setRoot(unwrappedTabbarCoordinator.rootViewController)
	}
	
	private func showPreloginPage() {
		preLoginCoordinator = PreLoginCoordinator()
		preLoginCoordinator?.start()
		
		preLoginCoordinator?.onNavigationEvent = { [weak self] event in
			switch event {
			case .showHomePageScreen:
				self?.showHomePageScreen()
			}
		}
		
		guard let unwrappedPreloginCoordinator = preLoginCoordinator else {
			return
		}
		
		Router.shared.setRoot(unwrappedPreloginCoordinator.rootViewController)
	}
}


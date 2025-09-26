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
	
	init(rootViewController: UIViewController = UINavigationController()) {
		self.rootViewController = rootViewController
	}
	
	func start() {
		
	}
	
	private func showHomePageScreen() {
		tabbarCoordinator = TabbarCoordinator()
		
		guard let unwrappedTabbarCoordinator = tabbarCoordinator else {
			return
		}
		
		Router.shared.setRoot(unwrappedTabbarCoordinator.rootViewController)
	}
	
	private func showOnboardingPage() {
		tabbarCoordinator = TabbarCoordinator()
		
		guard let unwrappedTabbarCoordinator = tabbarCoordinator else {
			return
		}
		
		Router.shared.setRoot(unwrappedTabbarCoordinator.rootViewController)
	}
}


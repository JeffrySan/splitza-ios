//
//  AppDelegate.swift
//  Splitza
//
//  Created by Jeffry Sandy Purnomo on 09/07/25.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
	
	var window: UIWindow?
	var navigationController: UINavigationController = UINavigationController()
	
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		
		window = Router.shared.window
		
		let tabbarCoordinator = TabbarCoordinator()
		tabbarCoordinator.start()
		
		navigationController.viewControllers = [tabbarCoordinator.rootViewController]
		
		window?.rootViewController = navigationController
		window?.makeKeyAndVisible()
		
		return true
	}
}


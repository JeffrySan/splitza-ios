//
//  SceneDelegate.swift
//  Splitza
//
//  Created by Jeffry Sandy Purnomo on 11/09/25.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
	
	var window: UIWindow?
	var navigationController: UINavigationController = UINavigationController()
	
	func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
		
		guard let windowScene = (scene as? UIWindowScene) else {
			return
		}
		
		window = UIWindow(windowScene: windowScene)
		
		guard let unwrappedWindow = window else {
			return
		}
		
		// Set up the Router with the window
		Router.shared.window = unwrappedWindow
		
		let tabbarCoordinator = TabbarCoordinator()
		tabbarCoordinator.start()
		
		navigationController.viewControllers = [tabbarCoordinator.rootViewController]
		
		window?.rootViewController = navigationController
		window?.makeKeyAndVisible()
	}
	
	func sceneDidDisconnect(_ scene: UIScene) {
		// Called as the scene is being released by the system.
		// This occurs shortly after the scene enters the background, or when its session is discarded.
	}
	
	func sceneDidBecomeActive(_ scene: UIScene) {
		// Called when the scene has moved from an inactive state to an active state.
	}
	
	func sceneWillResignActive(_ scene: UIScene) {
		// Called when the scene will move from an active state to an inactive state.
	}
	
	func sceneWillEnterForeground(_ scene: UIScene) {
		// Called as the scene transitions from the background to the foreground.
	}
	
	func sceneDidEnterBackground(_ scene: UIScene) {
		// Called as the scene transitions from the foreground to the background.
	}
}

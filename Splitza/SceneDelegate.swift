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
	var appcoordinator: AppCoordinator?
	
	func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
		
		guard let windowScene = (scene as? UIWindowScene) else { return }
		
		// Initialize the window with the scene
		let window = CustomWindow(windowScene: windowScene)
		window.windowLevel = .alert + 1
		
		self.window = window
		Router.shared.window = window
		
		let appCoordinator = AppCoordinator()
		appcoordinator = appCoordinator
		
		appCoordinator.start()
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

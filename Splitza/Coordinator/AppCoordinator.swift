//
//  AppCoordinator.swift
//  Splitza
//
//  Created by Jeffry Sandy Purnomo on 21/09/25.
//

import UIKit
import Foundation

final class AppCoordinator: Coordinator {
	
	var rootViewController: UIViewController {
		return UINavigationController()
	}
	
	init(rootViewController: UIViewController = UINavigationController()) {
		self.rootViewController = rootViewController
	}
	
	func start() {
		rootViewController.s
	}
}


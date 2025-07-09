//
//  TabbarCoordinator.swift
//  Splitza
//
//  Created by Jeffry Sandy Purnomo on 09/07/25.
//

import UIKit

final class TabbarCoordinator: Coordinator {
	
	private(set) var historyViewController: UIViewController = UIViewController()
	private(set) var scanViewController: UIViewController = UIViewController()
	private(set) var profileViewController: UIViewController = UIViewController()
	
	var rootViewController: UIViewController {
		return tabBarController
	}
	
	let tabBarController: TabbarViewController
	
	init() {
		tabBarController = TabbarViewController()
	}
	
	func start() {
		
		setupHistoryViewController()
		setupScanViewController()
		setupProfileViewController()
		
		tabBarController.viewControllers = [
			historyViewController,
			scanViewController,
			profileViewController
		]
	}
	
	private func setupProfileViewController() {
		
		let localProfileViewController = ProfileViewController()
		profileViewController = UINavigationController(rootViewController: localProfileViewController)
		
		profileViewController.tabBarItem = UITabBarItem(
			title: "Home",
			image: UIImage(systemName: "house"),
			selectedImage: UIImage(systemName: "house.fill")
		)
	}
	
	private func setupHistoryViewController() {
		let localHistoryViewController = HistoryViewController()
		historyViewController = UINavigationController(rootViewController: localHistoryViewController)
		
		historyViewController.tabBarItem = UITabBarItem(
			title: "History",
			image: UIImage(systemName: "clock.arrow.circlepath"),
			selectedImage: UIImage(systemName: "clock.arrow.circlepath")
		)
	}
	
	private func setupScanViewController() {
		let localScanViewController = ScanViewController()
		scanViewController = UINavigationController(rootViewController: localScanViewController)
		
		scanViewController.tabBarItem = UITabBarItem(
			title: "Scan",
			image: UIImage(systemName: "qrcode.viewfinder"),
			selectedImage: UIImage(systemName: "qrcode.viewfinder")
		)
	}
}

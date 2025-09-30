//
//  TabbarCoordinator.swift
//  Splitza
//
//  Created by Jeffry Sandy Purnomo on 09/07/25.
//

import UIKit

final class TabbarCoordinator: Coordinator {
	
	var onNavigationEvent: ((NavigationEvent) -> Void)?
	
	enum NavigationEvent {
		case showPreLoginPage
	}
	
	private(set) var historyViewController: UIViewController!
	private(set) var scanViewController: UIViewController!
	private(set) var profileViewController: UIViewController!
	
	var rootViewController: UIViewController {
		return tabBarController
	}
	
	let tabBarController: TabbarViewController
	
	init() {
		tabBarController = TabbarViewController()
	}
	
	@MainActor func start() {
		
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
		let profileViewModel = ProfileViewModel()
		profileViewModel.onNavigationEvent = { [weak self] event in
			switch event {
			case .logout:
				self?.onNavigationEvent?(.showPreLoginPage)
			}
		}
		
		let localProfileViewController = ProfileViewController(viewModel: profileViewModel)
		profileViewController = UINavigationController(rootViewController: localProfileViewController)
		
		Task {
			// Create UIImage on a background thread
			let profileImage = await createImage(systemName: "person")
			let profileSelectedImage = await createImage(systemName: "person.fill")
			
			// Set the tab bar item on the main thread
			await MainActor.run {
				profileViewController.tabBarItem = UITabBarItem(
					title: "Profile",
					image: profileImage,
					selectedImage: profileSelectedImage
				)
			}
		}
	}
	
	private func createImage(systemName: String) async -> UIImage? {
		await withCheckedContinuation { continuation in
			DispatchQueue.global(qos: .userInitiated).async {
				let image = UIImage(systemName: systemName)
				continuation.resume(returning: image)
			}
		}
	}
	
	@MainActor private func setupHistoryViewController() {
		let localHistoryViewModel = HistoryViewModel()
		let localHistoryViewController = HistoryViewController(viewModel: localHistoryViewModel)
		historyViewController = UINavigationController(rootViewController: localHistoryViewController)

		Task {
			// Create UIImage on a background thread
			let historyImage = await createImage(systemName: "clock.arrow.circlepath")
			let historySelectedImage = await createImage(systemName: "clock.arrow.circlepath")

			// Set the tab bar item on the main thread
			await MainActor.run {
				historyViewController.tabBarItem = UITabBarItem(
					title: "History",
					image: historyImage,
					selectedImage: historySelectedImage
				)
			}
		}
	}

	private func setupScanViewController() {
		let localScanViewController = ScanViewController()
		scanViewController = UINavigationController(rootViewController: localScanViewController)

		Task {
			// Create UIImage on a background thread
			let scanImage = await createImage(systemName: "qrcode.viewfinder")
			let scanSelectedImage = await createImage(systemName: "qrcode.viewfinder")

			// Set the tab bar item on the main thread
			await MainActor.run {
				scanViewController.tabBarItem = UITabBarItem(
					title: "Scan",
					image: scanImage,
					selectedImage: scanSelectedImage
				)
			}
		}
	}
}

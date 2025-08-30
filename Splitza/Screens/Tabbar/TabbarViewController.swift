//
//  TabbarViewController.swift
//  Splitza
//
//  Created by Jeffry Sandy Purnomo on 09/07/25.
//

import UIKit

final class TabbarViewController: UITabBarController {
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupTabBarAppearance()
	}
	
	private func setupTabBarAppearance() {
		
		let appearance = UITabBarAppearance()
		
		appearance.backgroundColor = .systemBackground
		
		appearance.stackedLayoutAppearance.normal.iconColor = .secondaryLabel
		appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
			.foregroundColor: UIColor.secondaryLabel
		]
		
		appearance.stackedLayoutAppearance.selected.iconColor = .systemBlue
		appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
			.foregroundColor: UIColor.systemBlue
		]
		
		tabBar.standardAppearance = appearance
		
		tabBar.tintColor = .systemBlue
		tabBar.unselectedItemTintColor = .secondaryLabel
	}
}

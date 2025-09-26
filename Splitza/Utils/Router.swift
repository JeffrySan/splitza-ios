//
//  Router.swift
//  Splitza
//
//  Created by Jeffry Sandy Purnomo on 21/09/25.
//

import UIKit
import Foundation

final class CustomWindow: UIWindow {
	
	override func sendEvent(_ event: UIEvent) {
		super.sendEvent(event)
	}
}

internal final class Router {
	
	static let shared = Router()
	
	var window: UIWindow?
	
	var keyWindow: UIWindow? {
		return UIApplication.shared.connectedScenes
			.compactMap { $0 as? UIWindowScene }
			.flatMap { $0.windows }
			.first { $0.isKeyWindow }
	}
	
	init() { }
	
	func setRoot(_ viewController: UIViewController, completion: (() -> Void)? = nil) {
		
		guard let window = window else {
			print("❌ Error: Window is not initialized")
			return
		}
		
		guard keyWindow != nil, window.rootViewController != nil else {
			window.rootViewController = viewController
			window.makeKeyAndVisible()
			completion?()
			return
		}
		
		guard let snapshot = window.snapshotView(afterScreenUpdates: true) else {
			return
		}
		
		viewController.view.addSubview(snapshot)
		window.rootViewController = viewController
		
		UIView.animate(
			withDuration: 0.15,
			animations: {
				snapshot.layer.opacity = 0
				snapshot.layer.transform = CATransform3DMakeScale(1.5, 1.5, 1.5)
			},
			completion: { _ in
				snapshot.removeFromSuperview()
			}
		)
		completion?()
	}
	
	func push(_ viewController: UIViewController, on coordinator: Coordinator, animated: Bool = true) {
		
		guard let navigationController = coordinator.rootViewController as? UINavigationController else {
			return
		}
		
		navigationController.pushViewController(viewController, animated: animated)
	}
}

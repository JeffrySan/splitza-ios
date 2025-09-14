//
//  Router.swift
//  Splitza
//
//  Created by Jeffry Sandy Purnomo on 09/07/25.
//

import UIKit
import RxSwift

final class Router {
	static let shared = Router()
	
	var window: UIWindow = UIWindow(frame: UIScreen.main.bounds)
	
	private let navigationController: UINavigationController = UINavigationController()
	
	private let disposeBag = DisposeBag()
	
	func setRoot(_ viewController: UIViewController, completion: (() -> Void)? = nil) {
		
		// Check whether keyWindow is not empty && window has root view contoller.
		// If true, update the root view contoller with animation.
		// If not, set as new root view controller
		
		guard window.rootViewController != nil else {
			window.rootViewController = viewController
			window.makeKeyAndVisible()
			completion?()
			return
		}
		
		guard let snapshot = window.snapshotView(afterScreenUpdates: true) else {
			completion?()
			return
		}
		
		viewController.view.addSubview(snapshot)
		window.rootViewController = viewController
		
		UIView.animate(
			withDuration: 0.15,
			animations: {
				snapshot.layer.opacity = 0
			},
			completion: { _ in
				snapshot.removeFromSuperview()
				completion?()
			}
		)
	}
	
	func push(
		_ screen: Screen,
		on viewController: UIViewController,
		completion: (() -> Void)? = nil
	) {
		guard let navigationController = viewController as? UINavigationController else {
			return
		}
		
		if navigationController.viewControllers.count == 0 {
			navigationController.setViewControllers([ screen.make() ], animated: true)
			return
		}
		
		navigationController.pushViewController(screen.make(), animated: true)
	}
	
	func push(
		_ screen: Screen,
		on coordinator: Coordinator,
		completion: (() -> Void)? = nil
	) {
		
		guard let nav = coordinator.rootViewController as? UINavigationController else {
			return
		}
		
		if nav.viewControllers.count == 0 {
			nav.setViewControllers([ screen.make() ], animated: true)
			return
		}
		
		nav.pushViewController(
			screen.make(),
			animated: true
		)
	}
	
	func push(
		_ screens: [Screen],
		on coordinator: Coordinator
	) {
		
		guard let nav = coordinator.rootViewController as? UINavigationController else {
			return
		}
		
		var viewControllers = nav.viewControllers
		
		if viewControllers.count == 0 {
			nav.setViewControllers(screens.map({ $0.make() }), animated: true)
			return
		}
		
		viewControllers.append(contentsOf: screens.map({ $0.make() }))
		
		nav.setViewControllers(viewControllers, animated: true)
	}
	
	func present(_ screen: Screen, on viewController: UIViewController, isAnimated: Bool = true, completion: (() -> Void)? = nil) {
		
		viewController.present(
			screen.make(),
			animated: isAnimated,
			completion: {
				completion?()
			}
		)
	}
}

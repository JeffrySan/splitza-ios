//
//  UIView+Extensions.swift
//  Splitza
//
//  Created by Jeffry Sandy Purnomo on 31/08/25.
//

import UIKit

extension UIView {
	func parentViewController() -> UIViewController? {
		var responder: UIResponder? = self
		while let r = responder {
			if let vc = r as? UIViewController {
				return vc
			}
			responder = r.next
		}
		return nil
	}
}

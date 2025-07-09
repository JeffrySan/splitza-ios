//
//  Screen.swift
//  Splitza
//
//  Created by Jeffry Sandy Purnomo on 09/07/25.
//

import UIKit

protocol Screen: AnyObject {
	
	var identifier: String { get }
	
	func make() -> UIViewController
}

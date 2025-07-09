//
//  Coordinator.swift
//  Splitza
//
//  Created by Jeffry Sandy Purnomo on 09/07/25.
//

import Foundation
import UIKit

protocol Coordinator {
	
	var rootViewController: UIViewController { get }
	
	func start()
}

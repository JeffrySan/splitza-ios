//
//  BillParticipant.swift
//  Splitza
//
//  Created by Jeffry Sandy Purnomo on 31/08/25.
//

import Foundation

struct BillParticipant {
	let id: String
	var name: String
	var email: String
	
	init(id: String = UUID().uuidString, name: String, email: String = "") {
		self.id = id
		self.name = name
		self.email = email
	}
	
	// Get abbreviated name for UI display
	var abbreviatedName: String {
		let components = name.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: " ")
		
		if components.count == 1 {
			// Single name - return first 2 characters
			let firstName = components[0]
			return String(firstName.prefix(2)).uppercased()
		} else if components.count >= 2 {
			// Multiple names - return initials
			let firstInitial = String(components[0].prefix(1))
			let lastInitial = String(components[1].prefix(1))
			return (firstInitial + lastInitial).uppercased()
		}
		
		return "?"
	}
	
	// Calculate total amount for this participant across all menu items
	func totalAmount(from menuItems: [MenuItem]) -> Double {
		return menuItems.reduce(0.0) { total, item in
			return total + item.amountForParticipant(id)
		}
	}
}

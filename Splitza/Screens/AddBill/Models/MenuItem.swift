//
//  MenuItem.swift
//  Splitza
//
//  Created by Jeffry Sandy Purnomo on 31/08/25.
//

import Foundation

struct MenuItem {
	// MARK: - Properties
	
	let id: String
	var title: String
	var price: Double
	var participantAssignments: [String: Int] // participantId: count
	
	var totalShares: Int {
		return participantAssignments.values.reduce(0, +)
	}
	
	var pricePerShare: Double {
		guard totalShares > 0 else { return 0.0 }
		return price / Double(totalShares)
	}
	
	var assignedParticipantIds: [String] {
		return participantAssignments.keys.filter { participantAssignments[$0] ?? 0 > 0 }
	}
	
	// MARK: - Initialization
	init(
		id: String = UUID().uuidString,
		title: String = "",
		price: Double = 0.0,
		participantAssignments: [String: Int] = [:]
	) {
		self.id = id
		self.title = title
		self.price = price
		self.participantAssignments = participantAssignments
	}
	
	// Get amount for specific participant
	func amountForParticipant(_ participantId: String) -> Double {
		
		guard let shares = participantAssignments[participantId] else {
			return 0.0
		}
		return pricePerShare * Double(shares)
	}
}

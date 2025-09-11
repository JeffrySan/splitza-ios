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
	
	// MARK: - Initialization
	
	init(id: String = UUID().uuidString, 
		 title: String = "", 
		 price: Double = 0.0, 
		 participantAssignments: [String: Int] = [:]) {
		self.id = id
		self.title = title
		self.price = price
		self.participantAssignments = participantAssignments
	}
	
	// Helper method to check if participant is assigned
	func isParticipantAssigned(_ participantId: String) -> Bool {
		return (participantAssignments[participantId] ?? 0) > 0
	}
	
	// Calculate total shares for this menu item
	var totalShares: Int {
		return participantAssignments.values.reduce(0, +)
	}
	
	// Calculate amount per share
	var pricePerShare: Double {
		guard totalShares > 0 else { return 0.0 }
		return price / Double(totalShares)
	}
	
	// Get amount for specific participant
	func amountForParticipant(_ participantId: String) -> Double {
		guard let shares = participantAssignments[participantId] else { return 0.0 }
		return pricePerShare * Double(shares)
	}
	
	// MARK: - Participant Management
	
	mutating func toggleParticipant(_ participantId: String) {
		guard let currentAssignment = participantAssignments[participantId] else {
			participantAssignments[participantId] = 1
			return
		}
		
		if currentAssignment > 0 {
			participantAssignments[participantId] = 0
		} else {
			participantAssignments[participantId] = 1
		}
	}
	
	// MARK: - Computed Properties
	
	var assignedParticipantIds: [String] {
		return participantAssignments.keys.filter { participantAssignments[$0] ?? 0 > 0 }
	}
}

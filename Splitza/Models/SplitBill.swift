//
//  SplitBill.swift
//  Splitza
//
//  Created by Jeffry Sandy Purnomo on 09/07/25.
//

import Foundation

struct SplitBill: Codable, Equatable {
	let id: String
	let title: String
	let totalAmount: Double
	let date: Date
	let location: String?
	let participants: [Participant]
	let currency: String
	let description: String?
	let isSettled: Bool
	
	init(id: String = UUID().uuidString,
		 title: String,
		 totalAmount: Double,
		 date: Date = Date(),
		 location: String? = nil,
		 participants: [Participant],
		 currency: String = "USD",
		 description: String? = nil,
		 isSettled: Bool = false) {
		self.id = id
		self.title = title
		self.totalAmount = totalAmount
		self.date = date
		self.location = location
		self.participants = participants
		self.currency = currency
		self.description = description
		self.isSettled = isSettled
	}
}

struct Participant: Codable, Equatable {
	let id: String
	let name: String
	let email: String?
	let amountOwed: Double
	let hasPaid: Bool
	
	init(id: String = UUID().uuidString,
		 name: String,
		 email: String? = nil,
		 amountOwed: Double,
		 hasPaid: Bool = false) {
		self.id = id
		self.name = name
		self.email = email
		self.amountOwed = amountOwed
		self.hasPaid = hasPaid
	}
}

// MARK: - Extensions for formatting
extension SplitBill {
	var formattedAmount: String {
		let formatter = NumberFormatter()
		formatter.numberStyle = .currency
		formatter.currencyCode = currency
		return formatter.string(from: NSNumber(value: totalAmount)) ?? "\(currency) \(totalAmount)"
	}
	
	var formattedDate: String {
		let formatter = DateFormatter()
		formatter.dateStyle = .medium
		formatter.timeStyle = .none
		return formatter.string(from: date)
	}
	
	var participantCount: Int {
		return participants.count
	}
	
	var settledParticipants: Int {
		return participants.filter { $0.hasPaid }.count
	}
}

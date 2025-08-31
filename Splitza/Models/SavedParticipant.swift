//
//  SavedParticipant.swift
//  Splitza
//
//  Created by Jeffry Sandy Purnomo on 30/08/25.
//

import Foundation

struct SavedParticipant: Codable, Equatable {
	let id: String
	let name: String
	let email: String?
	let createdDate: Date
	let lastUsedDate: Date
	
	init(id: String = UUID().uuidString,
		 name: String,
		 email: String? = nil,
		 createdDate: Date = Date(),
		 lastUsedDate: Date = Date()) {
		self.id = id
		self.name = name
		self.email = email
		self.createdDate = createdDate
		self.lastUsedDate = lastUsedDate
	}
}

// MARK: - Extensions
extension SavedParticipant {
	func updatedLastUsedDate() -> SavedParticipant {
		return SavedParticipant(
			id: id,
			name: name,
			email: email,
			createdDate: createdDate,
			lastUsedDate: Date()
		)
	}
}

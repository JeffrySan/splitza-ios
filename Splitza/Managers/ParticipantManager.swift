//
//  ParticipantManager.swift
//  Splitza
//
//  Created by Jeffry Sandy Purnomo on 30/08/25.
//

import Foundation

protocol ParticipantManagerProtocol {
	func saveParticipant(_ participant: SavedParticipant)
	func getAllParticipants() -> [SavedParticipant]
	func searchParticipants(with query: String) -> [SavedParticipant]
	func deleteParticipant(withId id: String)
	func updateLastUsedDate(for participantId: String)
}

final class ParticipantManager: ParticipantManagerProtocol {
	
	private let userDefaults = UserDefaults.standard
	private let participantsKey = "SavedParticipants"
	
	func saveParticipant(_ participant: SavedParticipant) {
		var participants = getAllParticipants()
		
		// Check if participant already exists (by name and email)
		if let existingIndex = participants.firstIndex(where: { 
			$0.name.lowercased() == participant.name.lowercased() && 
			$0.email?.lowercased() == participant.email?.lowercased() 
		}) {
			// Update existing participant
			participants[existingIndex] = participant.updatedLastUsedDate()
		} else {
			// Add new participant
			participants.append(participant)
		}
		
		saveParticipants(participants)
	}
	
	func getAllParticipants() -> [SavedParticipant] {
		guard let data = userDefaults.data(forKey: participantsKey) else {
			return []
		}
		
		do {
			let participants = try JSONDecoder().decode([SavedParticipant].self, from: data)
			// Sort by last used date (most recent first)
			return participants.sorted { $0.lastUsedDate > $1.lastUsedDate }
		} catch {
			print("Failed to decode saved participants: \(error)")
			return []
		}
	}
	
	func searchParticipants(with query: String) -> [SavedParticipant] {
		let allParticipants = getAllParticipants()
		
		guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
			return allParticipants
		}
		
		let lowercasedQuery = query.lowercased()
		return allParticipants.filter { participant in
			participant.name.lowercased().contains(lowercasedQuery) ||
			participant.email?.lowercased().contains(lowercasedQuery) == true
		}
	}
	
	func deleteParticipant(withId id: String) {
		var participants = getAllParticipants()
		participants.removeAll { $0.id == id }
		saveParticipants(participants)
	}
	
	func updateLastUsedDate(for participantId: String) {
		var participants = getAllParticipants()
		
		if let index = participants.firstIndex(where: { $0.id == participantId }) {
			participants[index] = participants[index].updatedLastUsedDate()
			saveParticipants(participants)
		}
	}
	
	private func saveParticipants(_ participants: [SavedParticipant]) {
		do {
			let data = try JSONEncoder().encode(participants)
			userDefaults.set(data, forKey: participantsKey)
		} catch {
			print("Failed to encode participants: \(error)")
		}
	}
}

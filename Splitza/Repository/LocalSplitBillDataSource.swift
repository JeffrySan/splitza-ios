//
//  LocalSplitBillDataSource.swift
//  Splitza
//
//  Created by Jeffry Sandy Purnomo on 10/08/25.
//

import Foundation

final class LocalSplitBillDataSource: SplitBillDataSource {
	
	private let manager: SplitBillManager
	
	init(manager: SplitBillManager = SplitBillManager.shared) {
		self.manager = manager
	}
	
	func getAllSplitBills() async throws -> [SplitBill] {
		let bills = manager.getAllSplitBills()
		return bills
	}
	
	func getSplitBill(email: String, name: String) async throws -> [SplitBill] {
		let participantBills = manager.getAllSplitBills(email: email, name: name)
		
		if participantBills.isEmpty {
			throw SplitBillError.splitBillNotFound
		}
		
		return participantBills
	}
	
	func searchSplitBills(query: String) async throws -> [SplitBill] {
		let bills = manager.searchSplitBills(query: query)
		return bills
	}
	
	func createSplitBill(_ splitBill: SplitBill) async throws -> SplitBill {
		manager.addSplitBill(splitBill)
		return splitBill
	}
	
	func updateSplitBill(_ splitBill: SplitBill) async throws -> SplitBill {
		manager.updateSplitBill(splitBill)
		return splitBill
	}
	
	func deleteSplitBill(id: String) async throws {
		manager.deleteSplitBill(withId: id)
	}
	
	func settleSplitBill(id: String) async throws -> SplitBill {
		let bills = manager.getAllSplitBills()
		
		guard let bill = bills.first(where: { $0.id == id }) else {
			throw SplitBillError.splitBillNotFound
		}
		
		// Create a new SplitBill with isSettled = true
		let settledBill = SplitBill(
			id: bill.id,
			title: bill.title,
			totalAmount: bill.totalAmount,
			date: bill.date,
			location: bill.location,
			participants: bill.participants.map { participant in
				Participant(
					id: participant.id,
					name: participant.name,
					email: participant.email,
					amountOwed: participant.amountOwed,
					hasPaid: true // Mark all participants as paid
				)
			},
			currency: bill.currency,
			description: bill.description,
			isSettled: true
		)
		
		manager.updateSplitBill(settledBill)
		return settledBill
	}
	
	// MARK: - User-specific queries
	
	func getSplitBillsForUser(email: String) async throws -> [SplitBill] {
		let allBills = manager.getAllSplitBills()
		let userBills = allBills.filter { bill in
			bill.participants.contains { $0.email?.lowercased() == email.lowercased() }
		}
		return userBills
	}
	
	func getSplitBillsForUser(name: String) async throws -> [SplitBill] {
		let allBills = manager.getAllSplitBills()
		let userBills = allBills.filter { bill in
			bill.participants.contains { $0.name.lowercased().contains(name.lowercased()) }
		}
		return userBills
	}
}

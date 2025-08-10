//
//  SplitBillManager.swift
//  Splitza
//
//  Created by Jeffry Sandy Purnomo on 09/07/25.
//

import Foundation

final class SplitBillManager {
	static let shared = SplitBillManager()
	
	private init() {}
	
	// For demo purposes, we'll use in-memory storage
	// In a real app, you'd use Core Data, SQLite, or a cloud service
	private var splitBills: [SplitBill] = []
	
	// MARK: - Public Methods
	
	func getAllSplitBills() -> [SplitBill] {
		return splitBills.sorted { $0.date > $1.date }
	}
	
	func addSplitBill(_ splitBill: SplitBill) {
		splitBills.append(splitBill)
	}
	
	func updateSplitBill(_ splitBill: SplitBill) {
		if let index = splitBills.firstIndex(where: { $0.id == splitBill.id }) {
			splitBills[index] = splitBill
		}
	}
	
	func deleteSplitBill(withId id: String) {
		splitBills.removeAll { $0.id == id }
	}
	
	func searchSplitBills(query: String) -> [SplitBill] {
		guard !query.isEmpty else { return getAllSplitBills() }
		
		let lowercasedQuery = query.lowercased()
		return splitBills.filter { splitBill in
			splitBill.title.lowercased().contains(lowercasedQuery) ||
			splitBill.location?.lowercased().contains(lowercasedQuery) == true ||
			splitBill.description?.lowercased().contains(lowercasedQuery) == true ||
			splitBill.participants.contains { $0.name.lowercased().contains(lowercasedQuery) }
		}.sorted { $0.date > $1.date }
	}
	
	// MARK: - Sample Data (for demo)
	
	func loadSampleData() {
		let sampleBills = createSampleSplitBills()
		splitBills.append(contentsOf: sampleBills)
	}
	
	private func createSampleSplitBills() -> [SplitBill] {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd"
		
		return [
			SplitBill(
				title: "Dinner at Joe's Pizza",
				totalAmount: 85.50,
				date: dateFormatter.date(from: "2025-08-08") ?? Date(),
				location: "Joe's Pizza Downtown",
				participants: [
					Participant(name: "John Doe", amountOwed: 28.50, hasPaid: true),
					Participant(name: "Jane Smith", amountOwed: 28.50, hasPaid: false),
					Participant(name: "Mike Johnson", amountOwed: 28.50, hasPaid: true)
				],
				description: "Team dinner after project completion",
				isSettled: false
			),
			SplitBill(
				title: "Weekend Trip to Mountains",
				totalAmount: 450.00,
				date: dateFormatter.date(from: "2025-08-05") ?? Date(),
				location: "Blue Ridge Mountains",
				participants: [
					Participant(name: "Alice Brown", amountOwed: 150.00, hasPaid: true),
					Participant(name: "Bob Wilson", amountOwed: 150.00, hasPaid: true),
					Participant(name: "Carol Davis", amountOwed: 150.00, hasPaid: true)
				],
				description: "Cabin rental and shared expenses",
				isSettled: true
			),
			SplitBill(
				title: "Coffee Shop Meeting",
				totalAmount: 32.75,
				date: dateFormatter.date(from: "2025-08-07") ?? Date(),
				location: "Starbucks Central",
				participants: [
					Participant(name: "David Lee", amountOwed: 16.25, hasPaid: false),
					Participant(name: "Emma Clark", amountOwed: 16.50, hasPaid: true)
				],
				description: "Business meeting over coffee",
				isSettled: false
			),
			SplitBill(
				title: "Movie Night Snacks",
				totalAmount: 67.20,
				date: dateFormatter.date(from: "2025-08-06") ?? Date(),
				location: "AMC Theater",
				participants: [
					Participant(name: "Frank Miller", amountOwed: 13.44, hasPaid: true),
					Participant(name: "Grace Turner", amountOwed: 13.44, hasPaid: false),
					Participant(name: "Henry White", amountOwed: 13.44, hasPaid: true),
					Participant(name: "Ivy Green", amountOwed: 13.44, hasPaid: false),
					Participant(name: "Jack Black", amountOwed: 13.44, hasPaid: true)
				],
				description: "Popcorn, drinks, and candy for group movie",
				isSettled: false
			),
			SplitBill(
				title: "Uber to Airport",
				totalAmount: 45.00,
				date: dateFormatter.date(from: "2025-08-04") ?? Date(),
				location: "LAX Airport",
				participants: [
					Participant(name: "Kevin Brown", amountOwed: 15.00, hasPaid: true),
					Participant(name: "Lisa Wang", amountOwed: 15.00, hasPaid: true),
					Participant(name: "Mark Taylor", amountOwed: 15.00, hasPaid: true)
				],
				description: "Shared ride to catch the flight",
				isSettled: true
			)
		]
	}
}

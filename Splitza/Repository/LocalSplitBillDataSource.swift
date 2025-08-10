//
//  LocalSplitBillDataSource.swift
//  Splitza
//
//  Created by Jeffry Sandy Purnomo on 10/08/25.
//

final class LocalSplitBillDataSource: SplitBillDataSource {
	
	private let manager: SplitBillManager
	
	init(manager: SplitBillManager = SplitBillManager.shared) {
		self.manager = manager
	}
	
	func getAllSplitBills() -> AnyPublisher<[SplitBill], Error> {
		let bills = manager.getAllSplitBills()
		return Just(bills)
			.setFailureType(to: Error.self)
			.eraseToAnyPublisher()
	}
	
	func getSplitBill(id: String) -> AnyPublisher<SplitBill, Error> {
		let bills = manager.getAllSplitBills()
		
		if let bill = bills.first(where: { $0.id == id }) {
			return Just(bill)
				.setFailureType(to: Error.self)
				.eraseToAnyPublisher()
		} else {
			return Fail(error: SplitBillRepositoryError.splitBillNotFound)
				.eraseToAnyPublisher()
		}
	}
	
	func searchSplitBills(query: String) -> AnyPublisher<[SplitBill], Error> {
		let bills = manager.searchSplitBills(query: query)
		return Just(bills)
			.setFailureType(to: Error.self)
			.eraseToAnyPublisher()
	}
	
	func createSplitBill(_ splitBill: SplitBill) -> AnyPublisher<SplitBill, Error> {
		manager.addSplitBill(splitBill)
		return Just(splitBill)
			.setFailureType(to: Error.self)
			.eraseToAnyPublisher()
	}
	
	func updateSplitBill(_ splitBill: SplitBill) -> AnyPublisher<SplitBill, Error> {
		manager.updateSplitBill(splitBill)
		return Just(splitBill)
			.setFailureType(to: Error.self)
			.eraseToAnyPublisher()
	}
	
	func deleteSplitBill(id: String) -> AnyPublisher<Void, Error> {
		manager.deleteSplitBill(withId: id)
		return Just(())
			.setFailureType(to: Error.self)
			.eraseToAnyPublisher()
	}
	
	func settleSplitBill(id: String) -> AnyPublisher<SplitBill, Error> {
		let bills = manager.getAllSplitBills()
		
		guard var bill = bills.first(where: { $0.id == id }) else {
			return Fail(error: SplitBillRepositoryError.splitBillNotFound)
				.eraseToAnyPublisher()
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
		
		return Just(settledBill)
			.setFailureType(to: Error.self)
			.eraseToAnyPublisher()
	}
}

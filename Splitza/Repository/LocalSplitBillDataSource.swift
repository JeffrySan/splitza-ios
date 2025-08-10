//
//  LocalSplitBillDataSource.swift
//  Splitza
//
//  Created by Jeffry Sandy Purnomo on 10/08/25.
//

import RxSwift

final class LocalSplitBillDataSource: SplitBillDataSource {
	
	private let manager: SplitBillManager
	
	init(manager: SplitBillManager = SplitBillManager.shared) {
		self.manager = manager
	}
	
	func getAllSplitBills() -> Observable<[SplitBill]> {
		let bills = manager.getAllSplitBills()
		return Observable.just(bills)
	}
	
	func getSplitBill(id: String) -> Observable<SplitBill> {
		let bills = manager.getAllSplitBills()
		
		if let bill = bills.first(where: { $0.id == id }) {
			return Observable.just(bill)
		} else {
			return Observable.error(SplitBillRepositoryError.splitBillNotFound)
		}
	}
	
	func searchSplitBills(query: String) -> Observable<[SplitBill]> {
		let bills = manager.searchSplitBills(query: query)
		return Observable.just(bills)
	}
	
	func createSplitBill(_ splitBill: SplitBill) -> Observable<SplitBill> {
		manager.addSplitBill(splitBill)
		return Observable.just(splitBill)
	}
	
	func updateSplitBill(_ splitBill: SplitBill) -> Observable<SplitBill> {
		manager.updateSplitBill(splitBill)
		return Observable.just(splitBill)
	}
	
	func deleteSplitBill(id: String) -> Observable<Void> {
		manager.deleteSplitBill(withId: id)
		return Observable.just(())
	}
	
	func settleSplitBill(id: String) -> Observable<SplitBill> {
		let bills = manager.getAllSplitBills()
		
		guard var bill = bills.first(where: { $0.id == id }) else {
			return Observable.error(SplitBillRepositoryError.splitBillNotFound)
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
		
		return Observable.just(settledBill)
	}
}

//
//  AddBillViewModel.swift
//  Splitza
//
//  Created by Jeffry Sandy Purnomo on 30/08/25.
//

import Foundation
import RxSwift
import RxRelay

final class AddBillViewModel {
	
	// MARK: - Dependencies
	
	private let repository: SplitBillRepository
	let disposeBag = DisposeBag()
	
	// MARK: - Form Data Relays
	
	let titleRelay = BehaviorRelay<String>(value: "")
	let amountRelay = BehaviorRelay<String>(value: "")
	let locationRelay = BehaviorRelay<String>(value: "")
	let descriptionRelay = BehaviorRelay<String>(value: "")
	let currencyRelay = BehaviorRelay<String>(value: "USD")
	let participantsRelay = BehaviorRelay<[ParticipantInput]>(value: [])
	
	// MARK: - State Relays
	
	let isLoadingRelay = BehaviorRelay<Bool>(value: false)
	let errorRelay = PublishRelay<Error>()
	let successRelay = PublishRelay<SplitBill>()
	
	// MARK: - Computed Properties
	
	var isFormValid: Observable<Bool> {
		return Observable.combineLatest(
			titleRelay.asObservable(),
			amountRelay.asObservable(),
			participantsRelay.asObservable()
		) { title, amount, participants in
			return !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
				   !amount.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
				   Double(amount) != nil &&
				   !participants.isEmpty &&
				   participants.allSatisfy { !$0.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
		}
	}
	
	var totalAmount: Observable<Double> {
		return amountRelay.asObservable()
			.map { Double($0) ?? 0.0 }
	}
	
	var participantCount: Observable<Int> {
		return participantsRelay.asObservable()
			.map { $0.count }
	}
	
	var amountPerParticipant: Observable<Double> {
		return Observable.combineLatest(totalAmount, participantCount) { total, count in
			return count > 0 ? total / Double(count) : 0.0
		}
	}
	
	// MARK: - Initialization
	
	init(repository: SplitBillRepository = SplitBillRepository(dataSourceType: .remote)) {
		self.repository = repository
	}
	
	// MARK: - Participant Management
	
	func addParticipant() {
		var participants = participantsRelay.value
		participants.append(ParticipantInput(name: "", email: ""))
		participantsRelay.accept(participants)
	}
	
	func removeParticipant(at index: Int) {
		var participants = participantsRelay.value
		guard index < participants.count else { return }
		participants.remove(at: index)
		participantsRelay.accept(participants)
	}
	
	func updateParticipant(at index: Int, name: String, email: String) {
		var participants = participantsRelay.value
		guard index < participants.count else { return }
		participants[index] = ParticipantInput(name: name, email: email)
		participantsRelay.accept(participants)
	}
	
	// MARK: - Bill Creation
	
	func createBill() {
		guard !isLoadingRelay.value else { return }
		
		let title = titleRelay.value.trimmingCharacters(in: .whitespacesAndNewlines)
		let amountString = amountRelay.value.trimmingCharacters(in: .whitespacesAndNewlines)
		let location = locationRelay.value.trimmingCharacters(in: .whitespacesAndNewlines)
		let description = descriptionRelay.value.trimmingCharacters(in: .whitespacesAndNewlines)
		let currency = currencyRelay.value
		let participantInputs = participantsRelay.value
		
		guard let totalAmount = Double(amountString) else {
			errorRelay.accept(AddBillError.invalidAmount)
			return
		}
		
		guard !participantInputs.isEmpty else {
			errorRelay.accept(AddBillError.noParticipants)
			return
		}
		
		isLoadingRelay.accept(true)
		
		// Calculate amount per participant
		let amountPerParticipant = totalAmount / Double(participantInputs.count)
		
		// Create participants
		let participants = participantInputs.map { input in
			Participant(
				name: input.name.trimmingCharacters(in: .whitespacesAndNewlines),
				email: input.email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : input.email.trimmingCharacters(in: .whitespacesAndNewlines),
				amountOwed: amountPerParticipant
			)
		}
		
		// Create split bill
		let splitBill = SplitBill(
			title: title,
			totalAmount: totalAmount,
			location: location.isEmpty ? nil : location,
			participants: participants,
			currency: currency,
			description: description.isEmpty ? nil : description
		)
		
		repository.createSplitBill(splitBill)
			.observe(on: MainScheduler.instance)
			.subscribe(
				onNext: { [weak self] createdBill in
					self?.isLoadingRelay.accept(false)
					self?.successRelay.accept(createdBill)
				},
				onError: { [weak self] error in
					self?.isLoadingRelay.accept(false)
					self?.errorRelay.accept(error)
				}
			)
			.disposed(by: disposeBag)
	}
	
	// MARK: - Form Reset
	
	func resetForm() {
		titleRelay.accept("")
		amountRelay.accept("")
		locationRelay.accept("")
		descriptionRelay.accept("")
		currencyRelay.accept("USD")
		participantsRelay.accept([])
	}
}

// MARK: - Supporting Models

struct ParticipantInput {
	let name: String
	let email: String
}

enum AddBillError: LocalizedError {
	case invalidAmount
	case noParticipants
	case networkError
	
	var errorDescription: String? {
		switch self {
		case .invalidAmount:
			return "Please enter a valid amount"
		case .noParticipants:
			return "Please add at least one participant"
		case .networkError:
			return "Network error occurred. Please try again."
		}
	}
}

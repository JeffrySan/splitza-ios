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
	private let participantManager: ParticipantManagerProtocol
	let disposeBag = DisposeBag()
	
	// MARK: - Form Data Relays
	
	let titleRelay = BehaviorRelay<String>(value: "")
	let amountRelay = BehaviorRelay<String>(value: "")
	let manualTotalAmountRelay = BehaviorRelay<Double>(value: 0.0)
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
			participantsRelay.asObservable(),
			manualTotalAmountRelay.asObservable(),
			isAmountBalanced
		) { title, participants, manualTotal, isBalanced in
			let hasTitle = !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
			let hasValidTotal = manualTotal > 0
			let hasValidParticipants = !participants.isEmpty && participants.allSatisfy { participant in
				let hasName = !participant.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
				let hasValidAmount = !participant.amount.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && 
									 Double(participant.amount) != nil && 
									 (Double(participant.amount) ?? 0) > 0
				return hasName && hasValidAmount
			}
			return hasTitle && hasValidTotal && hasValidParticipants && isBalanced
		}
	}
	
	var totalAmount: Observable<Double> {
		return participantsRelay.asObservable()
			.map { participants in
				return participants.compactMap { Double($0.amount) }.reduce(0, +)
			}
	}
	
	var distributedAmount: Observable<Double> {
		return participantsRelay.asObservable()
			.map { participants in
				return participants.compactMap { Double($0.amount) }.reduce(0, +)
			}
	}
	
	var isAmountBalanced: Observable<Bool> {
		return Observable.combineLatest(
			manualTotalAmountRelay.asObservable(),
			distributedAmount
		) { manualTotal, distributed in
			return abs(manualTotal - distributed) < 0.01 // Allow for small rounding differences
		}
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
	
	init(repository: SplitBillRepository = SplitBillRepository(dataSourceType: .remote),
		 participantManager: ParticipantManagerProtocol = ParticipantManager()) {
		self.repository = repository
		self.participantManager = participantManager
	}
	
	// MARK: - Participant Management
	
	func getSavedParticipants() -> [SavedParticipant] {
		return participantManager.getAllParticipants()
	}
	
	func searchSavedParticipants(query: String) -> [SavedParticipant] {
		return participantManager.searchParticipants(with: query)
	}
	
	func addParticipant() {
		var participants = participantsRelay.value
		participants.append(ParticipantInput(name: "", email: "", amount: ""))
		participantsRelay.accept(participants)
	}
	
	func addSavedParticipant(_ savedParticipant: SavedParticipant) {
		var participants = participantsRelay.value
		participants.append(ParticipantInput(
			name: savedParticipant.name,
			email: savedParticipant.email ?? "",
			amount: ""
		))
		participantsRelay.accept(participants)
		participantManager.updateLastUsedDate(for: savedParticipant.id)
	}
	
	func removeParticipant(at index: Int) {
		var participants = participantsRelay.value
		guard index < participants.count else { return }
		participants.remove(at: index)
		participantsRelay.accept(participants)
	}
	
	func updateParticipant(at index: Int, name: String, email: String?, amount: String) {
		var participants = participantsRelay.value
		guard index < participants.count else { return }
		participants[index] = ParticipantInput(name: name, email: email, amount: amount)
		participantsRelay.accept(participants)
	}
	
	func distributeAmountEqually() {
		let totalAmount = manualTotalAmountRelay.value
		let participants = participantsRelay.value
		
		guard totalAmount > 0 && !participants.isEmpty else { return }
		
		let amountPerPerson = totalAmount / Double(participants.count)
		let formattedAmount = String(format: "%.2f", amountPerPerson)
		
		let updatedParticipants = participants.map { participant in
			ParticipantInput(
				name: participant.name,
				email: participant.email,
				amount: formattedAmount
			)
		}
		
		participantsRelay.accept(updatedParticipants)
	}
	
	// MARK: - Bill Creation
	
	func createBill() {
		guard !isLoadingRelay.value else { return }
		
		let title = titleRelay.value.trimmingCharacters(in: .whitespacesAndNewlines)
		let location = locationRelay.value.trimmingCharacters(in: .whitespacesAndNewlines)
		let description = descriptionRelay.value.trimmingCharacters(in: .whitespacesAndNewlines)
		let currency = currencyRelay.value
		let participantInputs = participantsRelay.value
		
		guard !participantInputs.isEmpty else {
			errorRelay.accept(AddBillError.noParticipants)
			return
		}
		
		// Validate all participants have valid amounts
		let invalidParticipants = participantInputs.filter { input in
			guard let amount = Double(input.amount), amount > 0 else { return true }
			return input.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
		}
		
		guard invalidParticipants.isEmpty else {
			errorRelay.accept(AddBillError.invalidParticipantData)
			return
		}
		
		isLoadingRelay.accept(true)
		
		// Create participants with individual amounts
		let participants = participantInputs.compactMap { input -> Participant? in
			guard let amount = Double(input.amount), amount > 0 else { return nil }
			let trimmedName = input.name.trimmingCharacters(in: .whitespacesAndNewlines)
			let trimmedEmail = (input.email?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "")
			
			// Save participant for future use
			let savedParticipant = SavedParticipant(
				name: trimmedName,
				email: trimmedEmail.isEmpty ? nil : trimmedEmail
			)
			participantManager.saveParticipant(savedParticipant)
			
			return Participant(
				name: trimmedName,
				email: trimmedEmail.isEmpty ? nil : trimmedEmail,
				amountOwed: amount
			)
		}
		
		// Use the manual total amount entered by user
		let totalAmount = manualTotalAmountRelay.value
		
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
	
	// MARK: - Actions
	
	func saveBill() {
		isLoadingRelay.accept(true)
		
		// Create SplitBill from current data
		let splitBill = SplitBill(
			title: titleRelay.value,
			totalAmount: manualTotalAmountRelay.value,
			date: Date(),
			location: locationRelay.value,
			participants: [],
			currency: currencyRelay.value,
			description: descriptionRelay.value
		)
		
		// Save bill using repository
		repository.createSplitBill(splitBill)
			.observe(on: MainScheduler.instance)
			.subscribe(
				onNext: { [weak self] savedBill in
					// Save participants to UserDefaults for future use
					let participants = self?.participantsRelay.value ?? []
					for participant in participants {
						if !participant.name.isEmpty {
							let savedParticipant = SavedParticipant(
								id: UUID().uuidString,
								name: participant.name,
								email: participant.email
							)
							self?.participantManager.saveParticipant(savedParticipant)
						}
					}
					
					self?.isLoadingRelay.accept(false)
					self?.successRelay.accept(savedBill)
				},
				onError: { [weak self] error in
					self?.isLoadingRelay.accept(false)
					self?.errorRelay.accept(error)
				}
			)
			.disposed(by: disposeBag)
	}
}

// MARK: - Supporting Models

struct ParticipantInput {
	let name: String
	let email: String?
	let amount: String // Individual amount as string for UI input
	
	init(name: String, email: String?, amount: String = "") {
		self.name = name
		self.email = email
		self.amount = amount
	}
}

enum AddBillError: LocalizedError {
	case invalidAmount
	case noParticipants
	case invalidParticipantData
	case networkError
	
	var errorDescription: String? {
		switch self {
		case .invalidAmount:
			return "Please enter a valid amount"
		case .noParticipants:
			return "Please add at least one participant"
		case .invalidParticipantData:
			return "Please ensure all participants have valid names and amounts"
		case .networkError:
			return "Network error occurred. Please try again."
		}
	}
}

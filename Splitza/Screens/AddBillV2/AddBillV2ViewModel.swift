//
//  AddBillV2ViewModel.swift
//  Splitza
//
//  Created by Jeffry Sandy Purnomo on 31/08/25.
//

import Foundation
import RxSwift
import RxRelay

final class AddBillV2ViewModel {
	
	// MARK: - Properties
	
	private let disposeBag = DisposeBag()
	
	// MARK: - Relays
	
	// Input Relays
	let titleRelay = BehaviorRelay<String>(value: "")
	let locationRelay = BehaviorRelay<String>(value: "")
	let descriptionRelay = BehaviorRelay<String>(value: "")
	let currencyRelay = BehaviorRelay<String>(value: "IDR")
	
	// Data Relays
	let participantsRelay = BehaviorRelay<[BillParticipant]>(value: [])
	let menuItemsRelay = BehaviorRelay<[MenuItem]>(value: [])
	
	// UI State Relays
	let isParticipantsSectionCollapsed = BehaviorRelay<Bool>(value: false)
	let isLoadingRelay = BehaviorRelay<Bool>(value: false)
	let errorRelay = PublishRelay<Error>()
	let successRelay = PublishRelay<SplitBill>()
	
	// MARK: - Observables
	
	let totalAmountObservable: Observable<Double>
	let participantTotalsObservable: Observable<[String: Double]>
	
	var selectedParticipant: BehaviorRelay<BillParticipant>!
	
	// MARK: - Initialization
	
	init() {
		// Add default "Me" participant
		let defaultParticipant = BillParticipant(
			name: "Me",
			email: ""
		)
		selectedParticipant = .init(value: defaultParticipant)
		participantsRelay.accept([defaultParticipant])
		
		// Calculate total amount from all menu items
		totalAmountObservable = menuItemsRelay
			.map { menuItems in
				menuItems.reduce(0.0) { total, item in
					total + item.price
				}
			}
		
		// Calculate individual participant totals
		participantTotalsObservable = Observable.combineLatest(
			participantsRelay.asObservable(),
			menuItemsRelay.asObservable()
		) { participants, menuItems in
			var totals: [String: Double] = [:]
			for participant in participants {
				totals[participant.id] = participant.totalAmount(from: menuItems)
			}
			return totals
		}
	}
	
	// MARK: - Participant Management
    
	func addParticipant(_ participant: BillParticipant) {
		var currentParticipants = participantsRelay.value
		currentParticipants.append(participant)
		participantsRelay.accept(currentParticipants)
	}
	
	func updateParticipant(
		at index: Int,
		with participant: BillParticipant
	) {
		var currentParticipants = participantsRelay.value
		
		guard index < currentParticipants.count else {
			return
		}
		
		currentParticipants[index] = participant
		participantsRelay.accept(currentParticipants)
	}
	
	func removeParticipant(at index: Int) {
		var currentParticipants = participantsRelay.value
		
		guard index < currentParticipants.count,
			currentParticipants.count > 1 else {
			return
		}
		
		let removedParticipant = currentParticipants[index]
		currentParticipants.remove(at: index)
		
		var currentMenuItems = menuItemsRelay.value
		for i in 0..<currentMenuItems.count {
			currentMenuItems[i].participantAssignments.removeValue(
				forKey: removedParticipant.id
			)
		}
		
		participantsRelay.accept(currentParticipants)
		menuItemsRelay.accept(currentMenuItems)
	}
	
	// MARK: - Menu Item Management
	
	func addMenuItem() {
		var currentMenuItems = menuItemsRelay.value
		let newMenuItem = MenuItem(title: "New Item", price: 0.0)
		currentMenuItems.append(newMenuItem)
		menuItemsRelay.accept(currentMenuItems)
	}
	
	func updateMenuItem(at index: Int, with menuItem: MenuItem) {
		var currentMenuItems = menuItemsRelay.value
		
		guard index < currentMenuItems.count else {
			return
		}
		
		currentMenuItems[index] = menuItem
		menuItemsRelay.accept(currentMenuItems)
	}
	
	func removeMenuItem(at index: Int) {
		var currentMenuItems = menuItemsRelay.value
		
		guard index < currentMenuItems.count else {
			return
		}
		
		currentMenuItems.remove(at: index)
		menuItemsRelay.accept(currentMenuItems)
	}
	
	func removeParticipantAssignment(_ participantId: String, fromMenuItem itemId: String) {
		var currentMenuItems = menuItemsRelay.value
		guard let itemIndex = currentMenuItems.firstIndex(where: { $0.id == itemId }) else {
			return
		}
		
		currentMenuItems[itemIndex].participantAssignments.removeValue(forKey: participantId)
		menuItemsRelay.accept(currentMenuItems)
	}
	
	func incrementParticipantShares(_ participantId: String, inMenuItem itemId: String) {
		var currentMenuItems = menuItemsRelay.value
		guard let itemIndex = currentMenuItems.firstIndex(where: { $0.id == itemId }) else {
			return
		}
		
		let currentShares = currentMenuItems[itemIndex].participantAssignments[participantId] ?? 0
		currentMenuItems[itemIndex].participantAssignments[participantId] = currentShares + 1
		menuItemsRelay.accept(currentMenuItems)
	}
	
	func decrementParticipantShares(_ participantId: String, inMenuItem itemId: String) {
		var currentMenuItems = menuItemsRelay.value
		guard let itemIndex = currentMenuItems.firstIndex(where: { $0.id == itemId }) else {
			return
		}
		
		let currentShares = currentMenuItems[itemIndex].participantAssignments[participantId] ?? 0
		if currentShares > 1 {
			currentMenuItems[itemIndex].participantAssignments[participantId] = currentShares - 1
		} else {
			currentMenuItems[itemIndex].participantAssignments.removeValue(forKey: participantId)
		}
		menuItemsRelay.accept(currentMenuItems)
	}
	
	// MARK: - Validation
	
	func canSaveBill() -> Bool {
		let hasTitle = !titleRelay.value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
		let hasMenuItems = !menuItemsRelay.value.isEmpty
		let hasValidMenuItems = menuItemsRelay.value.allSatisfy { item in
			!item.title.isEmpty && item.price > 0 && !item.assignedParticipantIds.isEmpty
		}
		
		return hasTitle && hasMenuItems && hasValidMenuItems
	}
	
	// MARK: - Actions
	
	func toggleParticipantsSection() {
		isParticipantsSectionCollapsed.accept(!isParticipantsSectionCollapsed.value)
	}
	
	func resetForm() {
		titleRelay.accept("")
		locationRelay.accept("")
		descriptionRelay.accept("")
		currencyRelay.accept("IDR")
		
		// Reset to default "Me" participant
		let defaultParticipant = BillParticipant(name: "Me", email: "")
		participantsRelay.accept([defaultParticipant])
		
		menuItemsRelay.accept([])
		isParticipantsSectionCollapsed.accept(false)
	}
}

//
//  HistoryViewModel.swift
//  Splitza
//
//  Created by Jeffry Sandy Purnomo on 10/08/25.
//

import Foundation
import Combine

// MARK: - HistoryViewState

enum HistoryViewState {
	case loading
	case loaded
	case empty
	case searchEmpty
	case error(Error)
}

// MARK: - HistoryViewModel

@MainActor
final class HistoryViewModel: ObservableObject {
	
	// MARK: - Published Properties
	@Published var splitBills: [SplitBill] = []
	@Published var filteredSplitBills: [SplitBill] = []
	@Published var isSearching: Bool = false
	@Published var searchQuery: String = ""
	@Published var viewState: HistoryViewState = .loading
	
	// MARK: - Private Properties
	private let repository: SplitBillRepositoryProtocol
	private var searchTask: Task<Void, Never>?
	private var searchWorkItem: DispatchWorkItem?
	
	var currentDataSource: [SplitBill] {
		return isSearching ? filteredSplitBills : splitBills
	}
	
	var numberOfItems: Int {
		return currentDataSource.count
	}
	
	var isEmpty: Bool {
		return currentDataSource.isEmpty
	}
	
	var emptyStateInfo: (title: String, subtitle: String, imageName: String) {
		if isSearching && isEmpty {
			return (
				title: "No matching bills found",
				subtitle: "Try adjusting your search terms",
				imageName: "magnifyingglass"
			)
		} else if isEmpty {
			return (
				title: "No split bills yet",
				subtitle: "Your split bill history will appear here",
				imageName: "doc.text"
			)
		} else {
			return (title: "", subtitle: "", imageName: "")
		}
	}
	
	// MARK: - Initialization
	
	init(repository: SplitBillRepositoryProtocol? = nil) {
		// Use configuration to determine data source type
		let dataSourceType = NetworkConfiguration.shared.dataSourceType
		self.repository = repository ?? SplitBillRepository(dataSourceType: dataSourceType)
		
		setupSearchObserver()
	}
	
	private func setupSearchObserver() {
		// Observe search query changes with debounced search
		// This will be handled through the updateSearchQuery method with debouncing
	}
	
	// MARK: - Public Methods
	func loadData() async {
		viewState = .loading
		
		do {
			let bills = try await repository.getAllSplitBills()
			splitBills = bills
			updateFilteredBills(bills)
			viewState = .loaded
		} catch {
			viewState = .error(error)
		}
	}
	
	func refreshData() async {
		do {
			let bills = try await repository.getAllSplitBills()
			splitBills = bills
			updateFilteredBills(bills)
			viewState = .loaded
		} catch {
			viewState = .error(error)
		}
	}
	
	func updateSearchQuery(_ query: String) {
		let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
		searchQuery = trimmedQuery
		
		// Cancel previous work item
		searchWorkItem?.cancel()
		
		// Create a new debounced work item
		let workItem = DispatchWorkItem { [weak self] in
			Task {
				await self?.performSearch(query: trimmedQuery)
			}
		}
		searchWorkItem = workItem
		
		// Execute after 0.3s on background thread
		DispatchQueue.global().asyncAfter(deadline: .now() + 0.3, execute: workItem)
	}
	
	func clearSearch() {
		searchTask?.cancel()
		searchQuery = ""
		isSearching = false
		filteredSplitBills = splitBills
	}
	
	func splitBill(at index: Int) -> SplitBill? {
		
		guard index < currentDataSource.count else {
			return nil
		}
		
		return currentDataSource[index]
	}
	
	func deleteSplitBill(at index: Int) async {
		guard index < currentDataSource.count else {
			return
		}
		
		let splitBill = currentDataSource[index]
		
		do {
			try await repository.deleteSplitBill(id: splitBill.id)
			
			// Update local arrays
			if let originalIndex = splitBills.firstIndex(where: { $0.id == splitBill.id }) {
				splitBills.remove(at: originalIndex)
			}
			
			if isSearching {
				if let filteredIndex = filteredSplitBills.firstIndex(where: { $0.id == splitBill.id }) {
					filteredSplitBills.remove(at: filteredIndex)
				}
			}
			
			viewState = .loaded
		} catch {
			viewState = .error(error)
		}
	}
	
	func addSplitBill(_ splitBill: SplitBill) async {
		do {
			_ = try await repository.createSplitBill(splitBill)
			await refreshData()
		} catch {
			viewState = .error(error)
		}
	}
	
	func updateSplitBill(_ splitBill: SplitBill) async {
		do {
			_ = try await repository.updateSplitBill(splitBill)
			await refreshData()
		} catch {
			viewState = .error(error)
		}
	}
	
	func settleSplitBill(at index: Int) async {
		guard index < currentDataSource.count else { return }
		
		let splitBill = currentDataSource[index]
		
		do {
			_ = try await repository.settleSplitBill(id: splitBill.id)
			await refreshData()
		} catch {
			viewState = .error(error)
		}
	}
	
	// MARK: - Private Methods
	
	private func performSearch(query: String) async {
		let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
		
		if trimmedQuery.isEmpty {
			isSearching = false
			filteredSplitBills = splitBills
		} else {
			isSearching = true
			
			do {
				let searchResults = try await repository.searchSplitBills(query: trimmedQuery)
				filteredSplitBills = searchResults
			} catch {
				// Fallback to local search if remote search fails
				performLocalSearch(query: trimmedQuery)
			}
		}
		
		viewState = isEmpty ? (isSearching ? .searchEmpty : .empty) : .loaded
	}
	
	private func performLocalSearch(query: String) {
		let lowercasedQuery = query.lowercased()
		
		Task {
			let filtered = splitBills.filter { splitBill in
				splitBill.title.lowercased().contains(lowercasedQuery) ||
				splitBill.location?.lowercased().contains(lowercasedQuery) == true ||
				splitBill.description?.lowercased().contains(lowercasedQuery) == true ||
				splitBill.participants.contains { $0.name.lowercased().contains(lowercasedQuery) }
			}.sorted { $0.date > $1.date }
			
			await MainActor.run {
				filteredSplitBills = filtered
				viewState = .loaded
			}
		}
	}
	
	private func updateFilteredBills(_ bills: [SplitBill]) {
		if isSearching {
			Task {
				await performSearch(query: searchQuery)
			}
		} else {
			filteredSplitBills = bills
		}
	}
}

// MARK: - Analytics & Statistics Extensions

extension HistoryViewModel {
	
	var totalBillsCount: Int {
		return splitBills.count
	}
	
	var settledBillsCount: Int {
		return splitBills.filter { $0.isSettled }.count
	}
	
	var pendingBillsCount: Int {
		return splitBills.filter { !$0.isSettled }.count
	}
	
	var totalAmountOwed: Double {
		return splitBills.reduce(0) { total, bill in
			total + bill.totalAmount
		}
	}
	
	var settledAmount: Double {
		return splitBills.filter { $0.isSettled }.reduce(0) { total, bill in
			total + bill.totalAmount
		}
	}
	
	var pendingAmount: Double {
		return splitBills.filter { !$0.isSettled }.reduce(0) { total, bill in
			total + bill.totalAmount
		}
	}
	
	var statistics: (
		totalBills: Int,
		settledBills: Int,
		pendingBills: Int,
		totalAmount: Double,
		settledAmount: Double,
		pendingAmount: Double
	) {
		let settledBills = splitBills.filter { $0.isSettled }
		let pendingBills = splitBills.filter { !$0.isSettled }
		
		return (
			totalBills: splitBills.count,
			settledBills: settledBills.count,
			pendingBills: pendingBills.count,
			totalAmount: splitBills.reduce(0) { $0 + $1.totalAmount },
			settledAmount: settledBills.reduce(0) { $0 + $1.totalAmount },
			pendingAmount: pendingBills.reduce(0) { $0 + $1.totalAmount }
		)
	}
}

// MARK: - Error Handling

extension HistoryViewModel {
	
	enum HistoryError: AppError {
		case dataLoadFailed
		case splitBillNotFound
		case invalidIndex
		
		var userMessage: String {
			switch self {
			case .dataLoadFailed:
				return "Failed to load split bill history"
			case .splitBillNotFound:
				return "Split bill not found"
			case .invalidIndex:
				return "Invalid split bill index"
			}
		}
		
		var debugMessage: String {
			switch self {
			case .dataLoadFailed:
				return "Failed to fetch split bill data from repository"
			case .splitBillNotFound:
				return "Split bill with specified ID was not found in the data source"
			case .invalidIndex:
				return "Attempted to access split bill at invalid index"
			}
		}
		
		var errorCode: String? {
			switch self {
			case .dataLoadFailed: return "history_data_load_failed"
			case .splitBillNotFound: return "history_split_bill_not_found"
			case .invalidIndex: return "history_invalid_index"
			}
		}
	}
}


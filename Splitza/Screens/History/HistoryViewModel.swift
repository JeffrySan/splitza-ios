//
//  HistoryViewModel.swift
//  Splitza
//
//  Created by Jeffry Sandy Purnomo on 10/08/25.
//

import Foundation
import Combine

// MARK: - HistoryViewModelDelegate

protocol HistoryViewModelDelegate: AnyObject {
	func historyViewModelDidUpdateData(_ viewModel: HistoryViewModel)
	func historyViewModel(_ viewModel: HistoryViewModel, didEncounterError error: Error)
}

// MARK: - HistoryViewState

enum HistoryViewState {
	case loading
	case loaded
	case empty
	case searchEmpty
	case error(Error)
}

// MARK: - HistoryViewModel

final class HistoryViewModel: ObservableObject {
	
	// MARK: - Published Properties
	
	@Published private(set) var splitBills: [SplitBill] = []
	@Published private(set) var filteredSplitBills: [SplitBill] = []
	@Published private(set) var isSearching = false
	@Published private(set) var searchQuery = ""
	@Published private(set) var viewState: HistoryViewState = .loading
	
	// MARK: - Private Properties
	
	private let repository: SplitBillRepository
	private var cancellables = Set<AnyCancellable>()
	
	// MARK: - Delegate
	
	weak var delegate: HistoryViewModelDelegate?	// MARK: - Computed Properties
	
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
	
	init(repository: SplitBillRepository? = nil) {
		// Use configuration to determine data source type
		let dataSourceType = NetworkConfiguration.shared.dataSourceType
		self.repository = repository ?? SplitBillRepository(dataSourceType: dataSourceType)
		setupBindings()
	}	// MARK: - Setup
	
	private func setupBindings() {
		// Observe search query changes and perform debounced search
		$searchQuery
			.debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
			.removeDuplicates()
			.sink { [weak self] query in
				self?.performSearch(query: query)
			}
			.store(in: &cancellables)
	}
	
	// MARK: - Public Methods
	
	func loadData() {
		viewState = .loading
		
		// Load sample data for demo (this will be removed when using real API)
		SplitBillManager.shared.loadSampleData()
		
		repository.getAllSplitBills()
			.receive(on: DispatchQueue.main)
			.sink(
				receiveCompletion: { [weak self] completion in
					if case .failure(let error) = completion {
						self?.viewState = .error(error)
						self?.delegate?.historyViewModel(self!, didEncounterError: error)
					}
				},
				receiveValue: { [weak self] bills in
					self?.splitBills = bills
					self?.filteredSplitBills = bills
					self?.updateViewState()
					self?.notifyDelegate()
				}
			)
			.store(in: &cancellables)
	}
	
	func refreshData() {
		repository.getAllSplitBills()
			.receive(on: DispatchQueue.main)
			.sink(
				receiveCompletion: { [weak self] completion in
					if case .failure(let error) = completion {
						self?.delegate?.historyViewModel(self!, didEncounterError: error)
					}
				},
				receiveValue: { [weak self] bills in
					self?.splitBills = bills
					
					if self?.isSearching == true {
						self?.performSearch(query: self?.searchQuery ?? "")
					} else {
						self?.filteredSplitBills = bills
					}
					
					self?.updateViewState()
					self?.notifyDelegate()
				}
			)
			.store(in: &cancellables)
	}	func updateSearchQuery(_ query: String) {
		let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
		searchQuery = trimmedQuery
	}
	
	func clearSearch() {
		searchQuery = ""
		isSearching = false
		filteredSplitBills = splitBills
		updateViewState()
		notifyDelegate()
	}
	
	func splitBill(at index: Int) -> SplitBill? {
		guard index < currentDataSource.count else { return nil }
		return currentDataSource[index]
	}
	
	func deleteSplitBill(at index: Int) {
		guard index < currentDataSource.count else { return }
		
		let splitBill = currentDataSource[index]
		
		repository.deleteSplitBill(id: splitBill.id)
			.receive(on: DispatchQueue.main)
			.sink(
				receiveCompletion: { [weak self] completion in
					if case .failure(let error) = completion {
						self?.delegate?.historyViewModel(self!, didEncounterError: error)
					}
				},
				receiveValue: { [weak self] _ in
					// Remove from local arrays
					if let originalIndex = self?.splitBills.firstIndex(where: { $0.id == splitBill.id }) {
						self?.splitBills.remove(at: originalIndex)
					}
					
					if self?.isSearching == true,
					   let filteredIndex = self?.filteredSplitBills.firstIndex(where: { $0.id == splitBill.id }) {
						self?.filteredSplitBills.remove(at: filteredIndex)
					}
					
					self?.updateViewState()
					self?.notifyDelegate()
				}
			)
			.store(in: &cancellables)
	}
	
	func addSplitBill(_ splitBill: SplitBill) {
		repository.createSplitBill(splitBill)
			.receive(on: DispatchQueue.main)
			.sink(
				receiveCompletion: { [weak self] completion in
					if case .failure(let error) = completion {
						self?.delegate?.historyViewModel(self!, didEncounterError: error)
					}
				},
				receiveValue: { [weak self] _ in
					self?.refreshData()
				}
			)
			.store(in: &cancellables)
	}
	
	func updateSplitBill(_ splitBill: SplitBill) {
		repository.updateSplitBill(splitBill)
			.receive(on: DispatchQueue.main)
			.sink(
				receiveCompletion: { [weak self] completion in
					if case .failure(let error) = completion {
						self?.delegate?.historyViewModel(self!, didEncounterError: error)
					}
				},
				receiveValue: { [weak self] _ in
					self?.refreshData()
				}
			)
			.store(in: &cancellables)
	}
	
	func settleSplitBill(at index: Int) {
		guard index < currentDataSource.count else { return }
		
		let splitBill = currentDataSource[index]
		
		repository.settleSplitBill(id: splitBill.id)
			.receive(on: DispatchQueue.main)
			.sink(
				receiveCompletion: { [weak self] completion in
					if case .failure(let error) = completion {
						self?.delegate?.historyViewModel(self!, didEncounterError: error)
					}
				},
				receiveValue: { [weak self] settledBill in
					// Update local arrays with settled bill
					if let originalIndex = self?.splitBills.firstIndex(where: { $0.id == settledBill.id }) {
						self?.splitBills[originalIndex] = settledBill
					}
					
					if self?.isSearching == true,
					   let filteredIndex = self?.filteredSplitBills.firstIndex(where: { $0.id == settledBill.id }) {
						self?.filteredSplitBills[filteredIndex] = settledBill
					}
					
					self?.updateViewState()
					self?.notifyDelegate()
				}
			)
			.store(in: &cancellables)
	}	// MARK: - Private Methods
	
	private func performSearch(query: String) {
		let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
		
		if trimmedQuery.isEmpty {
			isSearching = false
			filteredSplitBills = splitBills
		} else {
			isSearching = true
			
			repository.searchSplitBills(query: trimmedQuery)
				.receive(on: DispatchQueue.main)
				.sink(
					receiveCompletion: { [weak self] completion in
						if case .failure(let error) = completion {
							// Fallback to local search if remote search fails
							self?.performLocalSearch(query: trimmedQuery)
						}
					},
					receiveValue: { [weak self] searchResults in
						self?.filteredSplitBills = searchResults
						self?.updateViewState()
						self?.notifyDelegate()
					}
				)
				.store(in: &cancellables)
		}
		
		updateViewState()
		notifyDelegate()
	}
	
	private func performLocalSearch(query: String) {
		let lowercasedQuery = query.lowercased()
		filteredSplitBills = splitBills.filter { splitBill in
			splitBill.title.lowercased().contains(lowercasedQuery) ||
			splitBill.location?.lowercased().contains(lowercasedQuery) == true ||
			splitBill.description?.lowercased().contains(lowercasedQuery) == true ||
			splitBill.participants.contains { $0.name.lowercased().contains(lowercasedQuery) }
		}.sorted { $0.date > $1.date }
		
		updateViewState()
		notifyDelegate()
	}	private func updateViewState() {
		if splitBills.isEmpty && !isSearching {
			viewState = .empty
		} else if filteredSplitBills.isEmpty && isSearching {
			viewState = .searchEmpty
		} else {
			viewState = .loaded
		}
	}
	
	private func notifyDelegate() {
		delegate?.historyViewModelDidUpdateData(self)
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
	
	func getStatistics() -> (
		totalBills: Int,
		settledBills: Int,
		pendingBills: Int,
		totalAmount: Double,
		settledAmount: Double,
		pendingAmount: Double
	) {
		return (
			totalBills: totalBillsCount,
			settledBills: settledBillsCount,
			pendingBills: pendingBillsCount,
			totalAmount: totalAmountOwed,
			settledAmount: settledAmount,
			pendingAmount: pendingAmount
		)
	}
}

// MARK: - Error Handling

extension HistoryViewModel {
	
	enum HistoryError: LocalizedError {
		case dataLoadFailed
		case splitBillNotFound
		case invalidIndex
		
		var errorDescription: String? {
			switch self {
			case .dataLoadFailed:
				return "Failed to load split bill history"
			case .splitBillNotFound:
				return "Split bill not found"
			case .invalidIndex:
				return "Invalid split bill index"
			}
		}
	}
}


//
//  HistoryViewModel.swift
//  Splitza
//
//  Created by Jeffry Sandy Purnomo on 10/08/25.
//

import Foundation
import RxSwift
import RxRelay

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

final class HistoryViewModel {
	
	// MARK: - Reactive Properties
	
	private let splitBillsRelay = BehaviorRelay<[SplitBill]>(value: [])
	private let filteredSplitBillsRelay = BehaviorRelay<[SplitBill]>(value: [])
	private let isSearchingRelay = BehaviorRelay<Bool>(value: false)
	private let searchQueryRelay = BehaviorRelay<String>(value: "")
	private let viewStateRelay = BehaviorRelay<HistoryViewState>(value: .loading)
	
	// MARK: - Private Properties
	
	private let repository: SplitBillRepository
	private let disposeBag = DisposeBag()
	
	// MARK: - Delegate
	
	weak var delegate: HistoryViewModelDelegate?	// MARK: - Computed Properties
	
	var currentDataSource: [SplitBill] {
		return isSearchingRelay.value ? filteredSplitBillsRelay.value : splitBillsRelay.value
	}
	
	var numberOfItems: Int {
		return currentDataSource.count
	}
	
	var isEmpty: Bool {
		return currentDataSource.isEmpty
	}
	
	var emptyStateInfo: (title: String, subtitle: String, imageName: String) {
		if isSearchingRelay.value && isEmpty {
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
		searchQueryRelay
			.debounce(.milliseconds(300), scheduler: MainScheduler.instance)
			.distinctUntilChanged()
			.subscribe(onNext: { [weak self] query in
				self?.performSearch(query: query)
			})
			.disposed(by: disposeBag)
	}
	
	// MARK: - Public Methods
	
	func loadData() {
		viewStateRelay.accept(.loading)
		
		// Load sample data for demo (this will be removed when using real API)
		SplitBillManager.shared.loadSampleData()
		
		repository.getAllSplitBills()
			.observe(on: MainScheduler.instance)
			.subscribe(
				onNext: { [weak self] bills in
					self?.splitBillsRelay.accept(bills)
					self?.updateFilteredBills(bills)
					self?.viewStateRelay.accept(.loaded)
					self?.delegate?.historyViewModelDidUpdateData(self!)
				},
				onError: { [weak self] error in
					self?.viewStateRelay.accept(.error(error))
					self?.delegate?.historyViewModel(self!, didEncounterError: error)
				}
			)
			.disposed(by: disposeBag)
	}
	func refreshData() {
		repository.getAllSplitBills()
			.observe(on: MainScheduler.instance)
			.subscribe(
				onNext: { [weak self] bills in
					self?.splitBillsRelay.accept(bills)
					self?.updateFilteredBills(bills)
					self?.delegate?.historyViewModelDidUpdateData(self!)
				},
				onError: { [weak self] error in
					self?.delegate?.historyViewModel(self!, didEncounterError: error)
				}
			)
			.disposed(by: disposeBag)
	}
	
	func updateSearchQuery(_ query: String) {
		let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
		searchQueryRelay.accept(trimmedQuery)
	}
	
	func clearSearch() {
		searchQueryRelay.accept("")
		isSearchingRelay.accept(false)
		filteredSplitBillsRelay.accept(splitBillsRelay.value)
		delegate?.historyViewModelDidUpdateData(self)
	}
	
	func splitBill(at index: Int) -> SplitBill? {
		guard index < currentDataSource.count else { return nil }
		return currentDataSource[index]
	}
	
	func deleteSplitBill(at index: Int) {
		guard index < currentDataSource.count else { return }
		
		let splitBill = currentDataSource[index]
		
		repository.deleteSplitBill(id: splitBill.id)
			.observe(on: MainScheduler.instance)
			.subscribe(
				onNext: { [weak self] _ in
					// Remove from local arrays
					var currentBills = self?.splitBillsRelay.value ?? []
					if let originalIndex = currentBills.firstIndex(where: { $0.id == splitBill.id }) {
						currentBills.remove(at: originalIndex)
						self?.splitBillsRelay.accept(currentBills)
					}
					
					if self?.isSearchingRelay.value == true {
						var currentFilteredBills = self?.filteredSplitBillsRelay.value ?? []
						if let filteredIndex = currentFilteredBills.firstIndex(where: { $0.id == splitBill.id }) {
							currentFilteredBills.remove(at: filteredIndex)
							self?.filteredSplitBillsRelay.accept(currentFilteredBills)
						}
					}
					
					self?.delegate?.historyViewModelDidUpdateData(self!)
				},
				onError: { [weak self] error in
					self?.delegate?.historyViewModel(self!, didEncounterError: error)
				}
			)
			.disposed(by: disposeBag)
	}
	
	func addSplitBill(_ splitBill: SplitBill) {
		repository.createSplitBill(splitBill)
			.observe(on: MainScheduler.instance)
			.subscribe(
				onNext: { [weak self] _ in
					self?.refreshData()
				},
				onError: { [weak self] error in
					self?.delegate?.historyViewModel(self!, didEncounterError: error)
				}
			)
			.disposed(by: disposeBag)
	}
	
	func updateSplitBill(_ splitBill: SplitBill) {
		repository.updateSplitBill(splitBill)
			.observe(on: MainScheduler.instance)
			.subscribe(
				onNext: { [weak self] _ in
					self?.refreshData()
				},
				onError: { [weak self] error in
					self?.delegate?.historyViewModel(self!, didEncounterError: error)
				}
			)
			.disposed(by: disposeBag)
	}
	
	func settleSplitBill(at index: Int) {
		guard index < currentDataSource.count else { return }
		
		let splitBill = currentDataSource[index]
		
		repository.settleSplitBill(id: splitBill.id)
			.observe(on: MainScheduler.instance)
			.subscribe(
				onNext: { [weak self] _ in
					self?.refreshData()
				},
				onError: { [weak self] error in
					self?.delegate?.historyViewModel(self!, didEncounterError: error)
				}
			)
			.disposed(by: disposeBag)
	}
	
	// MARK: - Private Methods
	
	private func performSearch(query: String) {
		let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
		
		if trimmedQuery.isEmpty {
			isSearchingRelay.accept(false)
			filteredSplitBillsRelay.accept(splitBillsRelay.value)
		} else {
			isSearchingRelay.accept(true)
			
			repository.searchSplitBills(query: trimmedQuery)
				.observe(on: MainScheduler.instance)
				.subscribe(
					onNext: { [weak self] searchResults in
						self?.filteredSplitBillsRelay.accept(searchResults)
						self?.delegate?.historyViewModelDidUpdateData(self!)
					},
					onError: { [weak self] error in
						// Fallback to local search if remote search fails
						self?.performLocalSearch(query: trimmedQuery)
					}
				)
				.disposed(by: disposeBag)
		}
		
		delegate?.historyViewModelDidUpdateData(self)
	}
	
	private func performLocalSearch(query: String) {
		let lowercasedQuery = query.lowercased()
		let filtered = splitBillsRelay.value.filter { splitBill in
			splitBill.title.lowercased().contains(lowercasedQuery) ||
			splitBill.location?.lowercased().contains(lowercasedQuery) == true ||
			splitBill.description?.lowercased().contains(lowercasedQuery) == true ||
			splitBill.participants.contains { $0.name.lowercased().contains(lowercasedQuery) }
		}.sorted { $0.date > $1.date }
		
		filteredSplitBillsRelay.accept(filtered)
		delegate?.historyViewModelDidUpdateData(self)
	}
	
	private func updateFilteredBills(_ bills: [SplitBill]) {
		if isSearchingRelay.value {
			performSearch(query: searchQueryRelay.value)
		} else {
			filteredSplitBillsRelay.accept(bills)
		}
	}
}

// MARK: - Analytics & Statistics Extensions

extension HistoryViewModel {
	
	var totalBillsCount: Int {
		return splitBillsRelay.value.count
	}
	
	var settledBillsCount: Int {
		return splitBillsRelay.value.filter { $0.isSettled }.count
	}
	
	var pendingBillsCount: Int {
		return splitBillsRelay.value.filter { !$0.isSettled }.count
	}
	
	var totalAmountOwed: Double {
		return splitBillsRelay.value.reduce(0) { total, bill in
			total + bill.totalAmount
		}
	}
	
	var settledAmount: Double {
		return splitBillsRelay.value.filter { $0.isSettled }.reduce(0) { total, bill in
			total + bill.totalAmount
		}
	}
	
	var pendingAmount: Double {
		return splitBillsRelay.value.filter { !$0.isSettled }.reduce(0) { total, bill in
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


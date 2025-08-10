//
//  SplitBillRepository.swift
//  Splitza
//
//  Created by Jeffry Sandy Purnomo on 10/08/25.
//

import Foundation
import Combine

// MARK: - Data Source Protocol

protocol SplitBillDataSource {
	func getAllSplitBills() -> AnyPublisher<[SplitBill], Error>
	func getSplitBill(id: String) -> AnyPublisher<SplitBill, Error>
	func searchSplitBills(query: String) -> AnyPublisher<[SplitBill], Error>
	func createSplitBill(_ splitBill: SplitBill) -> AnyPublisher<SplitBill, Error>
	func updateSplitBill(_ splitBill: SplitBill) -> AnyPublisher<SplitBill, Error>
	func deleteSplitBill(id: String) -> AnyPublisher<Void, Error>
	func settleSplitBill(id: String) -> AnyPublisher<SplitBill, Error>
}

// MARK: - Repository Error

enum SplitBillRepositoryError: LocalizedError {
	case splitBillNotFound
	case networkError(Error)
	case cacheError(Error)
	case syncError(Error)
	
	var errorDescription: String? {
		switch self {
		case .splitBillNotFound:
			return "Split bill not found"
		case .networkError(let error):
			return "Network error: \(error.localizedDescription)"
		case .cacheError(let error):
			return "Cache error: \(error.localizedDescription)"
		case .syncError(let error):
			return "Sync error: \(error.localizedDescription)"
		}
	}
}

// MARK: - Split Bill Repository

final class SplitBillRepository {
	
	enum DataSourceType {
		case local
		case remote
		case hybrid // Uses local first, syncs with remote
	}
	
	private let localDataSource: SplitBillDataSource
	private let remoteDataSource: SplitBillDataSource
	private let dataSourceType: DataSourceType
	private var cancellables = Set<AnyCancellable>()
	
	init(
		localDataSource: SplitBillDataSource = LocalSplitBillDataSource(),
		remoteDataSource: SplitBillDataSource = RemoteSplitBillDataSource(),
		dataSourceType: DataSourceType = .local // Default to local for demo
	) {
		self.localDataSource = localDataSource
		self.remoteDataSource = remoteDataSource
		self.dataSourceType = dataSourceType
	}
	
	// MARK: - Public Methods
	
	func getAllSplitBills() -> AnyPublisher<[SplitBill], Error> {
		switch dataSourceType {
		case .local:
			return localDataSource.getAllSplitBills()
			
		case .remote:
			return remoteDataSource.getAllSplitBills()
			
		case .hybrid:
			return localDataSource.getAllSplitBills()
				.flatMap { [weak self] localBills -> AnyPublisher<[SplitBill], Error> in
					guard let self = self else {
						return Just(localBills).setFailureType(to: Error.self).eraseToAnyPublisher()
					}
					
					// Return local data immediately, sync in background
					self.syncWithRemote()
					return Just(localBills).setFailureType(to: Error.self).eraseToAnyPublisher()
				}
				.eraseToAnyPublisher()
		}
	}
	
	func getSplitBill(id: String) -> AnyPublisher<SplitBill, Error> {
		switch dataSourceType {
		case .local:
			return localDataSource.getSplitBill(id: id)
			
		case .remote:
			return remoteDataSource.getSplitBill(id: id)
			
		case .hybrid:
			return localDataSource.getSplitBill(id: id)
				.catch { [weak self] _ -> AnyPublisher<SplitBill, Error> in
					guard let self = self else {
						return Fail(error: SplitBillRepositoryError.splitBillNotFound).eraseToAnyPublisher()
					}
					return self.remoteDataSource.getSplitBill(id: id)
				}
				.eraseToAnyPublisher()
		}
	}
	
	func searchSplitBills(query: String) -> AnyPublisher<[SplitBill], Error> {
		switch dataSourceType {
		case .local:
			return localDataSource.searchSplitBills(query: query)
			
		case .remote:
			return remoteDataSource.searchSplitBills(query: query)
			
		case .hybrid:
			return localDataSource.searchSplitBills(query: query)
		}
	}
	
	func createSplitBill(_ splitBill: SplitBill) -> AnyPublisher<SplitBill, Error> {
		switch dataSourceType {
		case .local:
			return localDataSource.createSplitBill(splitBill)
			
		case .remote:
			return remoteDataSource.createSplitBill(splitBill)
			
		case .hybrid:
			return localDataSource.createSplitBill(splitBill)
				.flatMap { [weak self] localBill -> AnyPublisher<SplitBill, Error> in
					guard let self = self else {
						return Just(localBill).setFailureType(to: Error.self).eraseToAnyPublisher()
					}
					
					// Save locally first, then sync to remote
					return self.remoteDataSource.createSplitBill(splitBill)
						.catch { _ in
							// If remote fails, still return local success
							Just(localBill).setFailureType(to: Error.self)
						}
						.eraseToAnyPublisher()
				}
				.eraseToAnyPublisher()
		}
	}
	
	func updateSplitBill(_ splitBill: SplitBill) -> AnyPublisher<SplitBill, Error> {
		switch dataSourceType {
		case .local:
			return localDataSource.updateSplitBill(splitBill)
			
		case .remote:
			return remoteDataSource.updateSplitBill(splitBill)
			
		case .hybrid:
			return localDataSource.updateSplitBill(splitBill)
				.flatMap { [weak self] localBill -> AnyPublisher<SplitBill, Error> in
					guard let self = self else {
						return Just(localBill).setFailureType(to: Error.self).eraseToAnyPublisher()
					}
					
					return self.remoteDataSource.updateSplitBill(splitBill)
						.catch { _ in
							Just(localBill).setFailureType(to: Error.self)
						}
						.eraseToAnyPublisher()
				}
				.eraseToAnyPublisher()
		}
	}
	
	func deleteSplitBill(id: String) -> AnyPublisher<Void, Error> {
		switch dataSourceType {
		case .local:
			return localDataSource.deleteSplitBill(id: id)
			
		case .remote:
			return remoteDataSource.deleteSplitBill(id: id)
			
		case .hybrid:
			return localDataSource.deleteSplitBill(id: id)
				.flatMap { [weak self] _ -> AnyPublisher<Void, Error> in
					guard let self = self else {
						return Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
					}
					
					return self.remoteDataSource.deleteSplitBill(id: id)
						.catch { _ in
							Just(()).setFailureType(to: Error.self)
						}
						.eraseToAnyPublisher()
				}
				.eraseToAnyPublisher()
		}
	}
	
	func settleSplitBill(id: String) -> AnyPublisher<SplitBill, Error> {
		switch dataSourceType {
		case .local:
			return localDataSource.settleSplitBill(id: id)
			
		case .remote:
			return remoteDataSource.settleSplitBill(id: id)
			
		case .hybrid:
			return localDataSource.settleSplitBill(id: id)
				.flatMap { [weak self] localBill -> AnyPublisher<SplitBill, Error> in
					guard let self = self else {
						return Just(localBill).setFailureType(to: Error.self).eraseToAnyPublisher()
					}
					
					return self.remoteDataSource.settleSplitBill(id: id)
						.catch { _ in
							Just(localBill).setFailureType(to: Error.self)
						}
						.eraseToAnyPublisher()
				}
				.eraseToAnyPublisher()
		}
	}
	
	// MARK: - Configuration
	
	func switchToRemoteDataSource() {
		// This could be used when user logs in or network becomes available
	}
	
	func switchToLocalDataSource() {
		// This could be used when user goes offline
	}
	
	// MARK: - Private Methods
	
	private func syncWithRemote() {
		// Background sync - don't block the main flow
		remoteDataSource.getAllSplitBills()
			.sink(
				receiveCompletion: { completion in
					if case .failure(let error) = completion {
						print("Background sync failed: \(error)")
					}
				},
				receiveValue: { remoteBills in
					// Here you would implement sophisticated sync logic
					// For now, we'll just log that sync happened
					print("Background sync completed with \(remoteBills.count) bills")
				}
			)
			.store(in: &cancellables)
	}
}

//
//  SplitBillRepository.swift
//  Splitza
//
//  Created by Jeffry Sandy Purnomo on 10/08/25.
//

import Foundation
import RxSwift

// MARK: - Data Source Protocol

protocol SplitBillDataSource {
	func getAllSplitBills() -> Observable<[SplitBill]>
	func getSplitBill(email: String, name: String) -> Observable<[SplitBill]>
	func searchSplitBills(query: String) -> Observable<[SplitBill]>
	func createSplitBill(_ splitBill: SplitBill) -> Observable<SplitBill>
	func updateSplitBill(_ splitBill: SplitBill) -> Observable<SplitBill>
	func deleteSplitBill(id: String) -> Observable<Void>
	func settleSplitBill(id: String) -> Observable<SplitBill>
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
	private let disposeBag = DisposeBag()
	
	init(
		localDataSource: SplitBillDataSource = LocalSplitBillDataSource(),
		remoteDataSource: SplitBillDataSource = SupabaseSplitBillDataSource(),
		dataSourceType: DataSourceType
	) {
		self.localDataSource = localDataSource
		self.remoteDataSource = remoteDataSource
		self.dataSourceType = dataSourceType
	}
	
	// MARK: - Public Methods
	
	func getAllSplitBills() -> Observable<[SplitBill]> {
		switch dataSourceType {
		case .local:
			return localDataSource.getAllSplitBills()
			
		case .remote:
			return remoteDataSource.getAllSplitBills()
			
		case .hybrid:
			return localDataSource.getAllSplitBills()
				.flatMap { [weak self] localBills -> Observable<[SplitBill]> in
					guard let self = self else {
						return Observable.just(localBills)
					}
					
					// Return local data immediately, sync in background
					self.syncWithRemote()
					return Observable.just(localBills)
				}
		}
	}
	
	func getSplitBill(email: String, name: String) -> Observable<[SplitBill]> {
		switch dataSourceType {
		case .local:
			return localDataSource.getSplitBill(email: "", name: "")
			
		case .remote:
			return remoteDataSource.getSplitBill(email: "", name: "")
			
		case .hybrid:
			return localDataSource.getSplitBill(email: "", name: "")
				.catch { [weak self] _ -> Observable<[SplitBill]> in
					guard let self = self else {
						return Observable.error(SplitBillRepositoryError.splitBillNotFound)
					}
					return self.remoteDataSource.getSplitBill(email: "", name: "")
				}
		}
	}
	
	func searchSplitBills(query: String) -> Observable<[SplitBill]> {
		switch dataSourceType {
		case .local:
			return localDataSource.searchSplitBills(query: query)
			
		case .remote:
			return remoteDataSource.searchSplitBills(query: query)
			
		case .hybrid:
			return localDataSource.searchSplitBills(query: query)
		}
	}
	
	func createSplitBill(_ splitBill: SplitBill) -> Observable<SplitBill> {
		switch dataSourceType {
		case .local:
			return localDataSource.createSplitBill(splitBill)
			
		case .remote:
			return remoteDataSource.createSplitBill(splitBill)
			
		case .hybrid:
			return localDataSource.createSplitBill(splitBill)
				.flatMap { [weak self] localBill -> Observable<SplitBill> in
					guard let self = self else {
						return Observable.just(localBill)
					}
					
					// Save locally first, then sync to remote
					return self.remoteDataSource.createSplitBill(splitBill)
						.catch { _ in
							// If remote fails, still return local success
							Observable.just(localBill)
						}
				}
		}
	}
	
	func updateSplitBill(_ splitBill: SplitBill) -> Observable<SplitBill> {
		switch dataSourceType {
		case .local:
			return localDataSource.updateSplitBill(splitBill)
			
		case .remote:
			return remoteDataSource.updateSplitBill(splitBill)
			
		case .hybrid:
			return localDataSource.updateSplitBill(splitBill)
				.flatMap { [weak self] localBill -> Observable<SplitBill> in
					guard let self = self else {
						return Observable.just(localBill)
					}
					
					return self.remoteDataSource.updateSplitBill(splitBill)
						.catch { _ in
							Observable.just(localBill)
						}
				}
		}
	}
	
	func deleteSplitBill(id: String) -> Observable<Void> {
		switch dataSourceType {
		case .local:
			return localDataSource.deleteSplitBill(id: id)
			
		case .remote:
			return remoteDataSource.deleteSplitBill(id: id)
			
		case .hybrid:
			return localDataSource.deleteSplitBill(id: id)
				.flatMap { [weak self] _ -> Observable<Void> in
					guard let self = self else {
						return Observable.just(())
					}
					
					return self.remoteDataSource.deleteSplitBill(id: id)
						.catch { _ in
							Observable.just(())
						}
				}
		}
	}
	
	func settleSplitBill(id: String) -> Observable<SplitBill> {
		switch dataSourceType {
		case .local:
			return localDataSource.settleSplitBill(id: id)
			
		case .remote:
			return remoteDataSource.settleSplitBill(id: id)
			
		case .hybrid:
			return localDataSource.settleSplitBill(id: id)
				.flatMap { [weak self] localBill -> Observable<SplitBill> in
					guard let self = self else {
						return Observable.just(localBill)
					}
					
					return self.remoteDataSource.settleSplitBill(id: id)
						.catch { _ in
							Observable.just(localBill)
						}
				}
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
			.subscribe(
				onNext: { remoteBills in
					// Here you would implement sophisticated sync logic
					// For now, we'll just log that sync happened
					print("Background sync completed with \(remoteBills.count) bills")
				},
				onError: { error in
					print("Background sync failed: \(error)")
				}
			)
			.disposed(by: disposeBag)
	}
}

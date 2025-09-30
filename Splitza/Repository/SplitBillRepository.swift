//
//  SplitBillRepository.swift
//  Splitza
//
//  Created by Jeffry Sandy Purnomo on 10/08/25.
//

import Foundation

// MARK: - Data Source Protocol

protocol SplitBillDataSource {
	func getAllSplitBills() async throws -> [SplitBill]
	func getSplitBill(email: String, name: String) async throws -> [SplitBill]
	func searchSplitBills(query: String) async throws -> [SplitBill]
	func createSplitBill(_ splitBill: SplitBill) async throws -> SplitBill
	func updateSplitBill(_ splitBill: SplitBill) async throws -> SplitBill
	func deleteSplitBill(id: String) async throws
	func settleSplitBill(id: String) async throws -> SplitBill
}

// MARK: - Repository Protocol

protocol SplitBillRepositoryProtocol {
	func getAllSplitBills() async throws -> [SplitBill]
	func getSplitBill(email: String, name: String) async throws -> [SplitBill]
	func searchSplitBills(query: String) async throws -> [SplitBill]
	func createSplitBill(_ splitBill: SplitBill) async throws -> SplitBill
	func updateSplitBill(_ splitBill: SplitBill) async throws -> SplitBill
	func deleteSplitBill(id: String) async throws
	func settleSplitBill(id: String) async throws -> SplitBill
	func switchToRemoteDataSource()
	func switchToLocalDataSource()
}

// MARK: - Split Bill Repository

final class SplitBillRepository: SplitBillRepositoryProtocol {
	
	enum DataSourceType {
		case local
		case remote
		case hybrid // Uses local first, syncs with remote
	}
	
	private let localDataSource: SplitBillDataSource
	private let remoteDataSource: SplitBillDataSource
	private var dataSourceType: DataSourceType
	
	init(
		localDataSource: SplitBillDataSource = LocalSplitBillDataSource(),
		remoteDataSource: SplitBillDataSource = SupabaseSplitBillDataSource(),
		dataSourceType: DataSourceType = .hybrid
	) {
		self.localDataSource = localDataSource
		self.remoteDataSource = remoteDataSource
		self.dataSourceType = dataSourceType
	}
	
	// MARK: - Public Methods
	
	func getAllSplitBills() async throws -> [SplitBill] {
		switch dataSourceType {
		case .local:
			return try await localDataSource.getAllSplitBills()
			
		case .remote:
			return try await remoteDataSource.getAllSplitBills()
			
		case .hybrid:
			do {
				let localBills = try await localDataSource.getAllSplitBills()
				
				// Sync in background without blocking
				Task {
					do {
						_ = try await remoteDataSource.getAllSplitBills()
						print("Background sync completed")
					} catch {
						print("Background sync failed: \(error)")
					}
				}
				
				return localBills
			} catch {
				throw SplitBillError.cacheError(error)
			}
		}
	}
	
	func getSplitBill(email: String, name: String) async throws -> [SplitBill] {
		switch dataSourceType {
		case .local:
			return try await localDataSource.getSplitBill(email: email, name: name)
			
		case .remote:
			return try await remoteDataSource.getSplitBill(email: email, name: name)
			
		case .hybrid:
			do {
				return try await localDataSource.getSplitBill(email: email, name: name)
			} catch {
				// If local fails, try remote
				do {
					return try await remoteDataSource.getSplitBill(email: email, name: name)
				} catch {
					throw SplitBillError.splitBillNotFound
				}
			}
		}
	}
	
	func searchSplitBills(query: String) async throws -> [SplitBill] {
		switch dataSourceType {
		case .local:
			return try await localDataSource.searchSplitBills(query: query)
			
		case .remote:
			return try await remoteDataSource.searchSplitBills(query: query)
			
		case .hybrid:
			return try await localDataSource.searchSplitBills(query: query)
		}
	}
	
	func createSplitBill(_ splitBill: SplitBill) async throws -> SplitBill {
		switch dataSourceType {
		case .local:
			return try await localDataSource.createSplitBill(splitBill)
			
		case .remote:
			return try await remoteDataSource.createSplitBill(splitBill)
			
		case .hybrid:
			// Save locally first
			let localBill = try await localDataSource.createSplitBill(splitBill)
			
			// Try to sync to remote in background
			Task {
				do {
					_ = try await remoteDataSource.createSplitBill(splitBill)
				} catch {
					print("Failed to sync new bill to remote: \(error)")
				}
			}
			
			return localBill
		}
	}
	
	func updateSplitBill(_ splitBill: SplitBill) async throws -> SplitBill {
		switch dataSourceType {
		case .local:
			return try await localDataSource.updateSplitBill(splitBill)
			
		case .remote:
			return try await remoteDataSource.updateSplitBill(splitBill)
			
		case .hybrid:
			// Update locally first
			let localBill = try await localDataSource.updateSplitBill(splitBill)
			
			// Try to sync to remote in background
			Task {
				do {
					_ = try await remoteDataSource.updateSplitBill(splitBill)
				} catch {
					print("Failed to sync updated bill to remote: \(error)")
				}
			}
			
			return localBill
		}
	}
	
	func deleteSplitBill(id: String) async throws {
		switch dataSourceType {
		case .local:
			try await localDataSource.deleteSplitBill(id: id)
			
		case .remote:
			try await remoteDataSource.deleteSplitBill(id: id)
			
		case .hybrid:
			// Delete locally first
			try await localDataSource.deleteSplitBill(id: id)
			
			// Try to sync to remote in background
			Task {
				do {
					try await remoteDataSource.deleteSplitBill(id: id)
				} catch {
					print("Failed to sync bill deletion to remote: \(error)")
				}
			}
		}
	}
	
	func settleSplitBill(id: String) async throws -> SplitBill {
		switch dataSourceType {
		case .local:
			return try await localDataSource.settleSplitBill(id: id)
			
		case .remote:
			return try await remoteDataSource.settleSplitBill(id: id)
			
		case .hybrid:
			// Settle locally first
			let localBill = try await localDataSource.settleSplitBill(id: id)
			
			// Try to sync to remote in background
			Task {
				do {
					_ = try await remoteDataSource.settleSplitBill(id: id)
				} catch {
					print("Failed to sync settled bill to remote: \(error)")
				}
			}
			
			return localBill
		}
	}
	
	// MARK: - Configuration
	
	func switchToRemoteDataSource() {
		dataSourceType = .remote
	}
	
	func switchToLocalDataSource() {
		dataSourceType = .local
	}
}

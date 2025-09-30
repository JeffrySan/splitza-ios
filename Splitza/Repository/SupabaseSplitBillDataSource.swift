//
//  SupabaseSplitBillDataSource.swift
//  Splitza
//
//  Created by Jeffry Sandy Purnomo on 30/08/25.
//

import Foundation
import Supabase

final class SupabaseSplitBillDataSource: SplitBillDataSource {
	
	private lazy var supabaseClient: SupabaseClient = {
		return SupabaseClient(
			supabaseURL: URL(string: AppConfiguration.baseURL)!,
			supabaseKey: AppConfiguration.supabaseAnonKey
		)
	}()
	
	func getAllSplitBills() async throws -> [SplitBill] {
		do {
			// Get all split bills
			let splitBillsDB: [SplitBillDB] = try await supabaseClient
				.from("split_bills")
				.select()
				.order("date", ascending: false)
				.execute()
				.value
			
			// Get all participants for these split bills
			let splitBillIds = splitBillsDB.map { $0.id }
			let participantsDB: [ParticipantDB] = try await supabaseClient
				.from("participants")
				.select()
				.in("split_bill_id", values: splitBillIds)
				.execute()
				.value
			
			// Group participants by split bill ID
			let participantsByBillId = Dictionary(grouping: participantsDB) { $0.splitBillId }
			
			// Convert to app models
			let splitBills = splitBillsDB.map { splitBillDB in
				let participants = participantsByBillId[splitBillDB.id] ?? []
				return SplitBill(from: splitBillDB, participants: participants)
			}
			
			return splitBills
		} catch {
			throw SplitBillError.networkError(error)
		}
	}
	
	// MARK: - User-Specific Queries
	func getSplitBill(email: String, name: String) async throws -> [SplitBill] {
		do {
			// Get split bill IDs where user participates
			let userParticipants: [ParticipantDB] = try await supabaseClient
				.from("participants")
				.select()
				.or("name.eq.\(name),email.eq.\(email)")
				.execute()
				.value
			
			let splitBillIds = userParticipants.map { $0.splitBillId }
			
			guard !splitBillIds.isEmpty else {
				throw SplitBillError.splitBillNotFound
			}
			
			// Get split bills for those IDs
			let splitBillsDB: [SplitBillDB] = try await supabaseClient
				.from("split_bills")
				.select()
				.in("id", values: splitBillIds)
				.order("date", ascending: false)
				.execute()
				.value
			
			// Get all participants for these split bills
			let participantsDB: [ParticipantDB] = try await supabaseClient
				.from("participants")
				.select()
				.in("split_bill_id", values: splitBillIds)
				.execute()
				.value
			
			// Group participants by split bill ID
			let participantsByBillId = Dictionary(grouping: participantsDB) { $0.splitBillId }
			
			// Convert to app models
			let splitBills = splitBillsDB.map { splitBillDB in
				let participants = participantsByBillId[splitBillDB.id] ?? []
				return SplitBill(from: splitBillDB, participants: participants)
			}
			
			return splitBills
		} catch {
			throw SplitBillError.networkError(error)
		}
	}
	
	func searchSplitBills(query: String) async throws -> [SplitBill] {
		throw SplitBillError.operationFailed
	}
	
	func createSplitBill(_ splitBill: SplitBill) async throws -> SplitBill {
		do {
			// First, insert the split bill
			let splitBillDB = splitBill.toDatabase
			let createdBillDB: SplitBillDB = try await supabaseClient
				.from("split_bills")
				.insert(splitBillDB)
				.select()
				.single()
				.execute()
				.value
			
			// Then, insert participants
			let participantsDB = splitBill.participants.map { $0.toDatabase(splitBillId: createdBillDB.id) }
			let createdParticipantsDB: [ParticipantDB] = try await supabaseClient
				.from("participants")
				.insert(participantsDB)
				.select()
				.execute()
				.value
			
			// Convert back to app model
			let createdSplitBill = SplitBill(from: createdBillDB, participants: createdParticipantsDB)
			
			return createdSplitBill
		} catch {
			throw SplitBillError.networkError(error)
		}
	}
	
	func updateSplitBill(_ splitBill: SplitBill) async throws -> SplitBill {
		throw SplitBillError.operationFailed
	}
	
	func deleteSplitBill(id: String) async throws {
		throw SplitBillError.operationFailed
	}
	
	func settleSplitBill(id: String) async throws -> SplitBill {
		throw SplitBillError.operationFailed
	}
}

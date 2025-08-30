//
//  SupabaseSplitBillDataSource.swift
//  Splitza
//
//  Created by Jeffry Sandy Purnomo on 30/08/25.
//

import Foundation
import RxSwift
import Supabase

final class SupabaseSplitBillDataSource: SplitBillDataSource {
	
	#if DEBUG
	private let supabaseUrl = "https://127.0.0.1:5534"
	private let supabaseKey = ""
	#else
	private let supabaseUrl = "https://snelzienvcjsncoxjgok.supabase.co"
	private let supabaseKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNuZWx6aWVudmNqc25jb3hqZ29rIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1MzA3NTExNiwiZXhwIjoyMDY4NjUxMTE2fQ.murmB5lKurlrZ5nj-JXoKOkIIQ4XtIAIAcA26zioFUk"
	#endif
	
	private lazy var supabaseClient: SupabaseClient = {
		#if DEBUG
		return SupabaseClient(
			supabaseURL: URL(string: supabaseUrl)!,
			supabaseKey: supabaseKey
		)
		#else
		return SupabaseClient(
			supabaseURL: URL(string: supabaseUrl)!,
			supabaseKey: supabaseKey
		)
		#endif
	}()
	
	func getAllSplitBills() -> Observable<[SplitBill]> {
		
		return Observable.create { [weak self] observer -> Disposable in
			
			guard let self else {
				observer.onError(NetworkError.selfDeallocated)
				return Disposables.create()
			}
			
			let task = Task {
				do {
					// Get all split bills
					let splitBillsDB: [SplitBillDB] = try await self.supabaseClient
						.from("split_bills")
						.select()
						.order("date", ascending: false)
						.execute()
						.value
					
					// Get all participants for these split bills
					let splitBillIds = splitBillsDB.map { $0.id }
					let participantsDB: [ParticipantDB] = try await self.supabaseClient
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
					
					observer.onNext(splitBills)
					observer.onCompleted()
				} catch {
					observer.onError(NetworkError.unknown(error))
				}
			}
			
			return Disposables.create {
				task.cancel()
			}
		}
	}
	
	// MARK: - User-Specific Queries
	func getSplitBill(email: String, name: String) -> RxSwift.Observable<[SplitBill]> {
		return Observable.create { [weak self] observer -> Disposable in
			
			guard let self else {
				observer.onError(NetworkError.selfDeallocated)
				return Disposables.create()
			}
			
			let task = Task {
				do {
					// Get split bill IDs where user participates
					let userParticipants: [ParticipantDB] = try await self.supabaseClient
						.from("participants")
						.select()
						.or("name.eq.\(name),email.eq.\(email)")
						.execute()
						.value
					
					let splitBillIds = userParticipants.map { $0.splitBillId }
					
					guard !splitBillIds.isEmpty else {
						observer.onError(NetworkError.noData)
						observer.onCompleted()
						return
					}
					
					// Get split bills for those IDs
					let splitBillsDB: [SplitBillDB] = try await self.supabaseClient
						.from("split_bills")
						.select()
						.in("id", values: splitBillIds)
						.order("date", ascending: false)
						.execute()
						.value
					
					// Get all participants for these split bills
					let participantsDB: [ParticipantDB] = try await self.supabaseClient
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
					
					observer.onNext(splitBills)
					observer.onCompleted()
				} catch {
					observer.onError(NetworkError.unknown(error))
				}
			}
			
			return Disposables.create {
				task.cancel()
			}
		}
	}
	
	func searchSplitBills(query: String) -> RxSwift.Observable<[SplitBill]> {
		return Observable.create({ (observer) -> Disposable in
			observer.onError(NetworkError.notFound)
			
			return Disposables.create()
		})
	}
	
	func createSplitBill(_ splitBill: SplitBill) -> Observable<SplitBill> {
		return Observable.create { [weak self] observer -> Disposable in
			
			guard let self else {
				observer.onError(NetworkError.selfDeallocated)
				return Disposables.create()
			}
			
			let task = Task {
				do {
					// First, insert the split bill
					let splitBillDB = splitBill.toDatabase
					let createdBillDB: SplitBillDB = try await self.supabaseClient
						.from("split_bills")
						.insert(splitBillDB)
						.select()
						.single()
						.execute()
						.value
					
					// Then, insert participants
					let participantsDB = splitBill.participants.map { $0.toDatabase(splitBillId: createdBillDB.id) }
					let createdParticipantsDB: [ParticipantDB] = try await self.supabaseClient
						.from("participants")
						.insert(participantsDB)
						.select()
						.execute()
						.value
					
					// Convert back to app model
					let createdSplitBill = SplitBill(from: createdBillDB, participants: createdParticipantsDB)
					
					observer.onNext(createdSplitBill)
					observer.onCompleted()
				} catch {
					observer.onError(NetworkError.unknown(error))
				}
			}
			
			return Disposables.create {
				task.cancel()
			}
		}
	}
	
	func updateSplitBill(_ splitBill: SplitBill) -> RxSwift.Observable<SplitBill> {
		return Observable.create({ (observer) -> Disposable in
			observer.onError(NetworkError.notFound)
			
			return Disposables.create()
		})
	}
	
	func deleteSplitBill(id: String) -> RxSwift.Observable<Void> {
		return Observable.create({ (observer) -> Disposable in
			observer.onError(NetworkError.notFound)
			
			return Disposables.create()
		})
	}
	
	func settleSplitBill(id: String) -> RxSwift.Observable<SplitBill> {
		return Observable.create({ (observer) -> Disposable in
			observer.onError(NetworkError.notFound)
			
			return Disposables.create()
		})
	}
}

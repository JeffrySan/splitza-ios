//
//  SplitBillDatabase.swift
//  Splitza
//
//  Created by Jeffry Sandy Purnomo on 30/08/25.
//

import Foundation

// MARK: - Database Models (matches Supabase table structure)

struct SplitBillDB: Codable {
    let id: String
    let title: String
    let totalAmount: Double
    let date: Date
    let location: String?
    let currency: String
    let description: String?
    let isSettled: Bool
    let createdAt: Date?
    let updatedAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case totalAmount = "total_amount"
        case date
        case location
        case currency
        case description
        case isSettled = "is_settled"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct ParticipantDB: Codable {
    let id: String
    let splitBillId: String
    let name: String
    let email: String?
    let amountOwed: Double
    let hasPaid: Bool
    let createdAt: Date?
    let updatedAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case splitBillId = "split_bill_id"
        case name
        case email
        case amountOwed = "amount_owed"
        case hasPaid = "has_paid"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - Extensions to convert between App Models and DB Models

extension SplitBill {
    // Convert to database model
    var toDatabase: SplitBillDB {
        return SplitBillDB(
            id: id,
            title: title,
            totalAmount: totalAmount,
            date: date,
            location: location,
            currency: currency,
            description: description,
            isSettled: isSettled,
            createdAt: nil,
            updatedAt: nil
        )
    }
    
    // Create from database models
    init(from splitBillDB: SplitBillDB, participants: [ParticipantDB]) {
        self.init(
            id: splitBillDB.id,
            title: splitBillDB.title,
            totalAmount: splitBillDB.totalAmount,
            date: splitBillDB.date,
            location: splitBillDB.location,
            participants: participants.map { Participant(from: $0) },
            currency: splitBillDB.currency,
            description: splitBillDB.description,
            isSettled: splitBillDB.isSettled
        )
    }
}

extension Participant {
    // Convert to database model
    func toDatabase(splitBillId: String) -> ParticipantDB {
        return ParticipantDB(
            id: id,
            splitBillId: splitBillId,
            name: name,
            email: email,
            amountOwed: amountOwed,
            hasPaid: hasPaid,
            createdAt: nil,
            updatedAt: nil
        )
    }
    
    // Create from database model
    init(from participantDB: ParticipantDB) {
        self.init(
            id: participantDB.id,
            name: participantDB.name,
            email: participantDB.email,
            amountOwed: participantDB.amountOwed,
            hasPaid: participantDB.hasPaid
        )
    }
}

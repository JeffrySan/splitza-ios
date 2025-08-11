//
//  SplitBillRequest.swift
//  Splitza
//
//  Created by Jeffry Sandy Purnomo on 11/08/25.
//

import Foundation
import RxSwift

struct CreateSplitBillRequest: Codable {
	let title: String
	let totalAmount: Double
	let location: String?
	let participants: [CreateParticipantRequest]
	let currency: String
	let description: String?
}

struct CreateParticipantRequest: Codable {
	let name: String
	let email: String?
	let amountOwed: Double
}

struct UpdateSplitBillRequest: Codable {
	let title: String?
	let totalAmount: Double?
	let location: String?
	let participants: [UpdateParticipantRequest]?
	let currency: String?
	let description: String?
	let isSettled: Bool?
}

struct UpdateParticipantRequest: Codable {
	let id: String?
	let name: String?
	let email: String?
	let amountOwed: Double?
	let hasPaid: Bool?
}

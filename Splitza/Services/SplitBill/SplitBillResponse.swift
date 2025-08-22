//
//  SplitBillResponse.swift
//  Splitza
//
//  Created by Jeffry Sandy Purnomo on 11/08/25.
//

import Foundation

struct SplitBillResponse: Codable {
	let success: Bool
	let data: [SplitBill]
	let message: String?
	let pagination: PaginationInfo?
}

struct SingleSplitBillResponse: Codable {
	let success: Bool
	let data: SplitBill
	let message: String?
}

struct PaginationInfo: Codable {
	let currentPage: Int
	let totalPages: Int
	let totalItems: Int
	let itemsPerPage: Int
}

struct ErrorResponse: Codable {
	let success: Bool
	let error: String
	let code: Int?
}

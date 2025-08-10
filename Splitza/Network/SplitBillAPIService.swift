//
//  SplitBillAPIService.swift
//  Splitza
//
//  Created by Jeffry Sandy Purnomo on 10/08/25.
//

import Foundation
import Combine

// MARK: - API Response Models

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

// MARK: - API Request Models

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

// MARK: - Split Bill API Requests

enum SplitBillAPIRequest {
	case getAllSplitBills(page: Int, limit: Int, sortBy: String?, sortOrder: String?)
	case getSplitBill(id: String)
	case searchSplitBills(query: String, page: Int, limit: Int)
	case createSplitBill(CreateSplitBillRequest)
	case updateSplitBill(id: String, UpdateSplitBillRequest)
	case deleteSplitBill(id: String)
	case settleSplitBill(id: String)
	case markParticipantPaid(billId: String, participantId: String, paid: Bool)
}

extension SplitBillAPIRequest: NetworkRequest {
	
	var baseURL: String {
		return NetworkConfiguration.shared.baseURL
	}
	
	var path: String {
		let basePath = NetworkConfiguration.Endpoints.splitBills
		
		switch self {
		case .getAllSplitBills:
			return basePath
		case .getSplitBill(let id):
			return "\(basePath)/\(id)"
		case .searchSplitBills:
			return "\(basePath)/search"
		case .createSplitBill:
			return basePath
		case .updateSplitBill(let id, _):
			return "\(basePath)/\(id)"
		case .deleteSplitBill(let id):
			return "\(basePath)/\(id)"
		case .settleSplitBill(let id):
			return "\(basePath)/\(id)/settle"
		case .markParticipantPaid(let billId, let participantId, _):
			return "\(basePath)/\(billId)/participants/\(participantId)/payment"
		}
	}
	
	var method: HTTPMethod {
		switch self {
		case .getAllSplitBills, .getSplitBill, .searchSplitBills:
			return .GET
		case .createSplitBill:
			return .POST
		case .updateSplitBill, .settleSplitBill, .markParticipantPaid:
			return .PUT
		case .deleteSplitBill:
			return .DELETE
		}
	}
	
	var parameters: [String: Any]? {
		switch self {
		case .getAllSplitBills(let page, let limit, let sortBy, let sortOrder):
			var params: [String: Any] = [
				"page": page,
				"limit": limit
			]
			if let sortBy = sortBy {
				params["sortBy"] = sortBy
			}
			if let sortOrder = sortOrder {
				params["sortOrder"] = sortOrder
			}
			return params
			
		case .searchSplitBills(let query, let page, let limit):
			return [
				"query": query,
				"page": page,
				"limit": limit
			]
			
		case .markParticipantPaid(_, _, let paid):
			return ["paid": paid]
			
		default:
			return nil
		}
	}
	
	var body: Data? {
		switch self {
		case .createSplitBill(let request):
			return try? JSONEncoder().encode(request)
		case .updateSplitBill(_, let request):
			return try? JSONEncoder().encode(request)
		default:
			return nil
		}
	}
	
	var headers: [String: String]? {
		var headers = NetworkConfiguration.shared.defaultHeaders
		
		// Add authentication header if available
		if let authToken = AuthManager.shared.authToken {
			headers["Authorization"] = "Bearer \(authToken)"
		}
		
		return headers
	}
	
	var timeoutInterval: TimeInterval {
		return NetworkConfiguration.shared.requestTimeout
	}
}

// MARK: - Split Bill API Service

protocol SplitBillAPIServiceProtocol {
	func getAllSplitBills(page: Int, limit: Int, sortBy: String?, sortOrder: String?) -> AnyPublisher<SplitBillResponse, NetworkError>
	func getSplitBill(id: String) -> AnyPublisher<SingleSplitBillResponse, NetworkError>
	func searchSplitBills(query: String, page: Int, limit: Int) -> AnyPublisher<SplitBillResponse, NetworkError>
	func createSplitBill(_ request: CreateSplitBillRequest) -> AnyPublisher<SingleSplitBillResponse, NetworkError>
	func updateSplitBill(id: String, request: UpdateSplitBillRequest) -> AnyPublisher<SingleSplitBillResponse, NetworkError>
	func deleteSplitBill(id: String) -> AnyPublisher<Void, NetworkError>
	func settleSplitBill(id: String) -> AnyPublisher<SingleSplitBillResponse, NetworkError>
	func markParticipantPaid(billId: String, participantId: String, paid: Bool) -> AnyPublisher<SingleSplitBillResponse, NetworkError>
}

final class SplitBillAPIService: SplitBillAPIServiceProtocol {
	
	private let networkManager: NetworkManager
	
	init(networkManager: NetworkManager = NetworkManager.shared) {
		self.networkManager = networkManager
	}
	
	func getAllSplitBills(page: Int = 1, limit: Int = 20, sortBy: String? = "date", sortOrder: String? = "desc") -> AnyPublisher<SplitBillResponse, NetworkError> {
		let request = SplitBillAPIRequest.getAllSplitBills(page: page, limit: limit, sortBy: sortBy, sortOrder: sortOrder)
		return networkManager.execute(request: request, responseType: SplitBillResponse.self)
	}
	
	func getSplitBill(id: String) -> AnyPublisher<SingleSplitBillResponse, NetworkError> {
		let request = SplitBillAPIRequest.getSplitBill(id: id)
		return networkManager.execute(request: request, responseType: SingleSplitBillResponse.self)
	}
	
	func searchSplitBills(query: String, page: Int = 1, limit: Int = 20) -> AnyPublisher<SplitBillResponse, NetworkError> {
		let request = SplitBillAPIRequest.searchSplitBills(query: query, page: page, limit: limit)
		return networkManager.execute(request: request, responseType: SplitBillResponse.self)
	}
	
	func createSplitBill(_ request: CreateSplitBillRequest) -> AnyPublisher<SingleSplitBillResponse, NetworkError> {
		let apiRequest = SplitBillAPIRequest.createSplitBill(request)
		return networkManager.execute(request: apiRequest, responseType: SingleSplitBillResponse.self)
	}
	
	func updateSplitBill(id: String, request: UpdateSplitBillRequest) -> AnyPublisher<SingleSplitBillResponse, NetworkError> {
		let apiRequest = SplitBillAPIRequest.updateSplitBill(id: id, request)
		return networkManager.execute(request: apiRequest, responseType: SingleSplitBillResponse.self)
	}
	
	func deleteSplitBill(id: String) -> AnyPublisher<Void, NetworkError> {
		let request = SplitBillAPIRequest.deleteSplitBill(id: id)
		return networkManager.execute(request: request)
			.map { _ in () }
			.eraseToAnyPublisher()
	}
	
	func settleSplitBill(id: String) -> AnyPublisher<SingleSplitBillResponse, NetworkError> {
		let request = SplitBillAPIRequest.settleSplitBill(id: id)
		return networkManager.execute(request: request, responseType: SingleSplitBillResponse.self)
	}
	
	func markParticipantPaid(billId: String, participantId: String, paid: Bool) -> AnyPublisher<SingleSplitBillResponse, NetworkError> {
		let request = SplitBillAPIRequest.markParticipantPaid(billId: billId, participantId: participantId, paid: paid)
		return networkManager.execute(request: request, responseType: SingleSplitBillResponse.self)
	}
}

// MARK: - Auth Manager (Simple Implementation)

final class AuthManager {
	static let shared = AuthManager()
	
	private init() {}
	
	// In a real app, this would be stored securely in Keychain
	var authToken: String? {
		return UserDefaults.standard.string(forKey: "auth_token")
	}
	
	func setAuthToken(_ token: String) {
		UserDefaults.standard.set(token, forKey: "auth_token")
	}
	
	func clearAuthToken() {
		UserDefaults.standard.removeObject(forKey: "auth_token")
	}
}

// MARK: - Convenience Extensions

extension SplitBill {
	
	func toCreateRequest() -> CreateSplitBillRequest {
		return CreateSplitBillRequest(
			title: title,
			totalAmount: totalAmount,
			location: location,
			participants: participants.map { participant in
				CreateParticipantRequest(
					name: participant.name,
					email: participant.email,
					amountOwed: participant.amountOwed
				)
			},
			currency: currency,
			description: description
		)
	}
	
	func toUpdateRequest() -> UpdateSplitBillRequest {
		return UpdateSplitBillRequest(
			title: title,
			totalAmount: totalAmount,
			location: location,
			participants: participants.map { participant in
				UpdateParticipantRequest(
					id: participant.id,
					name: participant.name,
					email: participant.email,
					amountOwed: participant.amountOwed,
					hasPaid: participant.hasPaid
				)
			},
			currency: currency,
			description: description,
			isSettled: isSettled
		)
	}
}

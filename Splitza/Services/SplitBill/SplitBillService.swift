//
//  SplitBillAPIService.swift
//  Splitza
//
//  Created by Jeffry Sandy Purnomo on 10/08/25.
//

import Foundation
import RxSwift

// MARK: - Split Bill API Requests

enum SplitBillService {
	case getAllSplitBills(page: Int, limit: Int, sortBy: String?, sortOrder: String?)
	case getSplitBill(id: String)
	case searchSplitBills(query: String, page: Int, limit: Int)
	case createSplitBill(CreateSplitBillRequest)
	case updateSplitBill(id: String, UpdateSplitBillRequest)
	case deleteSplitBill(id: String)
	case settleSplitBill(id: String)
	case markParticipantPaid(billId: String, participantId: String, paid: Bool)
}

extension SplitBillService: NetworkRequest {
	
	var parameters: [String : Any]? {
		return nil
	}
	
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

protocol SplitBillAPIServiceable {
	func getAllSplitBills(page: Int, limit: Int, sortBy: String?, sortOrder: String?) -> Observable<SplitBillResponse>
	func getSplitBill(id: String) -> Observable<SingleSplitBillResponse>
	func searchSplitBills(query: String, page: Int, limit: Int) -> Observable<SplitBillResponse>
	func createSplitBill(_ request: CreateSplitBillRequest) -> Observable<SingleSplitBillResponse>
	func updateSplitBill(id: String, request: UpdateSplitBillRequest) -> Observable<SingleSplitBillResponse>
	func deleteSplitBill(id: String) -> Observable<Void>
	func settleSplitBill(id: String) -> Observable<SingleSplitBillResponse>
	func markParticipantPaid(billId: String, participantId: String, paid: Bool) -> Observable<SingleSplitBillResponse>
}

final class SplitBillAPIService: SplitBillAPIServiceable {
	
	private let networkManager: NetworkManager
	
	init(networkManager: NetworkManager = NetworkManager()) {
		self.networkManager = networkManager
	}
	
	func getAllSplitBills(page: Int = 1, limit: Int = 20, sortBy: String? = "date", sortOrder: String? = "desc") -> Observable<SplitBillResponse> {
		let request = SplitBillService.getAllSplitBills(page: page, limit: limit, sortBy: sortBy, sortOrder: sortOrder)
		
		// Add parameters directly to the request
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
		
		return networkManager.get(
			path: request.path,
			parameters: params,
			headers: request.headers,
			responseType: SplitBillResponse.self
		)
	}
	
	func getSplitBill(id: String) -> Observable<SingleSplitBillResponse> {
		let request = SplitBillService.getSplitBill(id: id)
		
		return networkManager.get(
			path: request.path,
			parameters: nil,
			headers: request.headers,
			responseType: SingleSplitBillResponse.self
		)
	}
	
	func searchSplitBills(query: String, page: Int = 1, limit: Int = 20) -> Observable<SplitBillResponse> {
		let request = SplitBillService.searchSplitBills(query: query, page: page, limit: limit)
		
		// Add search parameters directly
		let params: [String: Any] = [
			"query": query,
			"page": page,
			"limit": limit
		]
		
		return networkManager.get(
			path: request.path,
			parameters: params,
			headers: request.headers,
			responseType: SplitBillResponse.self
		)
	}
	
	func createSplitBill(_ request: CreateSplitBillRequest) -> Observable<SingleSplitBillResponse> {
		let apiRequest = SplitBillService.createSplitBill(request)
		
		return networkManager.post(
			path: apiRequest.path,
			body: request,
			headers: apiRequest.headers,
			responseType: SingleSplitBillResponse.self
		)
	}
	
	func updateSplitBill(id: String, request: UpdateSplitBillRequest) -> Observable<SingleSplitBillResponse> {
		let apiRequest = SplitBillService.updateSplitBill(id: id, request)
		
		return networkManager.put(
			path: apiRequest.path,
			body: request,
			headers: apiRequest.headers,
			responseType: SingleSplitBillResponse.self
		)
	}
	
	func deleteSplitBill(id: String) -> Observable<Void> {
		let request = SplitBillService.deleteSplitBill(id: id)
		
		return networkManager.delete(
			path: request.path,
			headers: request.headers,
			responseType: EmptyResponse.self
		)
		.map { _ in () }
	}
	
	func settleSplitBill(id: String) -> Observable<SingleSplitBillResponse> {
		let request = SplitBillService.settleSplitBill(id: id)
		
		return networkManager.put(
			path: request.path,
			body: EmptyRequest(),
			headers: request.headers,
			responseType: SingleSplitBillResponse.self
		)
	}
	
	func markParticipantPaid(billId: String, participantId: String, paid: Bool) -> Observable<SingleSplitBillResponse> {
		let request = SplitBillService.markParticipantPaid(billId: billId, participantId: participantId, paid: paid)
		
		// Create request body with paid status
		let body = ["paid": paid]
		
		return networkManager.put(
			path: request.path,
			body: body,
			headers: request.headers,
			responseType: SingleSplitBillResponse.self
		)
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

// MARK: - Helper Structs

struct EmptyRequest: Codable {}

struct EmptyResponse: Codable {}

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

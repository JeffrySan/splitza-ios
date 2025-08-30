//
//  NetworkError.swift
//  Splitza
//
//  Created by Jeffry Sandy Purnomo on 10/08/25.
//

import Foundation

enum NetworkError: LocalizedError, Equatable {
	case invalidURL
	case noData
	case decodingError
	case serverError(Int)
	case networkUnavailable
	case timeout
	case unauthorized
	case forbidden
	case notFound
	case selfDeallocated
	case notImplemented
	case unknown(Error)
	
	var errorDescription: String? {
		switch self {
		case .invalidURL:
			return "Invalid URL"
		case .noData:
			return "No data received"
		case .decodingError:
			return "Failed to decode response"
		case .serverError(let code):
			return "Server error with code: \(code)"
		case .networkUnavailable:
			return "Network unavailable"
		case .timeout:
			return "Request timeout"
		case .unauthorized:
			return "Unauthorized access"
		case .forbidden:
			return "Access forbidden"
		case .notFound:
			return "Resource not found"
		case .selfDeallocated:
			return "Object deallocated"
		case .notImplemented:
			return "Feature not implemented"
		case .unknown(let error):
			return error.localizedDescription
		}
	}
	
	static func == (lhs: NetworkError, rhs: NetworkError) -> Bool {
		switch (lhs, rhs) {
		case (.invalidURL, .invalidURL),
			(.noData, .noData),
			(.decodingError, .decodingError),
			(.networkUnavailable, .networkUnavailable),
			(.timeout, .timeout),
			(.unauthorized, .unauthorized),
			(.forbidden, .forbidden),
			(.notFound, .notFound),
			(.selfDeallocated, .selfDeallocated):
			return true
		case (.serverError(let lhsCode), .serverError(let rhsCode)):
			return lhsCode == rhsCode
		case (.unknown(let lhsError), .unknown(let rhsError)):
			return lhsError.localizedDescription == rhsError.localizedDescription
		default:
			return false
		}
	}
}

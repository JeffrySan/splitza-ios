//
//  NetworkError.swift
//  Splitza
//
//  Created by Jeffry Sandy Purnomo on 26/09/25.
//

import Foundation

enum NetworkError: AppError, LocalizedError, Equatable {
	
	case invalidURL
	case noData
	case decodingError
	case serverError(statusCode: Int)
	case networkUnavailable
	case timeout
	case unauthorized
	case forbidden
	case notFound
	case selfDeallocated
	case notImplemented
	case unknown(Error)
	case requestTimeout
	case noInternetConnection

	// MARK: - AppError Protocol Conformance

	var userMessage: String {
		switch self {
		case .invalidURL:
			return "Invalid URL"
		case .noData:
			return "No data received"
		case .decodingError:
			return "Failed to decode response"
		case .serverError:
			return "The server encountered an error. Please try again later."
		case .networkUnavailable:
			return "Network unavailable"
		case .timeout, .requestTimeout:
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
		case .unknown:
			return "An unknown network error occurred. Please try again."
		case .noInternetConnection:
			return "No internet connection. Please check your network and try again."
		}
	}

	var debugMessage: String {
		switch self {
		case .invalidURL:
			return "The URL provided was invalid."
		case .noData:
			return "No data was returned from the server."
		case .decodingError:
			return "Failed to decode the server response."
		case .serverError(let statusCode):
			return "The server returned an error with status code \(statusCode)."
		case .networkUnavailable:
			return "The network is currently unavailable."
		case .timeout, .requestTimeout:
			return "The request took too long to complete."
		case .unauthorized:
			return "The request was unauthorized."
		case .forbidden:
			return "Access to the resource is forbidden."
		case .notFound:
			return "The requested resource was not found."
		case .selfDeallocated:
			return "The object was deallocated before the operation completed."
		case .notImplemented:
			return "This feature is not implemented."
		case .unknown(let error):
			return error.localizedDescription
		case .noInternetConnection:
			return "The device is not connected to the internet."
		}
	}

	var errorCode: String? {
		switch self {
		case .invalidURL: return "invalid_url"
		case .noData: return "no_data"
		case .decodingError: return "decoding_error"
		case .serverError(let statusCode): return "server_error_\(statusCode)"
		case .networkUnavailable: return "network_unavailable"
		case .timeout, .requestTimeout: return "timeout"
		case .unauthorized: return "unauthorized"
		case .forbidden: return "forbidden"
		case .notFound: return "not_found"
		case .selfDeallocated: return "self_deallocated"
		case .notImplemented: return "not_implemented"
		case .unknown: return "unknown"
		case .noInternetConnection: return "no_internet"
		}
	}

	// MARK: - Equatable Conformance

	static func == (lhs: NetworkError, rhs: NetworkError) -> Bool {
		switch (lhs, rhs) {
		case (.invalidURL, .invalidURL),
			(.noData, .noData),
			(.decodingError, .decodingError),
			(.networkUnavailable, .networkUnavailable),
			(.timeout, .timeout),
			(.requestTimeout, .requestTimeout),
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

//
//  SplitBillError.swift
//  Splitza
//
//  Created by Jeffry Sandy Purnomo on 27/09/25.
//

import Foundation

enum SplitBillError: AppError {
	case splitBillNotFound
	case networkError(Error)
	case cacheError(Error)
	case syncError(Error)
	case databaseError(Error)
	case invalidData
	case operationFailed
	
	// MARK: - AppError Protocol Conformance
	
	var userMessage: String {
		switch self {
		case .splitBillNotFound:
			return "Split bill not found"
		case .networkError:
			return "Network error occurred. Please check your connection and try again."
		case .cacheError:
			return "Failed to save data locally. Please try again."
		case .syncError:
			return "Failed to sync with server. Your changes have been saved locally."
		case .databaseError:
			return "Database error occurred. Please try again."
		case .invalidData:
			return "Invalid data provided. Please check your input and try again."
		case .operationFailed:
			return "Operation failed. Please try again."
		}
	}
	
	var debugMessage: String {
		switch self {
		case .splitBillNotFound:
			return "The requested split bill could not be found in the data source."
		case .networkError(let error):
			return "Network error: \(error.localizedDescription)"
		case .cacheError(let error):
			return "Cache error: \(error.localizedDescription)"
		case .syncError(let error):
			return "Sync error: \(error.localizedDescription)"
		case .databaseError(let error):
			return "Database error: \(error.localizedDescription)"
		case .invalidData:
			return "The provided data is invalid or corrupted."
		case .operationFailed:
			return "The requested operation could not be completed."
		}
	}
	
	var errorCode: String? {
		switch self {
		case .splitBillNotFound: return "split_bill_not_found"
		case .networkError: return "network_error"
		case .cacheError: return "cache_error"
		case .syncError: return "sync_error"
		case .databaseError: return "database_error"
		case .invalidData: return "invalid_data"
		case .operationFailed: return "operation_failed"
		}
	}
}
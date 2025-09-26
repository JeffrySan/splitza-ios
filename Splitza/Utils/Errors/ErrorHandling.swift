//
//  ErrorHandling.swift
//  Splitza
//
//  Created by Jeffry Sandy Purnomo on 26/09/25.
//

protocol AppError: Error {
	/// A user-friendly message for the error
	var userMessage: String { get }
	
	/// A developer-friendly debug message for logging
	var debugMessage: String { get }
	
	/// An optional error code (e.g., from the server)
	var errorCode: String? { get }
}

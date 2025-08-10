//
//  NetworkRequest.swift
//  Splitza
//
//  Created by Jeffry Sandy Purnomo on 10/08/25.
//

import Foundation

protocol NetworkRequest {
	var baseURL: String { get }
	var path: String { get }
	var method: HTTPMethod { get }
	var headers: [String: String]? { get }
	var parameters: [String: Any]? { get }
	var body: Data? { get }
	var timeoutInterval: TimeInterval { get }
}

extension NetworkRequest {
	var baseURL: String {
		return "https://api.splitza.com" // Replace with your actual API base URL
	}
	
	var headers: [String: String]? {
		return [
			"Content-Type": "application/json",
			"Accept": "application/json"
		]
	}
	
	var parameters: [String: Any]? {
		return nil
	}
	
	var body: Data? {
		return nil
	}
	
	var timeoutInterval: TimeInterval {
		return 30.0
	}
}

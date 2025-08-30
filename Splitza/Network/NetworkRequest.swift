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

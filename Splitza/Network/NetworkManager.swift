//
//  NetworkManager.swift
//  Splitza
//
//  Created by Jeffry Sandy Purnomo on 10/08/25.
//

import Foundation
import RxSwift
import RxCocoa

// MARK: - HTTPMethod
enum HTTPMethod: String {
	case GET = "GET"
	case POST = "POST"
	case PUT = "PUT"
	case DELETE = "DELETE"
	case PATCH = "PATCH"
}

// MARK: - NetworkManager

final class NetworkManager {
	
	private let session: URLSession
	private let decoder: JSONDecoder
	private let encoder: JSONEncoder
	
	init() {
		let configuration = URLSessionConfiguration.default
		configuration.timeoutIntervalForRequest = 30.0
		configuration.timeoutIntervalForResource = 60.0
		configuration.waitsForConnectivity = true
		
		self.session = URLSession(configuration: configuration)
		self.decoder = JSONDecoder()
		self.encoder = JSONEncoder()
		
		// Configure date decoding strategy
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'"
		decoder.dateDecodingStrategy = .formatted(dateFormatter)
		
		// Configure date encoding strategy
		encoder.dateEncodingStrategy = .formatted(dateFormatter)
	}
	
	// MARK: - Generic Request Methods
	
	func execute<T: Codable>(
		request: NetworkRequest,
		responseType: T.Type
	) -> Observable<T> {
		
		guard let urlRequest = buildURLRequest(from: request) else {
			return Observable.error(NetworkError.invalidURL)
		}
		
		return session.rx.response(request: urlRequest)
			.map { [weak self] response, data in
				try self?.handleResponse(data: data, response: response) ?? data
			}
			.map { data in
				try self.decoder.decode(T.self, from: data)
			}
			.catch { error in
				Observable.error(self.mapError(error))
			}
			.observe(on: MainScheduler.instance)
	}
	
	func execute(request: NetworkRequest) -> Observable<Data> {
		guard let urlRequest = buildURLRequest(from: request) else {
			return Observable.error(NetworkError.invalidURL)
		}
		
		return session.rx.response(request: urlRequest)
			.map { [weak self] response, data in
				try self?.handleResponse(data: data, response: response) ?? data
			}
			.catch { error in
				Observable.error(self.mapError(error))
			}
			.observe(on: MainScheduler.instance)
	}
	
	// MARK: - Private Methods
	
	private func buildURLRequest(from request: NetworkRequest) -> URLRequest? {
		var urlComponents = URLComponents(string: request.baseURL + request.path)
		
		// Add query parameters for GET requests
		if request.method == .GET, let parameters = request.parameters {
			urlComponents?.queryItems = parameters.map { key, value in
				URLQueryItem(name: key, value: "\(value)")
			}
		}
		
		guard let url = urlComponents?.url else {
			return nil
		}
		
		var urlRequest = URLRequest(url: url)
		urlRequest.httpMethod = request.method.rawValue
		urlRequest.timeoutInterval = request.timeoutInterval
		
		// Add headers
		request.headers?.forEach { key, value in
			urlRequest.setValue(value, forHTTPHeaderField: key)
		}
		
		// Add body for non-GET requests
		if request.method != .GET {
			if let body = request.body {
				urlRequest.httpBody = body
			} else if let parameters = request.parameters {
				urlRequest.httpBody = try? JSONSerialization.data(withJSONObject: parameters)
			}
		}
		
		return urlRequest
	}
	
	private func handleResponse(data: Data, response: URLResponse) throws -> Data {
		guard let httpResponse = response as? HTTPURLResponse else {
			throw NetworkError.unknown(NSError(domain: "Invalid response", code: 0))
		}
		
		switch httpResponse.statusCode {
		case 200...299:
			return data
		case 400:
			throw NetworkError.decodingError
		case 401:
			throw NetworkError.unauthorized
		case 403:
			throw NetworkError.forbidden
		case 404:
			throw NetworkError.notFound
		case 408:
			throw NetworkError.timeout
		case 500...599:
			throw NetworkError.serverError(statusCode: httpResponse.statusCode)
		default:
			throw NetworkError.unknown(NSError(domain: "HTTP Error", code: httpResponse.statusCode))
		}
	}
	
	private func mapError(_ error: Error) -> NetworkError {
		if let networkError = error as? NetworkError {
			return networkError
		}
		
		if error is DecodingError {
			return .decodingError
		}
		
		let nsError = error as NSError
		
		switch nsError.code {
		case NSURLErrorNotConnectedToInternet,
		NSURLErrorNetworkConnectionLost:
			return .networkUnavailable
		case NSURLErrorTimedOut:
			return .timeout
		case NSURLErrorBadURL:
			return .invalidURL
		default:
			return .unknown(error)
		}
	}
}

// MARK: - Convenience Methods

extension NetworkManager {
	
	// MARK: - RxSwift Methods (Legacy)
	
	func get<T: Codable>(
		path: String,
		parameters: [String: Any]? = nil,
		headers: [String: String]? = nil,
		responseType: T.Type
	) -> Observable<T> {
		
		let request = GenericNetworkRequest(
			path: path,
			method: .GET,
			headers: headers,
			parameters: parameters
		)
		
		return execute(request: request, responseType: responseType)
	}
	
	func post<T: Codable, Body: Encodable>(
		path: String,
		body: Body? = nil,
		headers: [String: String]? = nil,
		responseType: T.Type
	) -> Observable<T> {
		
		let bodyData: Data?
		if let body = body {
			bodyData = try? encoder.encode(body)
		} else {
			bodyData = nil
		}
		
		let request = GenericNetworkRequest(
			path: path,
			method: .POST,
			headers: headers,
			body: bodyData
		)
		
		return execute(request: request, responseType: responseType)
	}
	
	func put<T: Codable, Body: Encodable>(
		path: String,
		body: Body? = nil,
		headers: [String: String]? = nil,
		responseType: T.Type
	) -> Observable<T> {
		
		let bodyData: Data?
		if let body = body {
			bodyData = try? encoder.encode(body)
		} else {
			bodyData = nil
		}
		
		let request = GenericNetworkRequest(
			path: path,
			method: .PUT,
			headers: headers,
			body: bodyData
		)
		
		return execute(request: request, responseType: responseType)
	}
	
	func delete<T: Codable>(
		path: String,
		headers: [String: String]? = nil,
		responseType: T.Type
	) -> Observable<T> {
		
		let request = GenericNetworkRequest(
			path: path,
			method: .DELETE,
			headers: headers
		)
		
		return execute(request: request, responseType: responseType)
	}
	
	// MARK: - Async/Await Methods
	
	func get<T: Codable>(
		path: String,
		parameters: [String: Any]? = nil,
		headers: [String: String]? = nil,
		responseType: T.Type
	) async throws -> T {
		
		let request = GenericNetworkRequest(
			path: path,
			method: .GET,
			headers: headers,
			parameters: parameters
		)
		
		return try await executeAsync(request: request, responseType: responseType)
	}
	
	func post<T: Codable, Body: Encodable>(
		path: String,
		body: Body? = nil,
		headers: [String: String]? = nil,
		responseType: T.Type
	) async throws -> T {
		
		let bodyData: Data?
		if let body = body {
			bodyData = try? encoder.encode(body)
		} else {
			bodyData = nil
		}
		
		let request = GenericNetworkRequest(
			path: path,
			method: .POST,
			headers: headers,
			body: bodyData
		)
		
		return try await executeAsync(request: request, responseType: responseType)
	}
	
	func put<T: Codable, Body: Encodable>(
		path: String,
		body: Body? = nil,
		headers: [String: String]? = nil,
		responseType: T.Type
	) async throws -> T {
		
		let bodyData: Data?
		if let body = body {
			bodyData = try? encoder.encode(body)
		} else {
			bodyData = nil
		}
		
		let request = GenericNetworkRequest(
			path: path,
			method: .PUT,
			headers: headers,
			body: bodyData
		)
		
		return try await executeAsync(request: request, responseType: responseType)
	}
	
	func delete<T: Codable>(
		path: String,
		headers: [String: String]? = nil,
		responseType: T.Type
	) async throws -> T {
		
		let request = GenericNetworkRequest(
			path: path,
			method: .DELETE,
			headers: headers
		)
		
		return try await executeAsync(request: request, responseType: responseType)
	}
	
	// MARK: - Private Async Helper
	
	private func executeAsync<T: Codable>(
		request: NetworkRequest,
		responseType: T.Type
	) async throws -> T {
		
		guard let urlRequest = buildURLRequest(from: request) else {
			throw NetworkError.invalidURL
		}
		
		do {
			let (data, response) = try await session.data(for: urlRequest)
			let validatedData = try handleResponse(data: data, response: response)
			return try decoder.decode(responseType, from: validatedData)
		} catch {
			throw mapError(error)
		}
	}
}

// MARK: - Generic Network Request

private struct GenericNetworkRequest: NetworkRequest {
	
	var baseURL: String
	let path: String
	let method: HTTPMethod
	let headers: [String: String]?
	let parameters: [String: Any]?
	let body: Data?
	let timeoutInterval: TimeInterval
	
	init(
		path: String,
		method: HTTPMethod,
		headers: [String: String]? = nil,
		parameters: [String: Any]? = nil,
		body: Data? = nil,
		timeoutInterval: TimeInterval = 30.0
	) {
		self.baseURL = NetworkConfiguration.shared.baseURL
		self.path = path
		self.method = method
		self.headers = headers
		self.parameters = parameters
		self.body = body
		self.timeoutInterval = timeoutInterval
	}
}

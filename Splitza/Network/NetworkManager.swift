//
//  NetworkManager.swift
//  Splitza
//
//  Created by Jeffry Sandy Purnomo on 10/08/25.
//

import Foundation
import Combine

// MARK: - NetworkError

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
		case .unknown(let error):
			return "Unknown error: \(error.localizedDescription)"
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
			(.notFound, .notFound):
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

// MARK: - HTTPMethod

enum HTTPMethod: String {
	case GET = "GET"
	case POST = "POST"
	case PUT = "PUT"
	case DELETE = "DELETE"
	case PATCH = "PATCH"
}

// MARK: - NetworkRequest

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

// MARK: - NetworkManager

final class NetworkManager {
	static let shared = NetworkManager()
	
	private let session: URLSession
	private let decoder: JSONDecoder
	private let encoder: JSONEncoder
	
	private init() {
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
	) -> AnyPublisher<T, NetworkError> {
		
		guard let urlRequest = buildURLRequest(from: request) else {
			return Fail(error: NetworkError.invalidURL)
				.eraseToAnyPublisher()
		}
		
		return session.dataTaskPublisher(for: urlRequest)
			.tryMap { [weak self] data, response in
				try self?.handleResponse(data: data, response: response) ?? data
			}
			.decode(type: T.self, decoder: decoder)
			.mapError { error in
				self.mapError(error)
			}
			.receive(on: DispatchQueue.main)
			.eraseToAnyPublisher()
	}
	
	func execute(request: NetworkRequest) -> AnyPublisher<Data, NetworkError> {
		guard let urlRequest = buildURLRequest(from: request) else {
			return Fail(error: NetworkError.invalidURL)
				.eraseToAnyPublisher()
		}
		
		return session.dataTaskPublisher(for: urlRequest)
			.tryMap { [weak self] data, response in
				try self?.handleResponse(data: data, response: response) ?? data
			}
			.mapError { error in
				self.mapError(error)
			}
			.receive(on: DispatchQueue.main)
			.eraseToAnyPublisher()
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
			throw NetworkError.serverError(httpResponse.statusCode)
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
	
	func get<T: Codable>(
		path: String,
		parameters: [String: Any]? = nil,
		headers: [String: String]? = nil,
		responseType: T.Type
	) -> AnyPublisher<T, NetworkError> {
		
		let request = GenericNetworkRequest(
			path: path,
			method: .GET,
			headers: headers,
			parameters: parameters
		)
		
		return execute(request: request, responseType: responseType)
	}
	
	func post<T: Codable>(
		path: String,
		body: Encodable? = nil,
		headers: [String: String]? = nil,
		responseType: T.Type
	) -> AnyPublisher<T, NetworkError> {
		
		let bodyData = try? encoder.encode(AnyEncodable(body))
		
		let request = GenericNetworkRequest(
			path: path,
			method: .POST,
			headers: headers,
			body: bodyData
		)
		
		return execute(request: request, responseType: responseType)
	}
	
	func put<T: Codable>(
		path: String,
		body: Encodable? = nil,
		headers: [String: String]? = nil,
		responseType: T.Type
	) -> AnyPublisher<T, NetworkError> {
		
		let bodyData = try? encoder.encode(AnyEncodable(body))
		
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
	) -> AnyPublisher<T, NetworkError> {
		
		let request = GenericNetworkRequest(
			path: path,
			method: .DELETE,
			headers: headers
		)
		
		return execute(request: request, responseType: responseType)
	}
}

// MARK: - Generic Network Request

private struct GenericNetworkRequest: NetworkRequest {
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
		self.path = path
		self.method = method
		self.headers = headers
		self.parameters = parameters
		self.body = body
		self.timeoutInterval = timeoutInterval
	}
}

// MARK: - AnyEncodable Helper

private struct AnyEncodable: Encodable {
	private let _encode: (Encoder) throws -> Void
	
	init<T: Encodable>(_ wrapped: T?) {
		if let wrapped = wrapped {
			_encode = wrapped.encode
		} else {
			_encode = { _ in }
		}
	}
	
	func encode(to encoder: Encoder) throws {
		try _encode(encoder)
	}
}

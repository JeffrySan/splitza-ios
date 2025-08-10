//
//  NetworkConfiguration.swift
//  Splitza
//
//  Created by Jeffry Sandy Purnomo on 10/08/25.
//

import Foundation

// MARK: - Environment Configuration

enum AppEnvironment {
	case development
	case staging
	case production
}

// MARK: - Network Configuration

struct NetworkConfiguration {
	
	static let shared = NetworkConfiguration()
	
	private init() {}
	
	// MARK: - Current Environment
	
#if DEBUG
	static let currentEnvironment: AppEnvironment = .development
#else
	static let currentEnvironment: AppEnvironment = .production
#endif
	
	// MARK: - Base URLs
	
	var baseURL: String {
		switch Self.currentEnvironment {
		case .development:
			return "https://api-dev.splitza.com"
		case .staging:
			return "https://api-staging.splitza.com"
		case .production:
			return "https://api.splitza.com"
		}
	}
	
	// MARK: - API Endpoints
	
	struct Endpoints {
		static let splitBills = "/api/v1/split-bills"
		static let auth = "/api/v1/auth"
		static let users = "/api/v1/users"
		static let search = "/api/v1/search"
	}
	
	// MARK: - Configuration Flags
	
	var isNetworkingEnabled: Bool {
		// For demo purposes, we can disable networking
		// In a real app, this might depend on user settings or feature flags
		return UserDefaults.standard.bool(forKey: "networking_enabled")
	}
	
	var shouldUseHybridMode: Bool {
		return UserDefaults.standard.bool(forKey: "hybrid_mode_enabled")
	}
	
	var requestTimeout: TimeInterval {
		switch Self.currentEnvironment {
		case .development:
			return 60.0 // Longer timeout for development
		case .staging, .production:
			return 30.0
		}
	}
	
	// MARK: - Data Source Strategy
	
	var dataSourceType: SplitBillRepository.DataSourceType {
		if !isNetworkingEnabled {
			return .local
		}
		
		if shouldUseHybridMode {
			return .hybrid
		}
		
		return .remote
	}
	
	// MARK: - API Keys and Headers
	
	var defaultHeaders: [String: String] {
		var headers = [
			"Content-Type": "application/json",
			"Accept": "application/json",
			"User-Agent": "Splitza-iOS/\(appVersion)"
		]
		
		if let apiKey = apiKey {
			headers["X-API-Key"] = apiKey
		}
		
		return headers
	}
	
	private var apiKey: String? {
		// In a real app, this would come from a secure configuration
		switch Self.currentEnvironment {
		case .development:
			return "dev_api_key_12345"
		case .staging:
			return "staging_api_key_67890"
		case .production:
			return Bundle.main.object(forInfoDictionaryKey: "API_KEY") as? String
		}
	}
	
	private var appVersion: String {
		return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0.0"
	}
}

// MARK: - Network Monitoring

import Network
import RxSwift
import RxRelay

final class NetworkMonitor {
	
	static let shared = NetworkMonitor()
	
	private let monitor = NWPathMonitor()
	private let queue = DispatchQueue(label: "NetworkMonitor")
	
	private let isConnectedRelay = BehaviorRelay<Bool>(value: false)
	private let connectionTypeRelay = BehaviorRelay<ConnectionType>(value: .unknown)
	
	var isConnected: Observable<Bool> {
		return isConnectedRelay.asObservable()
	}
	
	var connectionType: Observable<ConnectionType> {
		return connectionTypeRelay.asObservable()
	}
	
	enum ConnectionType {
		case wifi
		case cellular
		case ethernet
		case unknown
	}
	
	private init() {
		startMonitoring()
	}
	
	private func startMonitoring() {
		monitor.pathUpdateHandler = { [weak self] path in
			DispatchQueue.main.async {
				self?.isConnectedRelay.accept(path.status == .satisfied)
				self?.updateConnectionType(path)
			}
		}
		monitor.start(queue: queue)
	}
	
	private func updateConnectionType(_ path: NWPath) {
		if path.usesInterfaceType(.wifi) {
			connectionTypeRelay.accept(.wifi)
		} else if path.usesInterfaceType(.cellular) {
			connectionTypeRelay.accept(.cellular)
		} else if path.usesInterfaceType(.wiredEthernet) {
			connectionTypeRelay.accept(.ethernet)
		} else {
			connectionTypeRelay.accept(.unknown)
		}
	}
	
	deinit {
		monitor.cancel()
	}
}

// MARK: - Configuration Extensions

extension NetworkConfiguration {
	
	// MARK: - Development Helpers
	
	func enableNetworking() {
		UserDefaults.standard.set(true, forKey: "networking_enabled")
	}
	
	func disableNetworking() {
		UserDefaults.standard.set(false, forKey: "networking_enabled")
	}
	
	func enableHybridMode() {
		UserDefaults.standard.set(true, forKey: "hybrid_mode_enabled")
	}
	
	func disableHybridMode() {
		UserDefaults.standard.set(false, forKey: "hybrid_mode_enabled")
	}
	
	// MARK: - URL Building
	
	func buildURL(path: String, queryParams: [String: String]? = nil) -> URL? {
		var components = URLComponents(string: baseURL + path)
		
		if let queryParams = queryParams {
			components?.queryItems = queryParams.map { key, value in
				URLQueryItem(name: key, value: value)
			}
		}
		
		return components?.url
	}
}

// MARK: - Mock Configuration for Testing

#if DEBUG
extension NetworkConfiguration {
	
	static func mockConfiguration(
		environment: AppEnvironment = .development,
		networkingEnabled: Bool = false,
		hybridMode: Bool = false
	) -> NetworkConfiguration {
		let config = NetworkConfiguration.shared
		
		if networkingEnabled {
			config.enableNetworking()
		} else {
			config.disableNetworking()
		}
		
		if hybridMode {
			config.enableHybridMode()
		} else {
			config.disableHybridMode()
		}
		
		return config
	}
}
#endif

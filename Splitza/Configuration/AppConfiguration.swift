//
//  AppConfiguration.swift
//  Splitza
//
//  Created by Jeffry Sandy Purnomo on 21/09/25.
//

import Foundation

enum Environment: String {
	case local
	case development
	case testing
	case staging
	case production
	
	static var current: Environment {
		return getEnvironment()
	}
	
	private static func getEnvironment() -> Environment {
		// First check for scheme environment variable
		if let envString = ProcessInfo.processInfo.environment["ENVIRONMENT"],
		   let environment = Environment(rawValue: envString) {
			return environment
		}
		
		return .local
	}
}

struct AppConfiguration {
	static let current: Environment = {
		return Environment.current
	}()
	
	static var baseURL: String {
		switch current {
		case .local:
			return "http://localhost:3000"
		case .development:
			return "https://malcom-tariffless-riskily.ngrok-free.dev"
		case .testing:
			return "https://snelzienvcjsncoxjgok.supabase.co"
		case .staging:
			return "https://staging-api.splitza.com"
		case .production:
			return "https://snelzienvcjsncoxjgok.supabase.co"
		}
	}
	
	static var supabaseAnonKey: String {
		switch current {
		case .local:
			return ""
		case .development:
			return ((Bundle.main.infoDictionary?["SUPABASE_DEV_ANON_KEY"] as? String) ?? "-")
		case .testing:
			return ((Bundle.main.infoDictionary?["SUPABASE_ANON_KEY"] as? String) ?? "-")
		case .staging:
			return "https://staging-api.splitza.com"
		case .production:
			return ((Bundle.main.infoDictionary?["SUPABASE_ANON_KEY"] as? String) ?? "-")
		}
	}
}

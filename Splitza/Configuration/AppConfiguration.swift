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
		#if DEBUG
		return getDebugEnvironment()
		#else
		return getReleaseEnvironment()
		#endif
	}
	
	private static func getDebugEnvironment() -> Environment {
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
			return "https://dev-api.splitza.com"
		case .testing:
			return "https://test-api.splitza.com"
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
			return "-"
		case .testing:
			return "https://test-api.splitza.com"
		case .staging:
			return "https://staging-api.splitza.com"
		case .production:
			return "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNuZWx6aWVudmNqc25jb3hqZ29rIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1MzA3NTExNiwiZXhwIjoyMDY4NjUxMTE2fQ.murmB5lKurlrZ5nj-JXoKOkIIQ4XtIAIAcA26zioFUk"
		}
	}
}

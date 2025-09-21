//
//  SupabaseManager.swift
//  Splitza
//
//  Created by Jeffry Sandy Purnomo on 21/09/25.
//

import Supabase
import Foundation

final class SupabaseManager {
	
	static let shared = SupabaseManager()
	
	let client: SupabaseClient
	
	private init() {
		// Replace these with your Supabase project URL and anon key
		let urlString = AppConfiguration.baseURL
		let key = AppConfiguration.supabaseAnonKey
		
		client = SupabaseClient(supabaseURL: URL(string: urlString)!, supabaseKey: key)
	}
}

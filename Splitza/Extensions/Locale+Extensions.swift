//
//  Locale+Extensions.swift
//  Splitza
//
//  Created by Jeffry Sandy Purnomo on 31/08/25.
//

import Foundation

extension Locale {
	var resolvedCurrencySymbol: String? {
		let formatter = NumberFormatter()
		formatter.numberStyle = .currency
		formatter.locale = self
		return formatter.currencySymbol
	}
}

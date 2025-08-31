//
//  Int+Extensions.swift
//  Splitza
//
//  Created by Jeffry Sandy Purnomo on 31/08/25.
//

import Foundation

extension Double {
	
	func formattedCurrency(currencyCode: String)-> String {
		let formatter = NumberFormatter()
		formatter.numberStyle = .currency
		formatter.currencyCode = currencyCode
		return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
	}
}

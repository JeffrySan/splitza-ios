//
//  String+Extensions.swift
//  Splitza
//
//  Created by Jeffry Sandy Purnomo on 31/08/25.
//

extension String {
	
	var currencySymbol: String {
		switch self {
		case "USD": return "$"
		case "EUR": return "€"
		case "GBP": return "£"
		case "JPY": return "¥"
		case "IDR": return "Rp"
		default: return "-"
		}
	}
}

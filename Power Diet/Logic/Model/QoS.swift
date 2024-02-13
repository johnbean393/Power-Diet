//
//  QoS.swift
//  Power Diet
//
//  Created by Bean John on 9/2/2024.
//

import Foundation

enum QoS: String, CaseIterable, Codable {
	
	case auto
	case userInteractive
	case userInitiated
	case utility
	case background
	
	static var presentedCases: [QoS] {
		let filtered: [QoS] = [.utility, .userInitiated, .userInteractive]
		return QoS.allCases.filter({ !filtered.contains($0) })
	}
	
}

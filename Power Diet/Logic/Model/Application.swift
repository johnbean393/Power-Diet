//
//  Application.swift
//  Power Diet
//
//  Created by Bean John on 9/2/2024.
//

import Foundation
import BezelNotification
import AppKit

struct Application: Identifiable, Codable, Equatable, Hashable {
	
	var id: UUID = UUID()
	
	var url: URL
	
	var execUrl: URL {
		let execName: String = url.deletingPathExtension().lastPathComponent
		return url.appendingPathComponent("Contents").appendingPathComponent("MacOS").appendingPathComponent(execName)
	}
	
	var isHelper: Bool
	
	var name: String {
		return url.deletingPathExtension().lastPathComponent
	}
	
	var qoS: QoS
	
	var isRunning: Bool
	
	var runningApplication: NSRunningApplication? {
		// Get list of running apps
		let runningApps: [NSRunningApplication] = NSWorkspace.shared.runningApplications
		// Check for app in running apps
		for app in runningApps {
			// If match, return object
			if let bundleUrl: URL = app.bundleURL {
				if bundleUrl == url {
					return app
				}
			}
		}
		// Else, return nil
		return nil
	}
	
	func launchWithQoS(completion: () -> Void) {
		// Init process with params
		let process: Process = Process()
		process.qualityOfService = {
			switch qoS {
				case .auto:
					return .default
				case .userInteractive:
					return .userInteractive
				case .userInitiated:
					return .userInitiated
				case .utility:
					return .utility
				case .background:
					return .background
			}
		}()
		process.executableURL = execUrl
		// Run app
		try? process.run()
		// Run completion handler
		completion()
	}
	
	func quit() {
		runningApplication!.terminate()
	}

}

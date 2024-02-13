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
	
	var execUrl: URL? {
		do {
			let execDir: URL = url.appendingPathComponent("Contents").appendingPathComponent("MacOS")
			let appLayers: Int = Int((url.posixPath().count - url.posixPath().replacingOccurrences(of: ".app", with: "").count) / 4)
			if execDir.fileExists() {
				// Return executable url if exists
				let execName: String = url.deletingPathExtension().lastPathComponent
				if execDir.appendingPathComponent(execName).fileExists() {
					return execDir.appendingPathComponent(execName)
				} else {
					// Else, get correct url
					let execDirContents: [URL] = try FileManager.default.contentsOfDirectory(atPath: execDir.posixPath()).map({
						execDir.appendingPathComponent($0)
					})
					if let execUrl = execDirContents.filter({
						FileManager.default.isExecutableFile(atPath: $0.posixPath())
						&& $0.pathExtension == ""
						&& $0.lastPathComponent != "_CodeSignature"
						&& ($0.posixPath().count - $0.posixPath().replacingOccurrences(of: ".app", with: "").count) == appLayers * 4
					}).first {
						return execUrl
					}
				}
			} else {
				// List all files in directory
				let packageContents: [URL] = try url.listDirectory()
				print(packageContents.filter({
					FileManager.default.isExecutableFile(atPath: $0.posixPath())
					&& $0.pathExtension == ""
					&& $0.lastPathComponent != "_CodeSignature"
					&& ($0.posixPath().count - $0.posixPath().replacingOccurrences(of: ".app", with: "").count) == appLayers * 4
				}))
				if let execUrl = packageContents.filter({
					FileManager.default.isExecutableFile(atPath: $0.posixPath())
					&& $0.pathExtension == ""
					&& $0.lastPathComponent != "_CodeSignature"
					&& ($0.posixPath().count - $0.posixPath().replacingOccurrences(of: ".app", with: "").count) == appLayers * 4
				}).first {
					return execUrl
				}
			}
		} catch {
			return nil
		}
		return nil
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
	
	func launchWithQoS(completion: @escaping () -> Void) {
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
		process.executableURL = execUrl!
		// Run app
		do {
			try process.run()
		} catch {
			print(error)
		}
		// Run completion handler
		completion()
	}
	
	func quit() {
		runningApplication!.terminate()
	}

}

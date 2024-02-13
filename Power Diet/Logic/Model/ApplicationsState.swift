//
//  PowerDietTools.swift
//  Power Diet
//
//  Created by Bean John on 9/2/2024.
//

import Foundation
import ExtensionKit
import SwiftUI

class ApplicationsState: ValueDataModel<Application> {
	
	static let shared: ApplicationsState = ApplicationsState()
	
	required init(appDirName: String = "Power Diet", datastoreName: String = "applicationState") {
		// Init object
		super.init(appDirName: appDirName, datastoreName: datastoreName)
		// Get all apps
		self.updateAppList()
		// Start observing app changes
		WorkspaceEvents.observeRunningApplications()
	}
	
	func updateAppList() {
		Task { @MainActor in
			self.values = await allApps().sorted(by: { $0.url.lastPathComponent <= $1.url.lastPathComponent })
			print("App list updated at \(Date.now.description)")
		}
	}
	
	private func allApps() async -> [Application] {
		// Declare scanned URLs
		let systemAppDir: URL = URL(filePath: "/Applications/")
		let userAppDir: URL = URL(filePath: "/Users/\(NSUserName())/Applications/")
		let appDirs: [URL] = [
			systemAppDir,
			userAppDir
		]
		// Get apps
		var apps = [Application]()
		for appDir in appDirs {
			do {
				var appUrls: [URL] = try appDir.listDirectory()
				appUrls = appUrls.filter({ $0.pathExtension == "app" })
				apps = apps + appUrls.map { url in
					// Find stored QoS
					let currQoS: QoS? = values.filter({ $0.url == url }).first?.qoS
					let isHelper: Bool = !appDirs.map({ $0 == url.deletingLastPathComponent() }).contains(true)
					let isRunning: Bool = {
						// Get list of running apps
						let runningApps: [NSRunningApplication] = NSWorkspace.shared.runningApplications
						// Check for app in running apps
						for app in runningApps {
							// If match, return true
							if let bundleUrl: URL = app.bundleURL {
								if bundleUrl == url {
									return true
								}
							}
						}
						// If not found in running application, return false
						return false
					}()
					return Application(url: url, isHelper: isHelper, qoS: currQoS ?? .userInteractive, isRunning: isRunning)
				}
			} catch { }
		}
		// Return result
		return apps.filter({ $0.name != "Power Diet" })
	}
	
}

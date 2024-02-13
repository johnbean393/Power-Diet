//
//  WorkspaceEvents.swift
//  Power Diet
//
//  Created by Bean John on 13/2/2024.
//

import Cocoa

class WorkspaceEvents {
	
	private static var appsObserver: NSKeyValueObservation!
	private static var previousValueOfRunningApps: Set<NSRunningApplication>!
	
	static func observeRunningApplications() {
		previousValueOfRunningApps = Set(NSWorkspace.shared.runningApplications)
		appsObserver = NSWorkspace.shared.observe(\.runningApplications, options: [.old, .new], changeHandler: observerCallback)
	}
	
	static func observerCallback<A>(_ application: NSWorkspace, _ change: NSKeyValueObservedChange<A>) {
		let workspaceApps = Set(NSWorkspace.shared.runningApplications)
		// TODO: symmetricDifference has bad performance
		let diff = Array(workspaceApps.symmetricDifference(previousValueOfRunningApps))
		if change.kind == .insertion {
			if let appLaunched: NSRunningApplication = diff.first {
				for (index, app) in ApplicationsState.shared.values.enumerated() {
					if app.url == appLaunched.bundleURL {
						ApplicationsState.shared.values[index].isRunning = true
					}
				}
			}
		} else if change.kind == .removal {
			if let appQuitted: NSRunningApplication = diff.first {
				for (index, app) in ApplicationsState.shared.values.enumerated() {
					if app.url == appQuitted.bundleURL {
						ApplicationsState.shared.values[index].isRunning = false
					}
				}
			}
		}
		previousValueOfRunningApps = workspaceApps
	}
}

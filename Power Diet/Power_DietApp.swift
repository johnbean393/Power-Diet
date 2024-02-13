//
//  Power_DietApp.swift
//  Power Diet
//
//  Created by Bean John on 9/2/2024.
//

import SwiftUI

@main
struct Power_DietApp: App {
	
	@StateObject private var applicationsState: ApplicationsState = ApplicationsState.shared
	
    var body: some Scene {
        WindowGroup {
            ContentView()
				.environmentObject(applicationsState)
        }
    }
}

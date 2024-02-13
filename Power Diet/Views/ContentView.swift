//
//  ContentView.swift
//  Power Diet
//
//  Created by Bean John on 9/2/2024.
//

import SwiftUI

struct ContentView: View {
	
	@EnvironmentObject private var applicationsState: ApplicationsState
	
	@State private var query: String = ""
	@State private var queryQos: [QoS] = [.userInteractive, .background]
	@State private var includeHelpers: Bool = false
	
	var body: some View {
		VStack {
			if !searchedApps.isEmpty {
				List(searchedApps) { app in
					AppRowView(app: app)
				}
			} else {
				ProgressView()
			}
		}
		.searchable(text: $query)
		.toolbar {
			ToolbarItemGroup {
				reloadButton
				qoSFilterMenu
			}
		}
	}
	
	var reloadButton: some View {
		Button {
			applicationsState.updateAppList()
		} label: {
			Label("", systemImage: "arrow.clockwise")
		}
	}
	
	var qoSFilterMenu: some View {
		Picker("", selection: $queryQos) {
			Text("No Filter")
				.tag([QoS.userInteractive, QoS.background])
			Text("P & E-Cores")
				.tag([QoS.userInteractive])
			Text("E-Cores")
				.tag([QoS.background])
		}
	}
	
	var searchedApps: Binding<[Application]> {
		var searchResults: Binding<[Application]>
		if query.isEmpty {
			searchResults = $applicationsState.values
		} else {
			searchResults = $applicationsState.values.filter({
				$0.name.lowercased().contains(query.lowercased())
			})
		}
		let qoSResult: Binding<[Application]> = searchResults.filter({ queryQos.contains($0.qoS) })
		return qoSResult
	}
	
}

#Preview {
    ContentView()
		.environmentObject(ApplicationsState.shared)
}


extension Binding where Value: MutableCollection, Value: RangeReplaceableCollection, Value.Element: Identifiable {
	func filter(_ isIncluded: @escaping (Value.Element)->Bool) -> Binding<[Value.Element]> {
		return Binding<[Value.Element]>(
			get: {
				// The binding returns a filtered subset of the original wrapped collection.
				self.wrappedValue.filter(isIncluded)
			},
			set: { newValue in
				// Assignments to the binding's wrapped value are compared with IDs in the original biding's collection.
				// If they match, they are replaced.
				// If no match is found, they are appended.
				newValue.forEach { newItem in
					guard let i = self.wrappedValue.firstIndex(where: { $0.id == newItem.id }) else {
						self.wrappedValue.append(newItem)
						return
					}
					self.wrappedValue[i] = newItem
				}
			}
		)
	}
}

//
//  DuoScreenCalendarApp.swift
//  DuoScreenCalendar
//
//  Created by 백상휘 on 10/20/26.
//

import SwiftUI
import SwiftData

@main
struct DuoScreenCalendarApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            TodoDTO.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            TabView {
                Tab("Content1", systemImage: "rectangle", role: .prominent) {
                    ContentView()
                }
                .tabPlacement(.pinned)
                Tab("Content2", systemImage: "rectangle.split.2x1.fill", role: .search) {
                    ContentView()
                }
                .tabPlacement(.pinned)
                Tab("Content3", systemImage: "rectangle.split.3x1.fill") {
                    ContentView()
                }
            }
        }
        .modelContainer(sharedModelContainer)
    }
}

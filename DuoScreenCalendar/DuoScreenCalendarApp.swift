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
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}

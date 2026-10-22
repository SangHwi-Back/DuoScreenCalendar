//
//  ContentView.swift
//  DuoScreenCalendar
//
//  Created by 백상휘 on 10/20/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var hingeStatus: DeviceHinge.Status?
    
    var body: some View {
        LargeApp(todos: SampleData.todos, month: Date())
            .environment(\.hingeStatus, hingeStatus)
            .onHingeChange { _, newContext in
                self.hingeStatus = newContext.hinge?.status
            }
    }
}

enum ArrangementViewType: CaseIterable {
    case overlay, split
    var viewStyle: any ArrangementViewStyle {
        switch self {
        case .overlay: OverlayArrangementViewStyle.overlay
        case .split: SplitArrangementViewStyle.split
        }
    }
    var title: String {
        switch self {
        case .overlay: "Overlay"
        case .split: "Split"
        }
    }
    var systemImage: String {
        switch self {
        case .overlay: "circle.dashed.rectangle"
        case .split: "rectangle.split.2x1"
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: TodoDTO.self, inMemory: true)
}

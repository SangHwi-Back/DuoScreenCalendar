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
    
    @Environment(\.horizontalSizeClass)
    private var horizontalSizeClass
    @Environment(\.verticalSizeClass)
    private var verticalSizeClass
    
    @Query private var items: [TodoDTO]
    
    @State private var hingeStatus: DeviceHinge.Status?
    
    @State private var isAddingTodo = false
    @State private var pickerDate: Date?
    @State private var todos = SampleData.todos
    @State private var month = Date()
    
    var body: some View {
//        NavigationSplitView {
//            TodoListView(todos: $todos, month: .init(), isAddingTodo: $isAddingTodo, pickedDate: $pickerDate, linksToCalendar: true)
//        } detail: {
//            CalendarView(month: $month, todos: todos, holidays: SampleData.holidays, selectedDate: $pickerDate, isSelectingDate: true)
//        }
        
        Group {
            switch hingeStatus {
            case .fullyOpen:
                LargeApp(todos: $todos, month: $month)
            case .partiallyOpen:
                SplitApp(todos: $todos, month: $month)
            default:
                CommonApp(todos: $todos, month: $month)
            }
        }
        .onHingeChange { _, newContext in
            self.hingeStatus = newContext.hinge?.status
        }
    }
    
    private func addItem() {
        withAnimation {
            let newItem = TodoDTO(timestamp: Date())
            modelContext.insert(newItem)
        }
    }
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: TodoDTO.self, inMemory: true)
}

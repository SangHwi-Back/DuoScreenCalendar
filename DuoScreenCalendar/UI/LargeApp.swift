//
//  LargeApp.swift
//  DuoScreenCalendar
//
//  Created by 백상휘 on 10/21/26.
//

import SwiftUI

struct LargeApp: View {
    @Environment(\.overlayArrangementZIndex) var zIndex
    
    @Binding var todos: [TodoItem]
    @Binding var month: Date
    
    // 할일 추가 시트(TodoListView)와 날짜 선택 모드(CalendarView)가 공유하는 상태
    @State private var isAddingTodo = false
    @State private var pickedDate: Date?
    
    var body: some View {
        NavigationSplitView {
            TodoListView(todos: $todos, month: month, isAddingTodo: $isAddingTodo, pickedDate: $pickedDate)
        } detail: {
            ArrangementView {
                CalendarView(month: $month, todos: todos, holidays: SampleData.holidays,
                             selectedDate: $pickedDate, isSelectingDate: isAddingTodo)
            } secondary: {
                CalendarView(month: $month, todos: todos, holidays: SampleData.holidays,
                             selectedDate: $pickedDate, isSelectingDate: isAddingTodo)
            }
            .arrangementViewStyle(.overlay)
        }
    }
}

#Preview("Light") {
    LargeApp(todos: Binding.constant(SampleData.todos), month: Binding.constant(Date()))
}

#Preview("Dark") {
    LargeApp(todos: Binding.constant(SampleData.todos), month: Binding.constant(Date()))
        .preferredColorScheme(.dark)
}

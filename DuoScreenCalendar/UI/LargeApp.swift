//
//  LargeApp.swift
//  DuoScreenCalendar
//
//  Created by 백상휘 on 10/21/26.
//

import SwiftUI

/**
 ArrangementView overlay 는 첫번째 화면은 덮을 화면, 두번째 화면은 아래 깔리는 화면이다.
 폰이 반쯤 접힐 경우 2개의 케이스가 존재한다.
 - 가로 상태일 경우 첫번째 두번째 화면은 겹친다.
 - 세로 상태일 경우 첫번째 화면은 아래로 내려가고 두번째 화면은 위로 올라간다.
 NavigationSplitView 를 긍정적으로 고려하면 좋겠다. left Pane 을 닫을 수 있도록 해준다.
 */
struct LargeApp: View {
    @Environment(\.overlayArrangementZIndex) var zIndex
    
    @Binding var todos: [TodoItem]
    @Binding var month: Date
    
    // 할일 추가 시트(TodoListView)와 날짜 선택 모드(CalendarView)가 공유하는 상태
    @State private var isAddingTodo = false
    @State private var pickedDate: Date?
    
    var body: some View {
        NavigationSplitView {
            Color.pink.frame(width: 100, height: 100)
        } detail: {
            ArrangementView {
                TodoListView(todos: $todos, month: month, isAddingTodo: $isAddingTodo, pickedDate: $pickedDate)
                    .opacity(0.5)
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

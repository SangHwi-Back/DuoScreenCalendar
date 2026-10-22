//
//  SplitApp.swift
//  DuoScreenCalendar
//
//  Created by 백상휘 on 10/21/26.
//

import SwiftUI

/**
 NavigationSplitView 와 다른 건 2개
 - 왼쪽 화면을 숨김 처리할 수 없다.
 - 완전히 편 상태로 세로로 볼 경우 위 아래로 화면이 나뉜다.
 언제나 두 개의 화면을 보여주고 싶다면 이걸 쓰면 된다.
 접었을 때는 첫번째 정의한 화면이 보일 것이며 아래 예시에선 TodoListView 만 보일 것이다.
 */
struct SplitApp: View {
    @Binding var todos: [TodoItem]
    @Binding var month: Date
    
    // 할일 추가 시트(TodoListView)와 날짜 선택 모드(CalendarView)가 공유하는 상태
    @State private var isAddingTodo = false
    @State private var pickedDate: Date?
    
    var body: some View {
        ArrangementView {
            TodoListView(todos: $todos, month: month, isAddingTodo: $isAddingTodo, pickedDate: $pickedDate)
        } secondary: {
            CalendarView(month: $month, todos: todos, holidays: SampleData.holidays,
                         selectedDate: $pickedDate, isSelectingDate: isAddingTodo)
        }
        .arrangementViewStyle(.split)
    }
}

#Preview {
    SplitApp(todos: Binding.constant(SampleData.todos), month: Binding.constant(Date()))
}

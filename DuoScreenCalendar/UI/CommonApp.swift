//
//  CommonApp.swift
//  DuoScreenCalendar
//
//  Created by 백상휘 on 10/21/26.
//

import SwiftUI

struct CommonApp: View {
    @Binding var todos: [TodoItem]
    @Binding var month: Date
    
    @State private var isAddingTodo = false
    @State private var pickedDate: Date?
    
    var body: some View {
        // 달력이 보이지 않는 레이아웃이라 시트가 날짜를 직접 고르게 한다.
        TodoListView(todos: $todos, month: month, isAddingTodo: $isAddingTodo,
                     pickedDate: $pickedDate, onTapList: { _ in }, linksToCalendar: false)
    }
}

#Preview {
    CommonApp(todos: Binding.constant(SampleData.todos), month: Binding.constant(Date()))
}

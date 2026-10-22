//
//  LargeAppViewModel.swift
//  DuoScreenCalendar
//

import SwiftUI
import Combine

/// LargeApp 과 하위 화면(LargeOverlayView, LargeSplitView)이 공유하는 상태.

@Observable final class LargeAppViewModel {
    enum Path: Hashable {
    case add(TodoItem)
    }
    
    var todos: [TodoItem]
    var month: Date
    var arrangementViewType = ArrangementViewType.overlay
    
    // 할일 추가 시트(TodoListView)와 날짜 선택 모드(CalendarView)가 공유하는 상태
    var isAddingTodo = false
    var pickedDate: Date?
    
    var selectedItem: TodoItem?
    var path = NavigationPath([Path]())
    
    init(todos: [TodoItem], month: Date) {
        self.todos = todos
        self.month = month
    }
    
    /// 시트 자체는 사이드바의 TodoListView가 `isAddingTodo`를 보고 띄운다.
    func presentAddTodo() {
        pickedDate = CalendarSupport.defaultTodoDate(in: month)
        withAnimation { isAddingTodo = true }
    }
}

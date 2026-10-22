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
    @Environment(\.hingeStatus) private var hingeStatus
    
    @Binding var todos: [TodoItem]
    @Binding var month: Date
    @State private var arrangementViewType = ArrangementViewType.overlay
    
    // 할일 추가 시트(TodoListView)와 날짜 선택 모드(CalendarView)가 공유하는 상태
    @State private var isAddingTodo = false
    @State private var pickedDate: Date?
    
    @State private var isBeyondZero = false
    
    @State private var selectedItem: TodoItem?
    @State private var path = NavigationPath([Path]())
    
    enum Path: Hashable {
    case add(TodoItem)
    }
    
    var body: some View {
        if arrangementViewType == .overlay {
            NavigationStack(path: $path) {
                GeometryReader { proxy in
                    ArrangementView {
                        VStack {
                            Spacer()
                            TodoListAddButton(
                                presentAddTodo: presentAddTodo,
                                monthLabel: CalendarSupport.monthLabel(for: month),
                                isCompact: false
                            )
                            .safeAreaPadding()
                        }
                        .opacity(zIndex > 0 || isBeyondZero == false ? 1.0 : 0.0)
                        .sheet(isPresented: $isAddingTodo) {
                            AddTodoSheet(
                                month: month,
                                date: Binding(get: { pickedDate ?? CalendarSupport.defaultTodoDate(in: month) }, set: { pickedDate = $0 }),
                                linksToCalendar: false,
                                onCancel: {
                                },
                                onSave: { item in
                                    withAnimation { todos.append(item) }
                                }
                            )
                        }
                    } secondary: {
                        TodoListView(
                            todos: $todos,
                            month: month,
                            isAddingTodo: $isAddingTodo,
                            pickedDate: $pickedDate
                        ) { item in
                            self.path.append(Path.add(item))
                        }
                        .onScrollGeometryChange(for: Bool.self) { geometry in
                            geometry.contentOffset.y < geometry.contentInsets.top
                        } action: { wasBeyondZero, isBeyondZero in
                            self.isBeyondZero = isBeyondZero
                        }
                    }
                    .arrangementViewStyle(.overlay)
                }
                .navigationDestination(for: Path.self) { path in
                    if case .add(let item) = path {
                        TodoDetailView(todo: .constant(item)) {
                            self.selectedItem = nil
                        } onEdit: {
                        } onDelete: {
                        }
                    }
                }
                .toolbar {
                    if isBeyondZero {
                        ToolbarItem(placement: .primaryAction) {
                            TodoListAddButton(
                                presentAddTodo: presentAddTodo,
                                monthLabel: CalendarSupport.monthLabel(for: month),
                                isCompact: true
                            )
                        }
                    }
                    
                    ForEach(ArrangementViewType.allCases, id: \.self) { item in
                        let isSelected = arrangementViewType == item
                        ToolbarItem {
                            Button(item.title, systemImage: item.systemImage) {
                                withAnimation { arrangementViewType = item }
                            }
                            .buttonStyle(.plain)
                            .accessibilityAddTraits(isSelected ? .isSelected : [])
                        }
                        .axisBehavior(.verticalPreferred)
                    }
                }
            }
        } else {
            ArrangementView {
                TodoListView(
                    todos: $todos,
                    month: month,
                    isAddingTodo: $isAddingTodo,
                    pickedDate: $pickedDate
                ) { item in
                    self.path.append(Path.add(item))
                }
            } secondary: {
                NavigationStack(path: $path) {
                    CalendarView(month: $month, todos: todos, holidays: SampleData.holidays,
                                 selectedDate: $pickedDate, isSelectingDate: isAddingTodo)
                    .navigationDestination(for: Path.self) { path in
                        if case .add(let item) = path {
                            TodoDetailView(todo: .constant(item)) {
                                self.selectedItem = nil
                            } onEdit: {
                            } onDelete: {
                            }
                        }
                    }
                    .sheet(isPresented: $isAddingTodo) {
                        AddTodoSheet(
                            month: month,
                            date: Binding(get: { pickedDate ?? CalendarSupport.defaultTodoDate(in: month) }, set: { pickedDate = $0 }),
                            linksToCalendar: false,
                            onCancel: {
                            },
                            onSave: { item in
                                withAnimation { todos.append(item) }
                            }
                        )
                    }
                    .toolbar {
                        ToolbarItem {
                            TodoListAddButton(
                                presentAddTodo: presentAddTodo,
                                monthLabel: CalendarSupport.monthLabel(for: month),
                                isCompact: true)
                        }
                        
                        ForEach(ArrangementViewType.allCases, id: \.self) { item in
                            let isSelected = arrangementViewType == item
                            ToolbarItem {
                                Button(item.title, systemImage: item.systemImage) {
                                    withAnimation { arrangementViewType = item }
                                }
                                .buttonStyle(.plain)
                                .accessibilityAddTraits(isSelected ? .isSelected : [])
                            }
                            .axisBehavior(.verticalPreferred)
                        }
                    }
                }
            }
            .arrangementViewStyle(.split)
        }
    }

    /// 시트 자체는 사이드바의 TodoListView가 `isAddingTodo`를 보고 띄운다.
    private func presentAddTodo() {
        pickedDate = CalendarSupport.defaultTodoDate(in: month)
        withAnimation { isAddingTodo = true }
    }
}

#Preview("Light") {
    LargeApp(
        todos: .constant(SampleData.todos),
        month: .constant(Date())
    )
}

#Preview("Dark") {
    LargeApp(
        todos: .constant(SampleData.todos),
        month: .constant(Date())
    )
    .preferredColorScheme(.dark)
}

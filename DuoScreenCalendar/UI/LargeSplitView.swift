//
//  LargeSplitView.swift
//  DuoScreenCalendar
//

import SwiftUI

/// `ArrangementViewType.split` 일 때 LargeApp 이 보여주는 화면.
struct LargeSplitView: View {
    @Binding var viewModel: LargeAppViewModel
    
    var body: some View {
        ArrangementView {
            TodoListView(
                todos: $viewModel.todos,
                month: viewModel.month,
                isAddingTodo: $viewModel.isAddingTodo,
                pickedDate: $viewModel.pickedDate
            ) { item in
                viewModel.path.append(LargeAppViewModel.Path.add(item))
            }
        } secondary: {
            NavigationStack(path: $viewModel.path) {
                CalendarView(month: $viewModel.month, todos: viewModel.todos, holidays: SampleData.holidays,
                             selectedDate: $viewModel.pickedDate, isSelectingDate: viewModel.isAddingTodo)
                .navigationDestination(for: LargeAppViewModel.Path.self) { path in
                    switch path {
                    case .add(let item):
                        TodoDetailView(todo: .constant(item)) {
                            viewModel.selectedItem = nil
                        } onEdit: {
                        } onDelete: {
                        }
                    }
                }
                .sheet(isPresented: $viewModel.isAddingTodo) {
                    AddTodoSheet(
                        month: viewModel.month,
                        date: Binding(get: { viewModel.pickedDate ?? CalendarSupport.defaultTodoDate(in: viewModel.month) }, set: { viewModel.pickedDate = $0 }),
                        linksToCalendar: false,
                        onCancel: {
                            viewModel.isAddingTodo = false
                        },
                        onSave: { item in
                            withAnimation { viewModel.todos.append(item) }
                        }
                    )
                }
                .toolbar {
                    ToolbarItem {
                        TodoListAddButton(
                            presentAddTodo: viewModel.presentAddTodo,
                            monthLabel: CalendarSupport.monthLabel(for: viewModel.month),
                            isCompact: true)
                    }
                    
                    ForEach(ArrangementViewType.allCases, id: \.self) { item in
                        let isSelected = viewModel.arrangementViewType == item
                        ToolbarItem {
                            Button(item.title, systemImage: item.systemImage) {
                                withAnimation { viewModel.arrangementViewType = item }
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

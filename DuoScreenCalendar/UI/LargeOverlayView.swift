//
//  LargeOverlayView.swift
//  DuoScreenCalendar
//

import SwiftUI

/// `ArrangementViewType.overlay` 일 때 LargeApp 이 보여주는 화면.
struct LargeOverlayView: View {
    @Environment(\.overlayArrangementZIndex) private var zIndex
    @Environment(\.hingeStatus) private var hingeStatus
    
    @Binding var viewModel: LargeAppViewModel
    
    @State private var isBeyondZero = false
    
    private var shouldShowOverlayAddButton: Bool {
        zIndex > 0 || isBeyondZero == false || hingeStatus == .partiallyOpen
    }
    private var shouldShowToolbarAddButton: Bool {
        isBeyondZero && (hingeStatus == .fullyOpen || hingeStatus == .closed)
    }
    
    var body: some View {
        NavigationStack(path: $viewModel.path) {
            GeometryReader { proxy in
                ArrangementView {
                    VStack {
                        Spacer()
                        TodoListAddButton(
                            presentAddTodo: viewModel.presentAddTodo,
                            monthLabel: CalendarSupport.monthLabel(for: viewModel.month),
                            isCompact: false
                        )
                    }
                    .opacity(shouldShowOverlayAddButton ? 1.0 : 0.0)
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
                } secondary: {
                    TodoListView(
                        todos: $viewModel.todos,
                        month: viewModel.month,
                        isAddingTodo: $viewModel.isAddingTodo,
                        pickedDate: $viewModel.pickedDate
                    ) { item in
                        viewModel.path.append(LargeAppViewModel.Path.add(item))
                    }
                    .onScrollGeometryChange(for: Bool.self) { geometry in
                        geometry.contentOffset.y > geometry.contentInsets.top
                    } action: { wasBeyondZero, isBeyondZero in
                        withAnimation {
                            self.isBeyondZero = isBeyondZero
                        }
                    }
                }
                .arrangementViewStyle(.overlay)
            }
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
            .toolbar {
                if shouldShowToolbarAddButton {
                    ToolbarItem(placement: .primaryAction) {
                        TodoListAddButton(
                            presentAddTodo: viewModel.presentAddTodo,
                            monthLabel: CalendarSupport.monthLabel(for: viewModel.month),
                            isCompact: true
                        )
                    }
                    .axisBehavior(.verticalPreferred)
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
}

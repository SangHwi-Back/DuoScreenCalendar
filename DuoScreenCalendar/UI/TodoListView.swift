//
//  TodoListView.swift
//  DuoScreenCalendar
//
//  Created by 백상휘 on 10/21/26.
//

import SwiftUI

struct TodoListView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.hingeStatus) private var hingeStatus
    @Binding var todos: [TodoItem]
    let month: Date
    /// 할일 추가 시트의 표시 여부. 날짜 선택 모드를 켜야 하는 달력과 부모를 통해 공유한다.
    @Binding var isAddingTodo: Bool
    /// 시트와 달력이 함께 쓰는 선택 날짜
    @Binding var pickedDate: Date?
    var onTapList: (TodoItem) -> Void
    /// 옆에 달력이 보이는 레이아웃인지. false이면 시트가 날짜를 직접 고르게 한다.
    var linksToCalendar = true
    
    @State private var isDoneExpanded = false
    
    private var calendar: Calendar { CalendarSupport.calendar }
    private var monthNumber: Int { calendar.component(.month, from: month) }
    private var monthLabel: String { CalendarSupport.monthLabel(for: month) }
    
    private var monthTodos: [TodoItem] {
        todos.filter {
            calendar.isDate($0.month, equalTo: month, toGranularity: $0.isYearly ? .year : .month)
        }
    }
    
    private var defaultDate: Date { CalendarSupport.defaultTodoDate(in: month) }
    
    private var thisWeek: [TodoItem] {
        sortedByDate(monthTodos.filter { !$0.isDone && isThisWeek($0) })
    }
    
    private var remaining: [TodoItem] {
        sortedByDate(monthTodos.filter { !$0.isDone && !isThisWeek($0) })
    }
    
    private var completed: [TodoItem] {
        sortedByDate(monthTodos.filter(\.isDone))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    section("이번 주", items: thisWeek)
                    section("남은 할일", items: remaining)
                    doneSection
                }
            }
            .scrollIndicators(.hidden)
        }
        .padding(.horizontal, 28)
        .padding(.vertical, 24)
        .background(tone(.paperBackground))
        .toolbar {
            if hingeStatus == .closed {
                ToolbarItem {
                    TodoListAddButton(presentAddTodo: presentAddTodo, monthLabel: monthLabel, isCompact: false)
                }
                .axisBehavior(.verticalPreferred)
            }
        }
    }
    
    // MARK: - Add todo sheet
    
    /// 이 뷰의 영역(왼쪽 패널) 안에서만 올라오는 시트. 옆의 달력은 가리지 않는다.
    private var addTodoOverlay: some View {
        ZStack(alignment: .bottom) {
            tone(.scrim)
                .ignoresSafeArea()
                .onTapGesture(perform: dismissAddTodo)
                .accessibilityHidden(true)
            
            AddTodoSheet(
                month: month,
                date: Binding(get: { pickedDate ?? defaultDate }, set: { pickedDate = $0 }),
                linksToCalendar: linksToCalendar,
                onCancel: dismissAddTodo,
                onSave: { item in
                    withAnimation { todos.append(item) }
                    dismissAddTodo()
                }
            )
            .padding(.top, 36)
            .transition(.move(edge: .bottom))
        }
        .accessibilityAddTraits(.isModal)
    }
    
    private func presentAddTodo() {
        pickedDate = defaultDate
        withAnimation { isAddingTodo = true }
    }
    
    private func dismissAddTodo() {
        withAnimation { isAddingTodo = false }
        pickedDate = nil
    }
    
    // MARK: - Header
    
    private var header: some View {
        let total = monthTodos.count
        let done = completed.count
        let progress = total == 0 ? 0 : Double(done) / Double(total)
        
        return VStack(alignment: .leading, spacing: 6) {
            Text("\(CalendarSupport.englishMonthName(of: month)) · \(monthLabel)")
                .font(.caption.weight(.semibold))
                .tracking(1.5)
                .foregroundStyle(tone(.muted))
            
            Text("\(monthNumber)월 할일")
                .font(.system(.largeTitle, design: .serif, weight: .bold))
                .foregroundStyle(tone(.ink))
            
            HStack(spacing: 16) {
                GeometryReader { proxy in
                    ZStack(alignment: .leading) {
                        Capsule().fill(tone(.sunk))
                        Capsule()
                            .fill(tone(.ink))
                            .frame(width: proxy.size.width * progress)
                    }
                }
                .frame(height: 4)
                
                Text("\(total)개 중 \(done)개 완료")
                    .font(.caption)
                    .foregroundStyle(tone(.muted))
            }
            .padding(.top, 6)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("진행률")
            .accessibilityValue("\(total)개 중 \(done)개 완료")
        }
    }
    
    // MARK: - Sections
    
    @ViewBuilder
    private func section(_ title: String, items: [TodoItem]) -> some View {
        if !items.isEmpty {
            sectionHeader(title, count: items.count)
            ForEach(items) { row($0) }
        }
    }
    
    @ViewBuilder
    private var doneSection: some View {
        if !completed.isEmpty {
            Button {
                withAnimation { isDoneExpanded.toggle() }
            } label: {
                sectionHeader("완료", count: completed.count)
            }
            .buttonStyle(.plain)
            .accessibilityValue(isDoneExpanded ? "펼침" : "접힘")
            
            if isDoneExpanded {
                ForEach(completed) { row($0) }
            }
        }
    }
    
    private func sectionHeader(_ title: String, count: Int) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text(title)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(tone(.ink))
            Text("\(count)개")
                .font(.caption)
                .foregroundStyle(tone(.muted))
        }
        .padding(.top, 20)
        .padding(.bottom, 8)
        .contentShape(Rectangle())
    }
    
    // MARK: - Row
    
    private func row(_ item: TodoItem) -> some View {
        let chip = item.category.chipColors(colorScheme: colorScheme)
        
        return HStack(spacing: 14) {
            Button {
                toggle(item)
            } label: {
                Image(systemName: item.isDone ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(item.isDone ? tone(.accent) : tone(.muted))
            }
            .buttonStyle(.plain)
            .accessibilityLabel(item.isDone ? "\(item.title) 완료 취소" : "\(item.title) 완료")
            
            VStack(alignment: .leading, spacing: 3) {
                Text(item.title)
                    .font(.body.weight(.semibold))
                    .strikethrough(item.isDone)
                    .foregroundStyle(item.isDone ? tone(.muted) : tone(.ink))
                Text(item.subtitle())
                    .font(.caption)
                    .foregroundStyle(tone(.muted))
            }
            
            Spacer(minLength: 8)
            
            Text(item.category.title)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(chip.foreground)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(chip.background, in: Capsule())
        }
        .padding(.vertical, 12)
        .contentShape(Rectangle())
        .onTapGesture {
            onTapList(item)
        }
        .overlay(alignment: .bottom) {
            Rectangle().fill(tone(.line)).frame(height: 1)
        }
    }
    
    // MARK: - Helpers
    
    private func tone(_ color: AppColor) -> Color {
        color.color(colorScheme: colorScheme)
    }
    
    private func toggle(_ item: TodoItem) {
        guard let index = todos.firstIndex(where: { $0.id == item.id }) else { return }
        withAnimation { todos[index].isDone.toggle() }
    }
    
    private func isThisWeek(_ item: TodoItem) -> Bool {
        guard let dueDate = item.dueDate else { return false }
        return calendar.isDate(dueDate, equalTo: Date(), toGranularity: .weekOfYear)
    }
    
    /// 날짜가 있는 항목을 빠른 순으로, 날짜 미정은 맨 뒤로 정렬한다.
    private func sortedByDate(_ items: [TodoItem]) -> [TodoItem] {
        items.sorted { ($0.dueDate ?? .distantFuture) < ($1.dueDate ?? .distantFuture) }
    }
}

#Preview("Light") {
    @Previewable @State var todos = SampleData.todos
    @Previewable @State var isAdding = false
    @Previewable @State var pickedDate: Date?
    TodoListView(todos: $todos, month: SampleData.october, isAddingTodo: $isAdding, pickedDate: $pickedDate, onTapList: { _ in })
}

#Preview("Dark") {
    @Previewable @State var todos = SampleData.todos
    @Previewable @State var isAdding = false
    @Previewable @State var pickedDate: Date?
    TodoListView(todos: $todos, month: SampleData.october, isAddingTodo: $isAdding, pickedDate: $pickedDate, onTapList: { _ in })
        .preferredColorScheme(.dark)
}

#Preview("Adding") {
    @Previewable @State var todos = SampleData.todos
    @Previewable @State var isAdding = true
    @Previewable @State var pickedDate: Date? = SampleData.october
    TodoListView(todos: $todos, month: SampleData.october, isAddingTodo: $isAdding, pickedDate: $pickedDate, onTapList: { _ in })
}

//
//  TodoDetailView.swift
//  DuoScreenCalendar
//
//  Created by 백상휘 on 10/22/26.
//

import SwiftUI

/// 할일 상세 화면. 뒤로가기·수정·삭제 동작은 부모가 정하고,
/// 이 화면은 완료 토글과 체크리스트 체크만 직접 처리한다.
struct TodoDetailView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Binding var todo: TodoItem
    let onBack: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void

    @State private var isConfirmingDelete = false

    private var calendar: Calendar { CalendarSupport.calendar }

    var body: some View {
        VStack(spacing: 0) {
            topBar

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    tags

                    Text(todo.title)
                        .font(.system(.title, design: .serif, weight: .bold))
                        .foregroundStyle(tone(.ink))

                    scheduleCard

                    if !todo.memo.isEmpty {
                        memoSection
                    }

                    if !todo.checklist.isEmpty {
                        checklistSection
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 16)
            }
            .scrollIndicators(.hidden)

            completeButton
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
                .padding(.top, 8)
        }
        .background(tone(.paperBackground))
        .confirmationDialog("이 할일을 삭제할까요?", isPresented: $isConfirmingDelete, titleVisibility: .visible) {
            Button("삭제", role: .destructive, action: onDelete)
        }
    }

    // MARK: - Top bar

    private var topBar: some View {
        HStack(spacing: 8) {
            Text("할일 상세")
                .font(.system(.title3, design: .serif, weight: .bold))
                .foregroundStyle(tone(.ink))

            Spacer()

            circleButton("chevron.left", label: "뒤로", action: onBack)
            circleButton("pencil", label: "수정", action: onEdit)
            circleButton("trash", label: "삭제") { isConfirmingDelete = true }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .overlay(alignment: .bottom) {
            Rectangle().fill(tone(.line)).frame(height: 1)
        }
    }

    private func circleButton(_ systemName: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(tone(.ink))
                .frame(width: 36, height: 36)
                .background(tone(.cardSurface), in: Circle())
                .overlay(Circle().stroke(tone(.line)))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
    }

    // MARK: - Tags

    private var tags: some View {
        let category = todo.category.chipColors(colorScheme: colorScheme)

        return HStack(spacing: 6) {
            tag(todo.category.title, foreground: category.foreground, background: category.background)

            switch status {
            case .upcoming:
                tag("예정", foreground: tone(.accent), background: tone(.accentSoft))
            case .overdue:
                tag("지남", foreground: tone(.accent), background: tone(.accentSoft))
            case .done:
                tag("완료", foreground: tone(.muted), background: tone(.sunk))
            }
        }
    }

    private func tag(_ text: String, foreground: Color, background: Color) -> some View {
        Text(text)
            .font(.caption2.weight(.semibold))
            .foregroundStyle(foreground)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(background, in: Capsule())
    }

    private enum Status {
        case upcoming
        case overdue
        case done
    }

    private var status: Status {
        if todo.isDone { return .done }
        guard let dueDate = todo.dueDate else { return .upcoming }
        return calendar.startOfDay(for: dueDate) < calendar.startOfDay(for: Date()) ? .overdue : .upcoming
    }

    // MARK: - Schedule card

    private var scheduleCard: some View {
        VStack(spacing: 0) {
            row(icon: "calendar", title: "날짜") {
                HStack(spacing: 8) {
                    Text(dateText)
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(tone(.ink))

                    if let relative = relativeDayText {
                        tag(relative, foreground: tone(.accent), background: tone(.accentSoft))
                    }
                }
            }

            divider

            row(icon: "clock", title: "시간") {
                Text(timeText)
                    .font(.subheadline)
                    .foregroundStyle(tone(.muted))
            }

            divider

            row(icon: "bell", title: "알림") {
                Text("당일 오전 9:00")
                    .font(.subheadline)
                    .foregroundStyle(tone(.muted))
            }
        }
        .modifier(CardStyle(colorScheme: colorScheme))
    }

    private var dateText: String {
        if let dueDate = todo.dueDate {
            return CalendarSupport.dayFormatter.string(from: dueDate)
        }
        if todo.isYearly {
            return "\(String(calendar.component(.year, from: todo.month)))년 중"
        }
        return "\(calendar.component(.month, from: todo.month))월 중"
    }

    private var timeText: String {
        guard let dueDate = todo.dueDate, todo.hasTime else { return "하루 종일" }
        return CalendarSupport.timeFormatter.string(from: dueDate)
    }

    /// 오늘 기준 남은 일수. 날짜 미정이면 표시하지 않는다.
    private var relativeDayText: String? {
        guard let dueDate = todo.dueDate else { return nil }
        let days = calendar.dateComponents(
            [.day],
            from: calendar.startOfDay(for: Date()),
            to: calendar.startOfDay(for: dueDate)
        ).day ?? 0

        switch days {
        case 0: return "오늘"
        case 1...: return "\(days)일 후"
        default: return "\(-days)일 전"
        }
    }

    // MARK: - Memo / Checklist

    private var memoSection: some View {
        section("메모") {
            Text(todo.memo)
                .font(.subheadline)
                .foregroundStyle(tone(.ink))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(14)
                .modifier(CardStyle(colorScheme: colorScheme))
        }
    }

    private var checklistSection: some View {
        let done = todo.checklist.filter(\.isDone).count

        return section("체크리스트 · \(done) / \(todo.checklist.count)") {
            VStack(spacing: 0) {
                ForEach($todo.checklist) { $item in
                    if item.id != todo.checklist.first?.id {
                        divider
                    }

                    Button {
                        item.isDone.toggle()
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: item.isDone ? "checkmark.square.fill" : "square")
                                .font(.title3)
                                .foregroundStyle(item.isDone ? tone(.muted) : tone(.ink))

                            Text(item.title)
                                .font(.subheadline)
                                .strikethrough(item.isDone)
                                .foregroundStyle(item.isDone ? tone(.muted) : tone(.ink))

                            Spacer(minLength: 0)
                        }
                        .padding(.horizontal, 16)
                        .frame(minHeight: 48)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityAddTraits(item.isDone ? .isSelected : [])
                }
            }
            .modifier(CardStyle(colorScheme: colorScheme))
        }
    }

    // MARK: - Complete button

    private var completeButton: some View {
        Button {
            withAnimation { todo.isDone.toggle() }
        } label: {
            Label(
                todo.isDone ? "완료 취소" : "완료로 표시",
                systemImage: todo.isDone ? "arrow.uturn.backward" : "checkmark"
            )
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .foregroundStyle(tone(.paperBackground))
            .background(tone(.ink), in: Capsule())
        }
        .buttonStyle(.plain)
    }

    // MARK: - Building blocks

    private struct CardStyle: ViewModifier {
        let colorScheme: ColorScheme

        func body(content: Content) -> some View {
            content
                .background(AppColor.cardSurface.color(colorScheme: colorScheme), in: RoundedRectangle(cornerRadius: 14))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(AppColor.line.color(colorScheme: colorScheme))
                )
        }
    }

    private func section<Content: View>(_ label: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.caption.weight(.semibold))
                .foregroundStyle(tone(.muted))
            content()
        }
    }

    private func row<Trailing: View>(
        icon: String,
        title: String,
        @ViewBuilder trailing: () -> Trailing
    ) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .frame(width: 20)
                .foregroundStyle(tone(.muted))
            Text(title)
                .font(.subheadline)
                .foregroundStyle(tone(.ink))
            Spacer(minLength: 8)
            trailing()
        }
        .padding(.horizontal, 16)
        .frame(minHeight: 48)
    }

    private var divider: some View {
        Rectangle().fill(tone(.line)).frame(height: 1)
    }

    private func tone(_ color: AppColor) -> Color {
        color.color(colorScheme: colorScheme)
    }
}

#Preview("Light") {
    @Previewable @State var todo = SampleData.todos[0]
    TodoDetailView(todo: $todo, onBack: {}, onEdit: {}, onDelete: {})
}

#Preview("Dark") {
    @Previewable @State var todo = SampleData.todos[0]
    TodoDetailView(todo: $todo, onBack: {}, onEdit: {}, onDelete: {})
        .preferredColorScheme(.dark)
}

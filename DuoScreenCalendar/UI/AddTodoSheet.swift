//
//  AddTodoSheet.swift
//  DuoScreenCalendar
//
//  Created by 백상휘 on 10/21/26.
//

import SwiftUI

/// 할일 추가 시트. `TodoListView` 위에 오버레이로 올라온다.
struct AddTodoSheet: View {
    private enum Period: CaseIterable {
        case date
        case month
        case year
    }
    
    @Environment(\.colorScheme) private var colorScheme
    
    /// 목록이 보여주는 달. "N월 중" / "N년 중" 기간의 기준이 된다.
    let month: Date
    /// 오른쪽 달력에서 고른 날짜와 연동된다.
    @Binding var date: Date
    /// 달력이 옆에 보이면 날짜를 달력에서 고르고, 아니면 시트 안에서 고른다.
    let linksToCalendar: Bool
    let onCancel: () -> Void
    let onSave: (TodoItem) -> Void
    
    @State private var title = ""
    @State private var period: Period = .date
    @State private var isAllDay = true
    @State private var time = CalendarSupport.date(2000, 1, 1, hour: 9)
    @State private var category: TodoCategory = .work
    @State private var memo = ""
    
    private let categories: [TodoCategory] = [.work, .personal, .health]
    
    private var calendar: Calendar { CalendarSupport.calendar }
    private var canSave: Bool { !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    
    var body: some View {
        VStack(spacing: 0) {
            header
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    titleSection
                    periodSection
                    if period == .date {
                        dateCard
                    }
                    categorySection
                    memoSection
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
            .scrollIndicators(.hidden)
            .scrollDismissesKeyboard(.interactively)
        }
        .background {
            UnevenRoundedRectangle(topLeadingRadius: 28, topTrailingRadius: 28)
                .fill(tone(.cardSurface))
                .shadow(color: .black.opacity(0.15), radius: 12, y: -2)
                .ignoresSafeArea(edges: .bottom)
        }
    }
    
    // MARK: - Header
    
    private var header: some View {
        VStack(spacing: 12) {
            Capsule()
                .fill(tone(.line))
                .frame(width: 40, height: 5)
            
            ZStack {
                Text("새 할일")
                    .font(.headline)
                    .foregroundStyle(tone(.ink))
                
                HStack {
                    Button("취소", action: onCancel)
                        .font(.subheadline)
                        .foregroundStyle(tone(.muted))
                    
                    Spacer()
                    
                    Button(action: save) {
                        Text("추가")
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(tone(.onAccent))
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(tone(.accent), in: Capsule())
                    }
                    .buttonStyle(.plain)
                    .disabled(!canSave)
                    .opacity(canSave ? 1 : 0.4)
                }
            }
        }
        .padding(.top, 10)
        .padding(.horizontal, 24)
        .padding(.bottom, 16)
        .contentShape(Rectangle())
        // 헤더를 아래로 끌어내리면 닫힌다.
        .gesture(
            DragGesture().onEnded { value in
                if value.translation.height > 80 { onCancel() }
            }
        )
    }
    
    // MARK: - Sections
    
    private var titleSection: some View {
        section("할일") {
            TextField("할일을 입력하세요", text: $title)
                .foregroundStyle(tone(.ink))
                .padding(14)
                .background(inputBackground, in: RoundedRectangle(cornerRadius: 14))
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(tone(.line)))
        }
    }
    
    private var periodSection: some View {
        section("기간") {
            HStack(spacing: 0) {
                ForEach(Period.allCases, id: \.self) { item in
                    let isSelected = period == item
                    Button {
                        withAnimation { period = item }
                    } label: {
                        Text(periodTitle(item))
                            .font(.subheadline.weight(isSelected ? .bold : .regular))
                            .foregroundStyle(isSelected ? tone(.ink) : tone(.muted))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background {
                                if isSelected {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(colorScheme == .dark ? tone(.sunk) : tone(.cardSurface))
                                        .shadow(color: .black.opacity(0.1), radius: 2, y: 1)
                                }
                            }
                    }
                    .buttonStyle(.plain)
                    .accessibilityAddTraits(isSelected ? .isSelected : [])
                }
            }
            .padding(4)
            .background(inputBackground, in: RoundedRectangle(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(tone(.line)))
        }
    }
    
    private var dateCard: some View {
        VStack(spacing: 0) {
            row(icon: "calendar", title: "날짜") {
                if linksToCalendar {
                    HStack(spacing: 8) {
                        Text(CalendarSupport.dayFormatter.string(from: date))
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(tone(.accent))
                        
                        HStack(spacing: 4) {
                            Text("달력에서 선택")
                            Image(systemName: "arrow.right")
                        }
                        .font(.caption2)
                        .foregroundStyle(tone(.muted))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(tone(.sunk), in: Capsule())
                    }
                } else {
                    DatePicker("날짜", selection: $date, displayedComponents: .date)
                        .labelsHidden()
                        .environment(\.locale, Locale(identifier: "ko_KR"))
                }
            }
            
            divider
            
            row(icon: "clock", title: "하루 종일") {
                Toggle("하루 종일", isOn: $isAllDay.animation())
                    .labelsHidden()
                    .tint(tone(.accent))
            }
            
            if !isAllDay {
                divider
                
                row(icon: "deskclock", title: "시간") {
                    DatePicker("시간", selection: $time, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                        .environment(\.locale, Locale(identifier: "ko_KR"))
                }
            }
            
            divider
            
            row(icon: "bell", title: "알림") {
                Text("당일 오전 9:00")
                    .font(.subheadline)
                    .foregroundStyle(tone(.muted))
            }
        }
        .background(colorScheme == .dark ? tone(.paperBackground) : tone(.cardSurface), in: RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(tone(.line)))
    }
    
    private var categorySection: some View {
        section("카테고리") {
            HStack(spacing: 10) {
                ForEach(categories, id: \.self) { item in
                    categoryChip(item)
                }
            }
        }
    }
    
    private var memoSection: some View {
        section("메모") {
            TextEditor(text: $memo)
                .scrollContentBackground(.hidden)
                .foregroundStyle(tone(.ink))
                .frame(minHeight: 90)
                .padding(8)
                .background(inputBackground, in: RoundedRectangle(cornerRadius: 14))
                .overlay(alignment: .topLeading) {
                    if memo.isEmpty {
                        Text("메모 (선택)")
                            .foregroundStyle(tone(.muted).opacity(0.8))
                            .padding(.horizontal, 13)
                            .padding(.top, 16)
                            .allowsHitTesting(false)
                    }
                }
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(tone(.line)))
        }
    }
    
    // MARK: - Building blocks
    
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
    
    private func categoryChip(_ item: TodoCategory) -> some View {
        let isSelected = category == item
        let colors = item.chipColors(colorScheme: colorScheme)
        // 라이트 모드의 카테고리 색은 옅은 배경색이라, 점과 테두리는 채도가 높은 다크 팔레트 색을 쓴다.
        let accent = item.appColor.color(colorScheme: .dark)
        
        return Button {
            category = item
        } label: {
            HStack(spacing: 6) {
                Circle()
                    .fill(accent)
                    .frame(width: 8, height: 8)
                Text(item.title)
                    .font(.subheadline.weight(.semibold))
            }
            .foregroundStyle(tone(.ink))
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(isSelected ? colors.background : tone(.cardSurface), in: Capsule())
            .overlay(Capsule().stroke(isSelected ? accent : tone(.line), lineWidth: isSelected ? 1.5 : 1))
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
    
    // MARK: - Helpers
    
    private var inputBackground: Color {
        colorScheme == .dark ? tone(.paperBackground) : tone(.sunk)
    }
    
    private func tone(_ color: AppColor) -> Color {
        color.color(colorScheme: colorScheme)
    }
    
    private func periodTitle(_ period: Period) -> String {
        switch period {
        case .date: "날짜 지정"
        case .month: "\(calendar.component(.month, from: month))월 중"
        case .year: "\(String(calendar.component(.year, from: month)))년 중"
        }
    }
    
    private func save() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else { return }
        
        var item = TodoItem(title: trimmedTitle, month: month, category: category)
        item.memo = memo.trimmingCharacters(in: .whitespacesAndNewlines)
        
        switch period {
        case .date:
            item.month = date
            if isAllDay {
                item.dueDate = calendar.startOfDay(for: date)
            } else {
                let components = calendar.dateComponents([.hour, .minute], from: time)
                item.dueDate = calendar.date(
                    bySettingHour: components.hour ?? 9,
                    minute: components.minute ?? 0,
                    second: 0,
                    of: date
                )
                item.hasTime = true
            }
        case .month:
            break
        case .year:
            item.isYearly = true
        }
        
        onSave(item)
    }
}

#Preview("Light") {
    @Previewable @State var date = SampleData.october
    AddTodoSheet(month: SampleData.october, date: $date, linksToCalendar: true, onCancel: {}, onSave: { _ in })
}

#Preview("Dark") {
    @Previewable @State var date = SampleData.october
    AddTodoSheet(month: SampleData.october, date: $date, linksToCalendar: true, onCancel: {}, onSave: { _ in })
        .preferredColorScheme(.dark)
}

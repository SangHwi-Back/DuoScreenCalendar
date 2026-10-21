//
//  CalendarView.swift
//  DuoScreenCalendar
//
//  Created by 백상휘 on 10/21/26.
//

import SwiftUI

struct CalendarView: View {
    private enum Mode: CaseIterable {
        case year
        case month
        
        var title: String {
            switch self {
            case .year: "년"
            case .month: "월"
            }
        }
    }
    
    @Environment(\.colorScheme) private var colorScheme
    @Binding var month: Date
    let todos: [TodoItem]
    let holidays: [Holiday]
    /// 할일 추가 시트에서 고른 날짜. 날짜 선택 모드일 때 이 칸이 강조된다.
    @Binding var selectedDate: Date?
    /// true이면 날짜 칸을 탭해 `selectedDate`를 바꿀 수 있다.
    let isSelectingDate: Bool
    
    @State private var mode: Mode = .month
    
    private var calendar: Calendar { CalendarSupport.calendar }
    private var year: Int { calendar.component(.year, from: month) }
    /// Int를 그대로 보간하면 "2,026"처럼 천 단위 구분이 붙는다.
    private var yearLabel: String { String(year) }
    private var monthNumber: Int { calendar.component(.month, from: month) }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            header
            
            Group {
                switch mode {
                case .month: monthGrid
                case .year: yearGrid
                }
            }
            .frame(maxHeight: .infinity, alignment: .top)
            
            navigation
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 24)
        .background(tone(.cardSurface))
        .overlay(alignment: .leading) {
            Rectangle().fill(tone(.line)).frame(width: 1)
        }
    }
    
    // MARK: - Header
    
    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                if isSelectingDate && mode == .month {
                    Text("할일 날짜를 탭해서 선택")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(tone(.accent))
                } else {
                    Text(mode == .month ? "\(yearLabel) · \(CalendarSupport.englishMonthName(of: month))" : yearLabel)
                        .font(.caption.weight(.semibold))
                        .tracking(1.5)
                        .foregroundStyle(tone(.muted))
                }
                
                Text(mode == .month ? "\(monthNumber)월" : "\(yearLabel)년")
                    .font(.system(.largeTitle, design: .serif, weight: .bold))
                    .foregroundStyle(tone(.ink))
            }
            
            Spacer()
            
            modePicker
        }
    }
    
    private var modePicker: some View {
        HStack(spacing: 0) {
            ForEach(Mode.allCases, id: \.self) { item in
                let isSelected = mode == item
                Button {
                    withAnimation { mode = item }
                } label: {
                    Text(item.title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(isSelected ? tone(.ink) : tone(.muted))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background {
                            if isSelected {
                                Capsule()
                                    .fill(tone(.cardSurface))
                                    .shadow(color: .black.opacity(0.12), radius: 3, y: 1)
                            }
                        }
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(isSelected ? .isSelected : [])
            }
        }
        .padding(4)
        .background(tone(.sunk), in: Capsule())
    }
    
    // MARK: - Month grid
    
    private var monthGrid: some View {
        let weeks = CalendarSupport.weeks(in: month)
        
        return VStack(spacing: 0) {
            weekdayHeader
            
            ForEach(weeks.indices, id: \.self) { row in
                HStack(spacing: 0) {
                    ForEach(0..<7, id: \.self) { column in
                        dayCell(weeks[row][column], column: column)
                    }
                }
                .frame(maxHeight: .infinity)
                .overlay(alignment: .top) {
                    Rectangle().fill(tone(.line)).frame(height: 1)
                }
            }
        }
    }
    
    private var weekdayHeader: some View {
        HStack(spacing: 0) {
            ForEach(CalendarSupport.weekdaySymbols.indices, id: \.self) { index in
                Text(CalendarSupport.weekdaySymbols[index])
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(weekdayColor(index))
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.bottom, 8)
    }
    
    @ViewBuilder
    private func dayCell(_ date: Date?, column: Int) -> some View {
        Group {
            if let date {
                if isSelectingDate {
                    Button {
                        selectedDate = date
                    } label: {
                        dayContent(date, column: column)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                            .background { selectionHighlight(for: date) }
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityAddTraits(isSelected(date) ? .isSelected : [])
                } else {
                    dayContent(date, column: column)
                }
            } else {
                Color.clear
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
    
    private func dayContent(_ date: Date, column: Int) -> some View {
        let holiday = holidays.first { calendar.isDate($0.date, inSameDayAs: date) }
        let items = todos.filter { item in
            guard let dueDate = item.dueDate else { return false }
            return calendar.isDate(dueDate, inSameDayAs: date)
        }
        let isToday = calendar.isDateInToday(date)
        let day = calendar.component(.day, from: date)
        
        return VStack(spacing: 3) {
            Text("\(day)")
                .font(.callout.weight(isToday ? .bold : .regular))
                .foregroundStyle(isToday ? tone(.onAccent) : weekdayColor(column, isHoliday: holiday != nil, defaultColor: .ink))
                .frame(width: 28, height: 28)
                .background {
                    if isToday { Circle().fill(tone(.accent)) }
                }
            
            if let holiday {
                Text(holiday.name)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(tone(.sundayRed))
                    .lineLimit(1)
            }
            
            ForEach(items.prefix(2)) { chip($0) }
        }
        .padding(.top, 8)
        .padding(.horizontal, 4)
        .accessibilityElement(children: .combine)
    }
    
    private func isSelected(_ date: Date) -> Bool {
        guard let selectedDate else { return false }
        return calendar.isDate(selectedDate, inSameDayAs: date)
    }
    
    @ViewBuilder
    private func selectionHighlight(for date: Date) -> some View {
        if isSelected(date) {
            RoundedRectangle(cornerRadius: 8)
                .fill(tone(.accentSoft))
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(tone(.accent), lineWidth: 1.5))
                .padding(2)
        }
    }
    
    private func chip(_ item: TodoItem) -> some View {
        let colors = item.category.chipColors(colorScheme: colorScheme)
        
        return Text(item.shortTitle ?? item.title)
            .font(.caption2)
            .strikethrough(item.isDone)
            .lineLimit(1)
            .minimumScaleFactor(0.8)
            .foregroundStyle(item.isDone ? tone(.muted) : colors.foreground)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(item.isDone ? tone(.sunk) : colors.background, in: RoundedRectangle(cornerRadius: 4))
    }
    
    // MARK: - Year grid
    
    private var yearGrid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 12) {
            ForEach(1...12, id: \.self) { value in
                let isSelected = value == monthNumber
                Button {
                    month = CalendarSupport.date(year, value, 1)
                    withAnimation { mode = .month }
                } label: {
                    Text("\(value)월")
                        .font(.headline)
                        .foregroundStyle(isSelected ? tone(.accent) : tone(.ink))
                        .frame(maxWidth: .infinity, minHeight: 80)
                        .background(
                            isSelected ? tone(.accentSoft) : tone(.sunk),
                            in: RoundedRectangle(cornerRadius: 14)
                        )
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    // MARK: - Navigation
    
    private var navigation: some View {
        HStack {
            Spacer()
            
            HStack(spacing: 24) {
                Button { step(by: -1) } label: {
                    Image(systemName: "chevron.left")
                }
                .accessibilityLabel(mode == .month ? "이전 달" : "이전 해")
                
                Button("오늘") { month = Date() }
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(tone(.accent))
                
                Button { step(by: 1) } label: {
                    Image(systemName: "chevron.right")
                }
                .accessibilityLabel(mode == .month ? "다음 달" : "다음 해")
            }
            .buttonStyle(.plain)
            .foregroundStyle(tone(.ink))
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(tone(.cardSurface), in: Capsule())
            .overlay(Capsule().stroke(tone(.line)))
            .shadow(color: .black.opacity(0.08), radius: 6, y: 2)
        }
    }
    
    // MARK: - Helpers
    
    private func tone(_ color: AppColor) -> Color {
        color.color(colorScheme: colorScheme)
    }
    
    private func weekdayColor(_ index: Int, isHoliday: Bool = false, defaultColor: AppColor = .muted) -> Color {
        if index == 0 || isHoliday { return tone(.sundayRed) }
        if index == 6 { return tone(.saturdayBlue) }
        return tone(defaultColor)
    }
    
    private func step(by value: Int) {
        let component: Calendar.Component = mode == .month ? .month : .year
        guard let next = calendar.date(byAdding: component, value: value, to: month) else { return }
        month = next
    }
}

#Preview("Light") {
    @Previewable @State var month = SampleData.october
    @Previewable @State var selectedDate: Date?
    CalendarView(month: $month, todos: SampleData.todos, holidays: SampleData.holidays,
                 selectedDate: $selectedDate, isSelectingDate: false)
}

#Preview("Dark") {
    @Previewable @State var month = SampleData.october
    @Previewable @State var selectedDate: Date?
    CalendarView(month: $month, todos: SampleData.todos, holidays: SampleData.holidays,
                 selectedDate: $selectedDate, isSelectingDate: false)
    .preferredColorScheme(.dark)
}

#Preview("Selecting") {
    @Previewable @State var month = SampleData.october
    @Previewable @State var selectedDate: Date? = CalendarSupport.date(2026, 10, 23)
    CalendarView(month: $month, todos: SampleData.todos, holidays: SampleData.holidays,
                 selectedDate: $selectedDate, isSelectingDate: true)
}

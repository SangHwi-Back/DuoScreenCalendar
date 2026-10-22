//
//  CalendarModels.swift
//  DuoScreenCalendar
//
//  Created by 백상휘 on 10/21/26.
//

import SwiftUI

// MARK: - Category

enum TodoCategory {
    case work
    case health
    case personal
    
    var title: String {
        switch self {
        case .work: "업무"
        case .health: "건강"
        case .personal: "개인"
        }
    }
    
    var appColor: AppColor {
        switch self {
        case .work: .work
        case .health: .health
        case .personal: .personal
        }
    }
    
    /// 라이트 모드의 카테고리 색은 칩 배경색, 다크 모드의 카테고리 색은 글자색으로 설계되어 있다.
    func chipColors(colorScheme: ColorScheme) -> (foreground: Color, background: Color) {
        let tint = appColor.color(colorScheme: colorScheme)
        if colorScheme == .dark {
            return (tint, tint.opacity(0.18))
        }
        return (AppColor.ink.color(colorScheme: colorScheme).opacity(0.75), tint)
    }
}

// MARK: - Items

struct ChecklistItem: Identifiable {
    let id = UUID()
    var title: String
    var isDone = false
}

struct TodoItem: Identifiable, Hashable {
    let id = UUID()
    var title: String
    /// 달력 칩처럼 좁은 곳에 쓰는 짧은 이름
    var shortTitle: String?
    var dueDate: Date?
    var hasTime = false
    /// 할일이 속한 달 (날짜가 미정이어도 달은 정해져 있다)
    var month: Date
    var category: TodoCategory
    var isDone = false
    /// true이면 `month`가 속한 해 전체에 걸친 할일이다 (날짜·달 미정).
    var isYearly = false
    var memo = ""
    var checklist: [ChecklistItem] = []
    
    func subtitle() -> String {
        let monthNumber = CalendarSupport.calendar.component(.month, from: month)
        guard let dueDate else {
            if isYearly {
                let year = CalendarSupport.calendar.component(.year, from: month)
                return "\(String(year))년 중 · 날짜 미정"
            }
            return "\(monthNumber)월 중 · 날짜 미정"
        }
        
        let day = CalendarSupport.dayFormatter.string(from: dueDate)
        guard hasTime else { return day }
        return "\(day) · \(CalendarSupport.timeFormatter.string(from: dueDate))"
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct Holiday {
    let date: Date
    let name: String
}

// MARK: - Calendar helpers

enum CalendarSupport {
    /// 일요일 시작 그레고리력. 달력 헤더(일~토)와 항상 일치하도록 고정한다.
    static let calendar = Calendar(identifier: .gregorian)
    
    static let weekdaySymbols = ["일", "월", "화", "수", "목", "금", "토"]
    
    static let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "M월 d일 (E)"
        return formatter
    }()
    
    static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "a h:mm"
        return formatter
    }()
    
    private static let englishMonthFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "MMMM"
        return formatter
    }()
    
    static func date(_ year: Int, _ month: Int, _ day: Int, hour: Int = 0) -> Date {
        let components = DateComponents(year: year, month: month, day: day, hour: hour)
        return calendar.date(from: components) ?? Date()
    }
    
    static func englishMonthName(of date: Date) -> String {
        englishMonthFormatter.string(from: date).uppercased()
    }
    
    static func isCurrentMonth(_ date: Date) -> Bool {
        calendar.isDate(date, equalTo: Date(), toGranularity: .month)
    }

    /// "이번 달" 또는 "N월"
    static func monthLabel(for month: Date) -> String {
        isCurrentMonth(month) ? "이번 달" : "\(calendar.component(.month, from: month))월"
    }

    /// 할일 추가 시트를 열 때 기본으로 선택되는 날짜: 이번 달이면 오늘, 아니면 그 달의 1일
    static func defaultTodoDate(in month: Date) -> Date {
        if isCurrentMonth(month) { return Date() }
        return calendar.dateInterval(of: .month, for: month)?.start ?? month
    }
    
    /// 한 달을 주 단위(7칸)로 나눈다. 달에 속하지 않는 칸은 nil이다.
    static func weeks(in month: Date) -> [[Date?]] {
        guard let interval = calendar.dateInterval(of: .month, for: month),
              let dayCount = calendar.range(of: .day, in: .month, for: month)?.count
                else { return [] }
        
        let leadingBlanks = calendar.component(.weekday, from: interval.start) - calendar.firstWeekday
        var cells: [Date?] = Array(repeating: nil, count: leadingBlanks)
        for offset in 0..<dayCount {
            cells.append(calendar.date(byAdding: .day, value: offset, to: interval.start))
        }
        while cells.count % 7 != 0 {
            cells.append(nil)
        }
        return stride(from: 0, to: cells.count, by: 7).map { Array(cells[$0..<$0 + 7]) }
    }
}

// MARK: - Sample data

enum SampleData {
    static let october = CalendarSupport.date(2026, 10, 1)
    
    static let todos: [TodoItem] = [
        TodoItem(title: "분기 보고서 초안 작성", shortTitle: "보고서",
                 dueDate: CalendarSupport.date(2026, 10, 22), month: october, category: .work,
                 memo: "3분기 매출·비용 요약과 다음 분기 계획을 함께 정리하기. 금요일 팀 회의 전에 공유.",
                 checklist: [
                    ChecklistItem(title: "3분기 매출 데이터 정리", isDone: true),
                    ChecklistItem(title: "비용 항목 전년 대비 비교"),
                    ChecklistItem(title: "다음 분기 계획 초안"),
                 ]),
        TodoItem(title: "치과 정기검진", shortTitle: "치과",
                 dueDate: CalendarSupport.date(2026, 10, 24, hour: 15), hasTime: true,
                 month: october, category: .health),
        TodoItem(title: "자동차 보험 갱신", shortTitle: "보험 갱신",
                 dueDate: CalendarSupport.date(2026, 10, 28), month: october, category: .personal),
        TodoItem(title: "독서 모임 발제 준비", shortTitle: "독서 모임",
                 dueDate: CalendarSupport.date(2026, 10, 30), month: october, category: .personal),
        TodoItem(title: "겨울 옷 정리", month: october, category: .personal),
        TodoItem(title: "여권사진", dueDate: CalendarSupport.date(2026, 10, 8),
                 month: october, category: .personal, isDone: true),
        TodoItem(title: "관리비", dueDate: CalendarSupport.date(2026, 10, 10),
                 month: october, category: .personal, isDone: true),
        TodoItem(title: "선물", dueDate: CalendarSupport.date(2026, 10, 14),
                 month: october, category: .personal, isDone: true),
    ]
    
    static let holidays: [Holiday] = [
        Holiday(date: CalendarSupport.date(2026, 10, 3), name: "개천절"),
        Holiday(date: CalendarSupport.date(2026, 10, 5), name: "대체휴일"),
        Holiday(date: CalendarSupport.date(2026, 10, 9), name: "한글날"),
    ]
}

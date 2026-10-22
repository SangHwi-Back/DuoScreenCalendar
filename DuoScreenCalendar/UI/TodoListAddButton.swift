//
//  TodoListAddButton.swift
//  DuoScreenCalendar
//
//  Created by 백상휘 on 10/22/26.
//

import SwiftUI

struct TodoListAddButton: View {
    @Environment(\.colorScheme) private var colorScheme
    
    private let presentAddTodo: () -> Void
    private let monthLabel: String
    private let isCompact: Bool
    
    init(presentAddTodo: @escaping () -> Void, monthLabel: String, isCompact: Bool = true) {
        self.presentAddTodo = presentAddTodo
        self.monthLabel = monthLabel
        self.isCompact = isCompact
    }
    
    var body: some View {
        Button(action: presentAddTodo) {
            if isCompact {
                Label("\(monthLabel) 할일 추가", systemImage: "plus")
                    .font(.headline)
                    .foregroundStyle(tone(.paperBackground))
                    .background(tone(.ink), in: Capsule())
            }
            else {
                Label("\(monthLabel) 할일 추가", systemImage: "plus")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, isCompact ? 0 : 16)
                    .foregroundStyle(tone(.paperBackground))
                    .background(tone(.ink), in: Capsule())
            }
        }
        .buttonStyle(.plain)
    }
    
    private func tone(_ color: AppColor) -> Color {
        color.color(colorScheme: colorScheme)
    }
}

#Preview {
    TodoListAddButton(presentAddTodo: {}, monthLabel: "이번 달")
}

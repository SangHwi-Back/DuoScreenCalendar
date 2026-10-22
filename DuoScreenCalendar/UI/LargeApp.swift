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
    @Environment(\.hingeStatus) private var hingeStatus
    
    @State private var viewModel: LargeAppViewModel
    
    init(todos: [TodoItem], month: Date) {
        _viewModel = State(wrappedValue: LargeAppViewModel(todos: todos, month: month))
    }
    
    var body: some View {
        if viewModel.arrangementViewType == .overlay {
            LargeOverlayView(viewModel: $viewModel)
        } else {
            LargeSplitView(viewModel: $viewModel)
        }
    }
}

#Preview("Light") {
    LargeApp(
        todos: SampleData.todos,
        month: Date()
    )
}

#Preview("Dark") {
    LargeApp(
        todos: SampleData.todos,
        month: Date()
    )
    .preferredColorScheme(.dark)
}

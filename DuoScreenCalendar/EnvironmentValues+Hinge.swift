//
//  EnvironmentValues+Hinge.swift
//  DuoScreenCalendar
//
//  Created by 백상휘 on 10/22/26.
//

import SwiftUI

extension EnvironmentValues {
    /// `ContentView`가 `onHingeChange`로 추적하는 힌지 상태.
    /// 하위 화면(`LargeApp` 등)이 `@Environment(\.hingeStatus)`로 읽는다. 힌지가 없는 기기는 nil이다.
    @Entry var hingeStatus: DeviceHinge.Status?
}

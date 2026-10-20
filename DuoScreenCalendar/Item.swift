//
//  Item.swift
//  DuoScreenCalendar
//
//  Created by 백상휘 on 10/20/26.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}

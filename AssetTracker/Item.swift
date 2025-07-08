//
//  Item.swift
//  AssetTracker
//
//  Created by Park Jiho on 7/8/25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var id: UUID = UUID()
    var timestamp: Date
    var amount: Double
    
    init(timestamp: Date, amount: Double) {
        self.timestamp = timestamp
        self.amount = amount
    }
}

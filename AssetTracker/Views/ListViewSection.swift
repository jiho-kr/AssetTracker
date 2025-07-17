//
//  ListViewSection.swift
//  AssetTracker
//
//  Created by Park Jiho on 7/9/25.
//

import SwiftUI
import SwiftData

struct ListViewSection: View {
    var items: [Item]
    var onDelete: (IndexSet) -> Void

    var body: some View {
        let sortedItems = items.sorted { $0.timestamp > $1.timestamp }

        List {
            ForEach(sortedItems.indices, id: \.self) { index in
                let item = sortedItems[index]
                let nextAmount = index + 1 < sortedItems.count ? sortedItems[index + 1].amount : nil
                let difference = nextAmount.map { item.amount - $0 }

                HStack {
                    Text(item.timestamp, format: .dateTime.year().month().day())
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text("\(Int(item.amount))원")

                        if let diff = difference {
                            let millionUnit = Int(floor(diff / 1_000_000))
                            if millionUnit != 0 {
                                Text("\(millionUnit >= 0 ? "+" : "")\(millionUnit)M")
                                    .font(.caption)
                                    .foregroundColor(millionUnit > 0 ? .red : .blue)
                            }
                        }
                    }
                }
            }
            .onDelete(perform: onDelete)
        }
    }
}

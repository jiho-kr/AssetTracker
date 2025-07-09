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
        List {
            ForEach(items) { item in
                HStack {
                    Text(item.timestamp, format: .dateTime.year().month().day())
                    Spacer()
                    Text("\(Int(item.amount))원")
                }
            }
            .onDelete(perform: onDelete)
        }
    }
}

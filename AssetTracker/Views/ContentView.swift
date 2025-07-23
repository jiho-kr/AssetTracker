//
//  ContentView.swift
//  AssetTracker
//
//  Created by Park Jiho on 7/8/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Item.timestamp, order: .reverse) private var items: [Item]

    @State private var showAddSheet = false
    @State private var showChart: Bool = true
    @State private var selectedGrouping: ChartGrouping = .daily

    var body: some View {
        NavigationStack {
            Group {
                if showChart {
                    ChartViewSection(items: items, selectedGrouping: $selectedGrouping)
                } else {
                    ListViewSection(items: items, onDelete: deleteItems)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { showChart.toggle() }) {
                        Image(systemName: showChart ? "list.bullet" : "chart.line.uptrend.xyaxis")
                    }
                }
                ToolbarItem {
                    Button(action: { showAddSheet = true }) {
                        Label("Add Asset", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddSheet) {
                AddItemSheet { amount, date in
                    withAnimation {
                        if let existing = items.first(where: { Calendar.current.isDate($0.timestamp, equalTo: date, toGranularity: .day) }) {
                            existing.amount = amount
                        } else {
                            let newItem = Item(timestamp: date, amount: amount)
                            modelContext.insert(newItem)
                        }
                    }
                }
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }
}

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

//
//import SwiftUI
//import SwiftData
//import Charts
//
//enum ChartGrouping: String, CaseIterable, Identifiable {
//    case daily = "Daily"
//    case monthly = "Monthly"
//    case yearly = "Annually"
//    
//    var id: String { rawValue }
//}
//
//struct ContentView: View {
//    @Environment(\.modelContext) private var modelContext
//    @Query(sort: \Item.timestamp, order: .reverse) private var items: [Item]
//    
//    @State private var showAddSheet = false
//    @State private var showChart: Bool = true
//    @State private var selectedGrouping: ChartGrouping = .daily
//
//    var body: some View {
//        NavigationStack {
//            Group {
//                if showChart {  // Chart Mode
//                    ScrollView {
//                        Picker("단위", selection: $selectedGrouping) {
//                            ForEach(ChartGrouping.allCases) { group in
//                                Text(group.rawValue).tag(group)
//                            }
//                        }
//                        .pickerStyle(.segmented)
//                        .labelsHidden()
//                        .padding()
//                        
//                        Chart {
//                            ForEach(groupedData(), id: \.0) { group in
//                                LineMark(
//                                    x: .value("Date", group.0),
//                                    y: .value("Amount", group.1)
//                                )
//                                .interpolationMethod(.monotone)
//                                .foregroundStyle(.blue)
//                                PointMark(
//                                    x: .value("Date", group.0),
//                                    y: .value("Amount", group.1)
//                                )
//                                .foregroundStyle(.blue)
//                                .symbolSize(40)
//                            }
//                        }
//                        .chartYScale(domain: .automatic(includesZero: false))
//                        .chartYAxis {
//                            AxisMarks(position: .leading) { value in
//                                if let doubleValue = value.as(Double.self) {
//                                    let billion = doubleValue / 100_000_000
//                                    let formatted = String(format: "%.2f억", billion)
//                                    AxisValueLabel(formatted)
//                                }
//                            }
//                        }
//                        .frame(height: 250)
//                        .padding(.horizontal)
//                    }
//                } else {    // List Mode
//                    List {
//                        ForEach(items) { item in
//                            HStack {
//                                Text(item.timestamp, format: .dateTime.year().month().day())
//                                Spacer()
//                                Text("\(Int(item.amount))원")
//                            }
//                        }
//                        .onDelete(perform: deleteItems)
//                    }
//                }
//            }
//            .toolbar {
//                ToolbarItem(placement: .navigationBarLeading) {
//                        Button(action: { showChart.toggle() }) {
//                            Image(systemName: showChart ? "list.bullet" : "chart.line.uptrend.xyaxis")
//                        }
//                    }
//                ToolbarItem {
//                    Button(action: { showAddSheet = true }) {
//                        Label("Add Asset", systemImage: "plus")
//                    }
//                }
//            }
//            .sheet(isPresented: $showAddSheet) {
//                AddItemSheet { amount, date in
//                    withAnimation {
//                        if let existing = items.first(where: { Calendar.current.isDate($0.timestamp, equalTo: date, toGranularity: .day) }) {
//                            existing.amount = amount
//                        } else {
//                            let newItem = Item(timestamp: date, amount: amount)
//                            modelContext.insert(newItem)
//                        }
//                    }
//                }
//            }
//        }
//    }
//
//    private func deleteItems(offsets: IndexSet) {
//        withAnimation {
//            for index in offsets {
//                modelContext.delete(items[index])
//            }
//        }
//    }
//    
//    private func groupedData() -> [(Date, Double)] {
//        let calendar = Calendar.current
//
//        switch selectedGrouping {
//        case .daily:
//            return items
//                .map { (calendar.startOfDay(for: $0.timestamp), $0.amount) }
//                .sorted(by: { $0.0 < $1.0 })
//
//        case .monthly:
//            let grouped = Dictionary(grouping: items) { item in
//                let comps = calendar.dateComponents([.year, .month], from: item.timestamp)
//                return calendar.date(from: comps) ?? item.timestamp
//            }
//
//            return grouped
//                .compactMap { (_, items) in
//                    guard let latest = items.max(by: { $0.timestamp < $1.timestamp }) else { return nil }
//                    return (latest.timestamp, latest.amount)
//                }
//                .sorted(by: { $0.0 < $1.0 })
//
//        case .yearly:
//            let grouped = Dictionary(grouping: items) { item in
//                let comps = calendar.dateComponents([.year], from: item.timestamp)
//                return calendar.date(from: comps) ?? item.timestamp
//            }
//
//            return grouped
//                .compactMap { (_, items) in
//                    guard let latest = items.max(by: { $0.timestamp < $1.timestamp }) else { return nil }
//                    return (latest.timestamp, latest.amount)
//                }
//                .sorted(by: { $0.0 < $1.0 })
//        }
//    }
//}
//
//#Preview {
//    ContentView()
//        .modelContainer(for: Item.self, inMemory: true)
//}

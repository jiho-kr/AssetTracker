//
//  ChartViewSection.swift
//  AssetTracker
//
//  Created by Park Jiho on 7/9/25.
//

import SwiftUI
import Charts
import SwiftData

enum ChartGrouping: String, CaseIterable, Identifiable {
    case daily = "Daily"
    case monthly = "Monthly"
    case yearly = "Annually"

    var id: String { rawValue }
}

struct ChartViewSection: View {
    var items: [Item]
    @Binding var selectedGrouping: ChartGrouping

    private var groupedData: [(Date, Double)] {
        let calendar = Calendar.current
        let now = Date()

        switch selectedGrouping {
        case .daily:
            let oneYearAgo = calendar.date(byAdding: .year, value: -1, to: now)!

            return items
                .filter { $0.timestamp >= oneYearAgo }
                .map { (calendar.startOfDay(for: $0.timestamp), $0.amount) }
                .sorted(by: { $0.0 < $1.0 })

        case .monthly:
            let grouped = Dictionary(grouping: items) { item in
                let comps = calendar.dateComponents([.year, .month], from: item.timestamp)
                return calendar.date(from: comps) ?? item.timestamp
            }

            return grouped
                .compactMap { (_, items) in
                    guard let latest = items.max(by: { $0.timestamp < $1.timestamp }) else { return nil }
                    return (latest.timestamp, latest.amount)
                }
                .sorted(by: { $0.0 < $1.0 })

        case .yearly:
            let grouped = Dictionary(grouping: items) { item in
                let comps = calendar.dateComponents([.year], from: item.timestamp)
                return calendar.date(from: comps) ?? item.timestamp
            }

            return grouped
                .compactMap { (_, items) in
                    guard let latest = items.max(by: { $0.timestamp < $1.timestamp }) else { return nil }
                    return (latest.timestamp, latest.amount)
                }
                .sorted(by: { $0.0 < $1.0 })
        }
    }

    var body: some View {
        ScrollView {
            Picker("단위", selection: $selectedGrouping) {
                ForEach(ChartGrouping.allCases) { group in
                    Text(group.rawValue).tag(group)
                }
            }
            .pickerStyle(.segmented)
            .labelsHidden()
            .padding()

            Chart {
                ForEach(groupedData, id: \.0) { group in
                    LineMark(
                        x: .value("Date", group.0),
                        y: .value("Amount", group.1)
                    )
                    .interpolationMethod(.monotone)
                    .foregroundStyle(.blue)
                    PointMark(
                        x: .value("Date", group.0),
                        y: .value("Amount", group.1)
                    )
                    .foregroundStyle(.blue)
                    .symbolSize(40)
                }
            }
            .chartYScale(domain: .automatic(includesZero: false))
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    if let doubleValue = value.as(Double.self) {
                        let billion = doubleValue / 100_000_000
                        AxisValueLabel(String(format: "%.2f억", billion))
                    }
                }
            }
            .frame(height: 250)
            .padding(.horizontal)
        }
    }
}

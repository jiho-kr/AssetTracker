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

extension ChartGrouping {
    func next() -> ChartGrouping {
        let all = ChartGrouping.allCases
        if let index = all.firstIndex(of: self), index < all.count - 1 {
            return all[index + 1]
        }
        return self
    }

    func previous() -> ChartGrouping {
        let all = ChartGrouping.allCases
        if let index = all.firstIndex(of: self), index > 0 {
            return all[index - 1]
        }
        return self
    }
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
                .compactMap { (monthStart, items) in
                    guard let latest = items.max(by: { $0.timestamp < $1.timestamp }) else { return nil }
                    let comps = calendar.dateComponents([.year, .month], from: monthStart)
                    guard let monthDate = calendar.date(from: comps) else { return nil }
                    return (monthDate, latest.amount)
                }
                .sorted(by: { $0.0 < $1.0 })

        case .yearly:
            let grouped = Dictionary(grouping: items) { item in
                calendar.component(.year, from: item.timestamp)
            }

            return grouped
                .compactMap { (year, items) in
                    guard let latest = items.max(by: { $0.timestamp < $1.timestamp }) else { return nil }
                    let yearDate = calendar.date(from: DateComponents(year: year, month: 1, day: 1))
                    return yearDate.map { ($0, latest.amount) }
                }
                .sorted(by: { $0.0 < $1.0 })

        }
    }

    private var diffedData: [(Date, Double)] {
        var result: [(Date, Double)] = []
        let sorted = groupedData
        if let first = sorted.first {
            result.append((first.0, 0))
        }
        for i in 1..<sorted.count {
            let date = sorted[i].0
            let delta = sorted[i].1 - sorted[i - 1].1
            result.append((date, delta))
        }
        return result
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

            VStack(alignment: .leading, spacing: 32) {
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
                            AxisGridLine()
                                .foregroundStyle(Color.gray.opacity(0.2))
                            AxisValueLabel(String(format: "%d억", Int(billion)))
                        }
                    }
                }
                .frame(height: 150)
                .padding(.horizontal)

                Chart {
                    ForEach(diffedData, id: \.0) { group in
                        BarMark(
                            x: .value("Date", group.0),
                            y: .value("Delta", group.1)
                        )
                        .foregroundStyle(group.1 >= 0 ? .green : .red)
                        .opacity(0.7)
                    }
                }
                .chartYScale(domain: .automatic(includesZero: true))
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        if let doubleValue = value.as(Double.self) {
                            let million = doubleValue / 1_000_000
                            AxisGridLine()
                                .foregroundStyle(Color.gray.opacity(0.2))
                            AxisValueLabel(String(format: "%d백만", Int(million)))
                        }
                    }
                }
                .frame(height: 150)
                .padding(.horizontal)

                VStack(alignment: .leading, spacing: 8) {
                    let maxAmount = groupedData.map(\.1).max() ?? 0

                    ForEach(diffedData.sorted(by: { $0.0 > $1.0 }).prefix(13), id: \.0) { entry in
                        HStack {
                            Text(dateFormatter.string(from: entry.0))
                                            .font(.caption)
                                            .frame(width: 80, alignment: .leading)

                            let amount = groupedData.first(where: { $0.0 == entry.0 })?.1 ?? 0
                            let amountInMillions = Int(amount / 1_000_000)
                            let deltaInMillions = Int(entry.1 / 1_000_000)
                            let sign = deltaInMillions >= 0 ? "+" : ""
                            let color = deltaInMillions >= 0 ? Color.red : Color.blue

                            Text("\(amountInMillions.formatted(.number.grouping(.automatic)))M")
                                .font(.caption)

                            Text("\(sign)\(deltaInMillions)M")
                                .foregroundColor(color)
                                .font(.caption)
                            
                            Spacer()

                            let diffFromMax = amount - maxAmount
                            let diffFromMaxInMillions = Int(diffFromMax / 1_000_000)
                            let maxSign = diffFromMaxInMillions >= 0 ? "+" : ""

                            Text("\(maxSign)\(diffFromMaxInMillions)M")
                                .font(.caption)
                                .foregroundColor(diffFromMaxInMillions >= 0 ? .green : .gray)

                            
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.bottom)

            }
            .padding(.bottom)
            .gesture(
                DragGesture()
                    .onEnded { value in
                        let threshold: CGFloat = 50
                        if value.translation.width < -threshold {
                            withAnimation {
                                selectedGrouping = selectedGrouping.next()
                            }
                        } else if value.translation.width > threshold {
                            withAnimation {
                                selectedGrouping = selectedGrouping.previous()
                            }
                        }
                    }
            )
        }
    }
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy.MM.dd"
    formatter.locale = Locale(identifier: "ko_KR") // 한국식 고정
    return formatter
}()

//
//  AddItemSheet.swift
//  AssetTracker
//
//  Created by Park Jiho on 7/8/25.
//

import SwiftUI

struct AddItemSheet: View {
    @Environment(\.dismiss) var dismiss
    @State private var amountText: String = ""
    @State private var date: Date = Date()

    var onSave: (Double, Date) -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section("Price") {
                    TextField("예: 10.12 (10억 1200만원)", text: $amountText)
                        .keyboardType(.decimalPad)
                }
                Section("Date") {
                    DatePicker("기준 일자", selection: $date, displayedComponents: .date)
                    .labelsHidden()
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancle") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if let amount = Double(amountText) {
                            let amountInWon = amount * 100_000_000
                            onSave(amountInWon, date)
                            dismiss()
                        }
                    }
                }
            }
        }
    }
}

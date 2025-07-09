# AssetTracker 📈

A simple SwiftUI app for tracking personal assets over time.  
It lets you enter your daily net worth and visualize the trend using line and bar charts, **stored locally using SwiftData** — no server or cloud required.

---

## Features

- 📅 Record daily asset values with date and amount
- 📊 View trends in:
  - Daily
  - Monthly (end-of-month values)
  - Yearly (end-of-year values)
- 📈 Line chart showing total assets
- 📉 Bar chart showing period-to-period changes (gain/loss)
- 🔄 Swipe to delete or overwrite existing dates
- 💾 Data is stored **locally on your device** using SwiftData (iOS 17+)
- 🎨 Simple and minimal interface
- 🧪 Supports both iPhone and macOS (via Catalyst)

---

## Requirements

- Xcode 15+
- iOS 17+ / macOS 14+
- Swift 5.9+
- SwiftData (no CoreData or external DBs)

---

## Getting Started

1. Clone the repository:

   ```bash
   git clone https://github.com/your-username/AssetTracker.git
   cd AssetTracker

# AGENTS.md - Developer Guide for AI Agents (iOS Branch)

Welcome to **LogKit iOS**! This file serves as the definitive reference manual and coding guidelines for AI Agents working on the iOS Swift codebase of this repository.

---

## 🎯 Project Mission & Vision

**LogKit iOS** is a pure Swift, SwiftUI-native logger for iOS / macOS with an in-app inspection UI console.

### Key Architectural Principles
1. **100% Pure Swift & Idiomatic**: Modern Swift 5.9 / 6 concurrency-safe patterns, zero external 3rd-party dependencies.
2. **Minimalist Architecture**: Clean, highly maintainable codebase aligned with Android's architecture.
3. **SwiftUI Native UI**: Dark & Light dual-theme SwiftUI console for mobile and desktop debugging.
4. **Swift Package Manager**: Managed via `Package.swift`.

---

## 📐 Architecture & Core Components

```
Sources/LogKit/
├── LogKit.swift                       # Unified Swift Singleton Facade & Entry Point
├── LoggerPrinter.swift                # Core Formatting & Dispatch Engine (ThreadDictionary tag isolation)
├── LogAdapter.swift                   # Protocol & Factory Constructors
├── Utils.swift                        # Priorities & String / Stacktrace formatting
├── Strategy/
│   ├── FormatStrategy.swift           # Output Formatting Strategy Protocol
│   ├── LogStrategy.swift              # Log Strategy Protocol & OSLog / Print Console
│   ├── PrettyFormatStrategy.swift     # Box Border, Thread & StackTrace Formatter
│   ├── CsvFormatStrategy.swift        # CSV Storage Formatter for Disk Persistence
│   └── DiskLogWriteReadStrategy.swift # Background Serial DispatchQueue Disk Persistence (500KB Split, 3000-line read)
└── UI/
    ├── LogInfo.swift                  # Log Data Structure (Identifiable, Sendable)
    ├── LogViewModel.swift             # ObservableObject & Combine Data Binding
    └── LogScreen.swift                # SwiftUI Log Inspection Console (Full Feature Parity with Android)
```

---

## 💡 Key UI & Interactive Features

When extending or modifying `LogScreen.swift`, strictly preserve the following user-centric UX designs:

1. **Priority Level Multi-Select Filter**:
   - Interactive `ALL`, `V`, `D`, `I`, `W`, `E` chips with explicit count badge `(X/5)`.
   - Distinct brand colors for each priority (`VERBOSE` gray, `DEBUG` blue, `INFO` green, `WARN` orange, `ERROR` red).
2. **Tag Search & Highlight**:
   - Grid-based `TagSelectionDialog` with real-time text matching and yellow background highlight (`Color(red: 1.0, green: 0.835, blue: 0.31)`).
3. **Dual Themes (Light & Dark)**:
   - Dynamic `☀️` / `🌙` theme toggle supporting high-contrast Dark (`#121212`) and Light (`#F5F5F5`) palettes.
4. **Collapsible Header**:
   - Ability to toggle or collapse Header to unleash **100% full-screen Log viewing area** with a floating expand trigger.
5. **Click-to-Copy**:
   - Tap any log card to copy formatted log entry to the system clipboard with toast feedback.

---

## 🛠 Build & Verification Commands

AI Agents MUST run the build verification command after modifying code:

```bash
swift test
```

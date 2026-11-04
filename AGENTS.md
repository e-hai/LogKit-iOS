# AGENTS.md - Developer Guide for AI Agents (iOS Repository)

Welcome to **LogKit iOS**! This file serves as the definitive reference manual and coding guidelines for AI Agents (such as Antigravity, AGY, Cursor, Copilot, etc.) working on the iOS Swift codebase of this repository.

> 💡 **Notice**: The Android Kotlin codebase is maintained in a dedicated independent repository: [LogKit-Android](https://github.com/e-hai/LogKit-Android).

---

## 🎯 Project Mission & Architectural Principles

**LogKit iOS** is a pure Swift, SwiftUI-native logger for iOS / macOS with an in-app inspection UI console.

### Key Architectural Guidelines
1. **100% Pure Swift & Idiomatic**: Modern Swift 5.9 / 6 concurrency-safe patterns (`Sendable`, `@MainActor`), zero external 3rd-party dependencies.
2. **Minimalist Architecture**: Highly cohesive, minimal abstraction layers, designed with full parity against the Android architecture.
3. **SwiftUI Native UI**: Dark (`#121212`) & Light (`#F5F5F5`) dual-theme SwiftUI console for mobile and desktop debugging.
4. **Swift Package Manager**: Standard SPM package configured via `Package.swift` with macOS and iOS support.
5. **Xcode Demo App**: Self-contained `LogKitDemo.xcodeproj` in the repository root referencing the local `LogKit` package.

---

## 📐 Component Architecture

```
LogKit-iOS/
├── Package.swift                      # SPM Package Definition (iOS 15+, macOS 12+)
├── LogKitDemo.xcodeproj               # Xcode Demo Project for Simulator & Devices
├── Sample/
│   ├── SampleApp.swift                # Demo Application Entry Point (@main)
│   └── ContentView.swift              # Feature-rich Demo Dashboard (Interval, Burst, Crash, Sheet Trigger)
├── Sources/LogKit/
│   ├── LogKit.swift                   # Unified Swift Singleton Facade & Entry Point
│   ├── LoggerPrinter.swift            # Core Formatting & Dispatch Engine (ThreadDictionary tag isolation)
│   ├── LogAdapter.swift               # Protocol & Factory Constructors
│   ├── Utils.swift                    # Priorities & String / StackTrace formatting
│   ├── Strategy/
│   │   ├── FormatStrategy.swift       # Output Formatting Strategy Protocol
│   │   ├── LogStrategy.swift          # Log Strategy Protocol & OSLog / Print Console
│   │   ├── PrettyFormatStrategy.swift # Box Border, Thread & StackTrace Formatter
│   │   ├── CsvFormatStrategy.swift    # CSV Storage Formatter for Disk Persistence
│   │   └── DiskLogWriteReadStrategy.swift # Background Serial DispatchQueue Disk Persistence (500KB Split, 3000-line reverse read)
│   └── UI/
│       ├── LogInfo.swift              # Log Data Structure (Identifiable, Sendable)
│       ├── LogViewModel.swift         # ObservableObject & Combine Data Binding (Tag & Level Filters)
│       └── LogScreen.swift            # SwiftUI Log Inspection Console (Full Feature Parity with Android)
└── Tests/
    └── LogKitTests/
        └── LogKitTests.swift          # Core XCTest Suite
```

---

## 💡 UX & UI Standards (Strict Preservation)

When extending or modifying `LogScreen.swift`, AI Agents MUST strictly preserve:

1. **Tag Filtering & Grid Search Dialog**:
   - Multi-tag set filtering with active chips and clear button.
   - Tags sorted alphabetically (natural dictionary order, NO dynamic frequency reordering).
   - Collapsible tag container with `展开 (N)` / `收起` toggle.
   - `TagSelectionDialog` supporting real-time text matching and yellow background highlighting (`Color(red: 1.0, green: 0.835, blue: 0.31)`).
2. **Priority Level Multi-Select Filter**:
   - Interactive `ALL`, `V`, `D`, `I`, `W`, `E` chips with explicit count badge `(X/5)`.
   - Distinct brand colors for each priority (`VERBOSE` gray, `DEBUG` blue, `INFO` green, `WARN` orange, `ERROR` red).
3. **Dual Themes (Light & Dark)**:
   - Dynamic `☀️` / `🌙` theme toggle supporting high-contrast Dark (`#121212`) and Light (`#F5F5F5`) palettes.
4. **Manual Collapse Button**:
   - Header collapsed explicitly via top-right button (`chevron.up.circle.fill` / `chevron.down.circle.fill`).
   - **NO automatic collapsing on list scroll** (maintains predictable reading context).
   - Floating action trigger to restore header when collapsed.
5. **Click-to-Copy**:
   - Tap any log card to copy formatted log entry to the system clipboard with toast feedback.
6. **Cross-Platform Compatibility**:
   - Ensure conditional compilation checks (`#if os(iOS)`) guard iOS-only APIs such as `navigationBarTitleDisplayMode` to keep macOS builds passing.

---

## 🛠 Build & Verification Commands

AI Agents MUST run the build verification commands after modifying code:

```bash
# 1. Run unit test suite
swift test

# 2. Verify Demo Xcode project build
xcodebuild -project LogKitDemo.xcodeproj -scheme LogKitDemo -destination 'generic/platform=iOS Simulator' build
```

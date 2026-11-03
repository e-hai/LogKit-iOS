import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

// MARK: - Color Extension Helper

private extension Color {
    init(hex: UInt32, alpha: Double = 1.0) {
        let red = Double((hex >> 16) & 0xFF) / 255.0
        let green = Double((hex >> 8) & 0xFF) / 255.0
        let blue = Double(hex & 0xFF) / 255.0
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: alpha)
    }
}

// MARK: - Theme Definition

private struct LogThemeColors {
    let isDark: Bool
    let background: Color
    let appBarBackground: Color
    let filterBarBackground: Color
    let chipBackground: Color
    let cardBackground: Color
    let textPrimary: Color
    let textSecondary: Color
    let dividerColor: Color
    let dialogBackground: Color
}

private let darkThemeColors = LogThemeColors(
    isDark: true,
    background: Color(hex: 0x121212),
    appBarBackground: Color(hex: 0x1A1A1A),
    filterBarBackground: Color(hex: 0x161616),
    chipBackground: Color(hex: 0x2A2A2A),
    cardBackground: Color(hex: 0x1E1E1E),
    textPrimary: Color(hex: 0xE0E0E0),
    textSecondary: Color(hex: 0xA0A0A0),
    dividerColor: Color(hex: 0x2C2C2C),
    dialogBackground: Color(hex: 0x1E1E1E)
)

private let lightThemeColors = LogThemeColors(
    isDark: false,
    background: Color(hex: 0xF5F5F5),
    appBarBackground: Color(hex: 0xFFFFFF),
    filterBarBackground: Color(hex: 0xEAEAEA),
    chipBackground: Color(hex: 0xE8E8E8),
    cardBackground: Color(hex: 0xFFFFFF),
    textPrimary: Color(hex: 0x212121),
    textSecondary: Color(hex: 0x666666),
    dividerColor: Color(hex: 0xE0E0E0),
    dialogBackground: Color(hex: 0xFFFFFF)
)

// MARK: - LogScreen View

public struct LogScreen: View {
    @StateObject private var viewModel: LogViewModel
    private let onBackClick: () -> Void

    @State private var isDarkTheme: Bool = true
    @State private var showTagDialog: Bool = false
    @State private var isHeaderVisible: Bool = true
    @State private var toastMessage: String? = nil

    private let allLevels = ["VERBOSE", "DEBUG", "INFO", "WARN", "ERROR"]

    public init(viewModel: LogViewModel = LogViewModel(), onBackClick: @escaping () -> Void = {}) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.onBackClick = onBackClick
    }

    private var themeColors: LogThemeColors {
        isDarkTheme ? darkThemeColors : lightThemeColors
    }

    public var body: some View {
        ZStack {
            themeColors.background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Collapsible Header
                if isHeaderVisible {
                    headerView
                        .transition(.move(edge: .top).combined(with: .opacity))
                }

                // Main Log List
                let displayed = viewModel.displayedLogs
                if displayed.isEmpty {
                    Spacer()
                    VStack(spacing: 8) {
                        Image(systemName: "tray")
                            .font(.system(size: 40))
                            .foregroundColor(themeColors.textSecondary)
                        Text("暂无相关日志记录")
                            .foregroundColor(themeColors.textSecondary)
                            .font(.system(size: 15))
                    }
                    Spacer()
                } else {
                    ScrollViewReader { _ in
                        ScrollView {
                            LazyVStack(spacing: 8) {
                                ForEach(displayed) { logInfo in
                                    LogItemCard(
                                        logInfo: logInfo,
                                        themeColors: themeColors,
                                        onCopy: { copyLog(logInfo) }
                                    )
                                }
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 8)
                        }
                    }
                }
            }

            // Floating Uncollapse Button when header is hidden
            if !isHeaderVisible {
                VStack {
                    HStack {
                        Spacer()
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                isHeaderVisible = true
                            }
                        }) {
                            Image(systemName: "slider.horizontal.3")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 36, height: 36)
                                .background(Color.blue)
                                .clipShape(Circle())
                                .shadow(radius: 4)
                        }
                        .padding(.trailing, 16)
                        .padding(.top, 10)
                    }
                    Spacer()
                }
            }

            // Toast Alert
            if let toast = toastMessage {
                VStack {
                    Spacer()
                    Text(toast)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color.black.opacity(0.8))
                        .cornerRadius(20)
                        .padding(.bottom, 30)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
        .sheet(isPresented: $showTagDialog) {
            TagSelectionDialog(
                tags: viewModel.tags,
                selectedTag: viewModel.selectedTag,
                themeColors: themeColors,
                onSelectTag: { tag in
                    viewModel.selectTag(tag)
                    showTagDialog = false
                },
                onDismiss: { showTagDialog = false }
            )
        }
    }

    // MARK: - Header Components

    private var headerView: some View {
        VStack(spacing: 0) {
            // Navigation Bar
            HStack(spacing: 12) {
                Button(action: onBackClick) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(themeColors.textPrimary)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("LogKit 日志控制台")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(themeColors.textPrimary)
                    Text("Tag: \(viewModel.selectedTag) (\(viewModel.displayedLogs.count)/\(viewModel.logs.count) 条)")
                        .font(.system(size: 12))
                        .foregroundColor(themeColors.textSecondary)
                }

                Spacer()

                // Theme Toggle
                Button(action: { isDarkTheme.toggle() }) {
                    Text(isDarkTheme ? "☀️" : "🌙")
                        .font(.system(size: 18))
                }

                // Tag List Dialog
                Button(action: { showTagDialog = true }) {
                    Image(systemName: "tag")
                        .font(.system(size: 18))
                        .foregroundColor(viewModel.selectedTag != LogViewModel.tagShowAllLog ? .blue : themeColors.textPrimary)
                }

                // Collapse Header
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        isHeaderVisible = false
                    }
                }) {
                    Image(systemName: "chevron.up")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(themeColors.textSecondary)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 8)
            .background(themeColors.appBarBackground)

            // Priority Filter Bar
            HStack(spacing: 6) {
                Text("级别 (\(viewModel.selectedLevels.count)/\(allLevels.count)):")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(viewModel.selectedLevels.count < allLevels.count ? .blue : themeColors.textSecondary)

                // ALL Chip
                let isAll = viewModel.selectedLevels.count == allLevels.count
                Button(action: {
                    viewModel.selectAllLevels(all: allLevels)
                }) {
                    Text("ALL")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(isAll ? .white : themeColors.textSecondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(isAll ? Color.blue : themeColors.chipBackground)
                        .cornerRadius(6)
                }

                // V, D, I, W, E Chips
                ForEach(allLevels, id: \.self) { level in
                    let isSelected = viewModel.selectedLevels.contains(level)
                    let color = getPriorityColor(level)
                    let short = getShortName(level)

                    Button(action: {
                        viewModel.toggleLevel(level)
                    }) {
                        Text(isSelected ? "✓ \(short)" : short)
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(isSelected ? .white : (themeColors.isDark ? Color(hex: 0x777777) : Color(hex: 0x999999)))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(isSelected ? color : themeColors.chipBackground)
                            .cornerRadius(6)
                    }
                }

                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(themeColors.filterBarBackground)

            // Tag Horizontal Quick Bar
            if !viewModel.tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(viewModel.tags, id: \.self) { tag in
                            let isSelected = tag == viewModel.selectedTag
                            Button(action: {
                                viewModel.selectTag(tag)
                            }) {
                                Text(tag)
                                    .font(.system(size: 12, weight: isSelected ? .bold : .regular))
                                    .foregroundColor(isSelected ? .white : themeColors.textPrimary)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(isSelected ? Color.blue : themeColors.chipBackground)
                                    .cornerRadius(12)
                            }
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                }
                .background(themeColors.filterBarBackground)
            }

            Rectangle()
                .fill(themeColors.dividerColor)
                .frame(height: 1)
        }
    }

    private func copyLog(_ log: LogInfo) {
        let content = "\(log.dateString) [\(log.priority)] \(log.tag): \(log.message)"
        #if canImport(UIKit)
        UIPasteboard.general.string = content
        #elseif canImport(AppKit)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(content, forType: .string)
        #endif

        withAnimation {
            toastMessage = "已复制日志至剪贴板"
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation {
                toastMessage = nil
            }
        }
    }

    private func getShortName(_ level: String) -> String {
        switch level {
        case "VERBOSE": return "V"
        case "DEBUG":   return "D"
        case "INFO":    return "I"
        case "WARN":    return "W"
        case "ERROR":   return "E"
        default:        return level
        }
    }
}

// MARK: - LogItemCard

private struct LogItemCard: View {
    let logInfo: LogInfo
    let themeColors: LogThemeColors
    let onCopy: () -> Void

    var body: some View {
        Button(action: onCopy) {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    // Priority Badge
                    let pColor = getPriorityColor(logInfo.priority)
                    Text(logInfo.priority)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(pColor)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(pColor.opacity(0.18))
                        .cornerRadius(4)

                    // Tag
                    Text(logInfo.tag)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.blue)

                    Spacer()

                    // Timestamp
                    Text(logInfo.dateString)
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(themeColors.textSecondary)
                }

                // Message Text
                Text(logInfo.message)
                    .font(.system(size: 13, design: .monospaced))
                    .foregroundColor(themeColors.textPrimary)
                    .multilineTextAlignment(.leading)
                    .lineSpacing(2)
            }
            .padding(10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(themeColors.cardBackground)
            .cornerRadius(8)
            .shadow(color: Color.black.opacity(themeColors.isDark ? 0.3 : 0.06), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - TagSelectionDialog

private struct TagSelectionDialog: View {
    let tags: [String]
    let selectedTag: String
    let themeColors: LogThemeColors
    let onSelectTag: (String) -> Void
    let onDismiss: () -> Void

    @State private var query: String = ""

    private var filteredTags: [String] {
        if query.trimmingCharacters(in: .whitespaces).isEmpty {
            return tags
        }
        return tags.filter { $0.localizedCaseInsensitiveContains(query) }
    }

    private let columns = [
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8)
    ]

    var body: some View {
        NavigationView {
            ZStack {
                themeColors.dialogBackground
                    .ignoresSafeArea()

                VStack(spacing: 12) {
                    // Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(themeColors.textSecondary)
                        TextField("输入 Tag 名称过滤...", text: $query)
                            .foregroundColor(themeColors.textPrimary)
                        if !query.isEmpty {
                            Button(action: { query = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(themeColors.textSecondary)
                            }
                        }
                    }
                    .padding(8)
                    .background(themeColors.chipBackground)
                    .cornerRadius(8)
                    .padding(.horizontal, 16)
                    .padding(.top, 12)

                    // Tag Grid with Yellow Highlight
                    if filteredTags.isEmpty {
                        Spacer()
                        Text("未找到包含 \"\(query)\" 的 Tag")
                            .font(.system(size: 13))
                            .foregroundColor(themeColors.textSecondary)
                        Spacer()
                    } else {
                        ScrollView {
                            LazyVGrid(columns: columns, spacing: 8) {
                                ForEach(filteredTags, id: \.self) { tag in
                                    let isSelected = tag == selectedTag
                                    Button(action: { onSelectTag(tag) }) {
                                        highlightedText(text: tag, query: query)
                                            .font(.system(size: 13, weight: isSelected ? .bold : .regular))
                                            .foregroundColor(isSelected ? .white : themeColors.textPrimary)
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 8)
                                            .padding(.horizontal, 8)
                                            .background(isSelected ? Color.blue : themeColors.chipBackground)
                                            .cornerRadius(6)
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 6)
                        }
                    }
                }
            }
            .navigationTitle("查找并筛选 Tag")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("关闭", action: onDismiss)
                }
            }
        }
    }

    @ViewBuilder
    private func highlightedText(text: String, query: String) -> some View {
        if query.isEmpty {
            Text(text)
        } else if let range = text.range(of: query, options: .caseInsensitive) {
            let prefix = String(text[..<range.lowerBound])
            let match = String(text[range])
            let suffix = String(text[range.upperBound...])

            HStack(spacing: 0) {
                if !prefix.isEmpty { Text(prefix) }
                Text(match)
                    .background(Color(red: 1.0, green: 0.835, blue: 0.31)) // 亮黄色高亮
                    .foregroundColor(.black)
                    .font(.system(size: 13, weight: .bold))
                if !suffix.isEmpty { Text(suffix) }
            }
        } else {
            Text(text)
        }
    }
}

// MARK: - Priority Colors

private func getPriorityColor(_ priority: String) -> Color {
    switch priority.uppercased() {
    case "V", "VERBOSE": return Color(hex: 0x9E9E9E)
    case "D", "DEBUG":   return Color(hex: 0x03A9F4)
    case "I", "INFO":    return Color(hex: 0x4CAF50)
    case "W", "WARN":    return Color(hex: 0xFF9800)
    case "E", "ERROR":   return Color(hex: 0xF44336)
    case "ASSERT", "WTF":return Color(hex: 0xE91E63)
    default:             return Color(hex: 0xB0BEC5)
    }
}

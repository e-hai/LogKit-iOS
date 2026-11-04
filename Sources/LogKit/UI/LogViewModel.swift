import Foundation
import Combine

public final class LogViewModel: ObservableObject {
    public static let tagShowAllLog = "ALL TAG"

    @Published public private(set) var logs: [LogInfo] = []
    @Published public private(set) var tags: [String] = []

    // 多选 Tag 集合（空集合表示不过滤全选）
    @Published public var selectedTags: Set<String> = []
    @Published public var selectedLevels: Set<String> = ["VERBOSE", "DEBUG", "INFO", "WARN", "ERROR"]

    public init() {
        refresh()
    }

    public func refresh() {
        LogKit.readLog { [weak self] lines in
            guard let self = self else { return }
            var parsedLogs: [LogInfo] = []
            var foundTags = Set<String>()

            for line in lines {
                let parts = line.components(separatedBy: ",")
                if parts.count >= 4 {
                    let timestamp = Int64(parts[0]) ?? Int64(Date().timeIntervalSince1970 * 1000)
                    let dateString = parts[1]
                    let priority = parts[2]
                    let tag = parts[3]
                    let message = parts.count >= 5 ? parts[4...].joined(separator: ",") : ""

                    let info = LogInfo(
                        date: timestamp,
                        dateString: dateString,
                        priority: priority,
                        tag: tag,
                        message: message
                    )
                    parsedLogs.append(info)
                    foundTags.insert(tag)
                }
            }

            self.logs = parsedLogs
            // 保持自然字典排序
            var tagList = [Self.tagShowAllLog]
            tagList.append(contentsOf: foundTags.sorted())
            self.tags = tagList
        }
    }

    public var displayedLogs: [LogInfo] {
        return logs.filter { log in
            // Filter by Multi-Tags
            if !selectedTags.isEmpty && !selectedTags.contains(Self.tagShowAllLog) {
                if !selectedTags.contains(log.tag) {
                    return false
                }
            }
            // Filter by Level
            return isLevelSelected(log.priority, selectedLevels: selectedLevels)
        }
    }

    // 统计各 Level 在当前数据集中的条数
    public var levelCounts: [String: Int] {
        var counts: [String: Int] = ["VERBOSE": 0, "DEBUG": 0, "INFO": 0, "WARN": 0, "ERROR": 0]
        let baseLogs: [LogInfo]
        if !selectedTags.isEmpty && !selectedTags.contains(Self.tagShowAllLog) {
            baseLogs = logs.filter { selectedTags.contains($0.tag) }
        } else {
            baseLogs = logs
        }
        for log in baseLogs {
            let p = log.priority.uppercased()
            if p.contains("V") || p.contains("VERBOSE") { counts["VERBOSE", default: 0] += 1 }
            else if p.contains("D") || p.contains("DEBUG") { counts["DEBUG", default: 0] += 1 }
            else if p.contains("I") || p.contains("INFO") { counts["INFO", default: 0] += 1 }
            else if p.contains("W") || p.contains("WARN") { counts["WARN", default: 0] += 1 }
            else if p.contains("E") || p.contains("ERROR") { counts["ERROR", default: 0] += 1 }
        }
        return counts
    }

    public func toggleTag(_ tag: String) {
        if tag == Self.tagShowAllLog {
            selectedTags.removeAll()
        } else {
            selectedTags.remove(Self.tagShowAllLog)
            if selectedTags.contains(tag) {
                selectedTags.remove(tag)
            } else {
                selectedTags.insert(tag)
            }
        }
    }

    public func removeTag(_ tag: String) {
        selectedTags.remove(tag)
    }

    public func clearAllTags() {
        selectedTags.removeAll()
    }

    public func toggleLevel(_ level: String) {
        if selectedLevels.contains(level) {
            if selectedLevels.count > 1 {
                selectedLevels.remove(level)
            }
        } else {
            selectedLevels.insert(level)
        }
    }

    public func soloLevel(_ level: String, all: [String]) {
        if selectedLevels == [level] {
            // 已是独占状态，恢复全选
            selectedLevels = Set(all)
        } else {
            selectedLevels = [level]
        }
    }

    public func selectAllLevels(all: [String]) {
        selectedLevels = Set(all)
    }

    private func isLevelSelected(_ priority: String, selectedLevels: Set<String>) -> Bool {
        let norm = priority.uppercased()
        if norm.contains("V") || norm.contains("VERBOSE") { return selectedLevels.contains("VERBOSE") }
        if norm.contains("D") || norm.contains("DEBUG") { return selectedLevels.contains("DEBUG") }
        if norm.contains("I") || norm.contains("INFO") { return selectedLevels.contains("INFO") }
        if norm.contains("W") || norm.contains("WARN") { return selectedLevels.contains("WARN") }
        if norm.contains("E") || norm.contains("ERROR") { return selectedLevels.contains("ERROR") }
        return true
    }
}

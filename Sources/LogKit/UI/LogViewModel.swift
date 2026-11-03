import Foundation
import Combine

public final class LogViewModel: ObservableObject {
    public static let tagShowAllLog = "ALL TAG"

    @Published public private(set) var logs: [LogInfo] = []
    @Published public private(set) var tags: [String] = []
    @Published public var selectedTag: String = tagShowAllLog
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
            var tagList = [Self.tagShowAllLog]
            tagList.append(contentsOf: foundTags.sorted())
            self.tags = tagList
        }
    }

    public var displayedLogs: [LogInfo] {
        return logs.filter { log in
            // Filter by Tag
            if selectedTag != Self.tagShowAllLog && log.tag != selectedTag {
                return false
            }
            // Filter by Level
            return isLevelSelected(log.priority, selectedLevels: selectedLevels)
        }
    }

    public func selectTag(_ tag: String) {
        selectedTag = tag
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

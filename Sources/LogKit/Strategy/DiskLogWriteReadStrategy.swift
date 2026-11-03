import Foundation

public final class DiskLogWriteReadStrategy: LogStrategy {
    private static let maxReadLines = 3000
    private static let maxBytes = 500 * 1024 // 500KB
    private static let fileNamePrefix = "logs"

    private let folderPath: String
    private let queue: DispatchQueue

    public init(folderPath: String? = nil) {
        if let folderPath = folderPath {
            self.folderPath = folderPath
        } else {
            let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            let documentsDirectory = paths.first?.path ?? NSTemporaryDirectory()
            self.folderPath = (documentsDirectory as NSString).appendingPathComponent("logger")
        }
        self.queue = DispatchQueue(label: "com.kit.log.filelogger", qos: .utility)
    }

    public func log(priority: LogPriority, tag: String?, message: String) {
        queue.async { [weak self] in
            guard let self = self else { return }
            self.writeLog(content: message)
        }
    }

    public func readLog(completion: @escaping ([String]) -> Void) {
        queue.async { [weak self] in
            guard let self = self else {
                DispatchQueue.main.async { completion([]) }
                return
            }
            let logs = self.readRecentLogs()
            DispatchQueue.main.async {
                completion(logs)
            }
        }
    }

    private func writeLog(content: String) {
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: folderPath) {
            try? fileManager.createDirectory(atPath: folderPath, withIntermediateDirectories: true, attributes: nil)
        }

        let targetFile = getWriteLogFile()
        guard let data = content.data(using: .utf8) else { return }

        if fileManager.fileExists(atPath: targetFile.path) {
            if let fileHandle = try? FileHandle(forWritingTo: targetFile) {
                defer { try? fileHandle.close() }
                fileHandle.seekToEndOfFile()
                fileHandle.write(data)
            }
        } else {
            try? data.write(to: targetFile, options: .atomic)
        }
    }

    private func getWriteLogFile() -> URL {
        let folderURL = URL(fileURLWithPath: folderPath)
        let fileManager = FileManager.default

        var count = 0
        var existingFileURL: URL? = nil
        var newFileURL = folderURL.appendingPathComponent("\(Self.fileNamePrefix)_\(count).csv")

        while fileManager.fileExists(atPath: newFileURL.path) {
            existingFileURL = newFileURL
            count += 1
            newFileURL = folderURL.appendingPathComponent("\(Self.fileNamePrefix)_\(count).csv")
        }

        if let existing = existingFileURL {
            if let attrs = try? fileManager.attributesOfItem(atPath: existing.path),
               let size = attrs[.size] as? Int64,
               size >= Int64(Self.maxBytes) {
                return newFileURL
            }
            return existing
        }

        return newFileURL
    }

    private func readRecentLogs() -> [String] {
        let fileManager = FileManager.default
        guard fileManager.fileExists(atPath: folderPath) else {
            return []
        }

        guard let contents = try? fileManager.contentsOfDirectory(atPath: folderPath) else {
            return []
        }

        // Filter files matching logs_*.csv
        let csvFiles = contents.filter { $0.hasPrefix(Self.fileNamePrefix) && $0.hasSuffix(".csv") }
        guard !csvFiles.isEmpty else { return [] }

        // Sort descending by numeric index
        let sortedFiles = csvFiles.sorted { f1, f2 in
            let num1 = Int(f1.replacingOccurrences(of: "\(Self.fileNamePrefix)_", with: "").replacingOccurrences(of: ".csv", with: "")) ?? 0
            let num2 = Int(f2.replacingOccurrences(of: "\(Self.fileNamePrefix)_", with: "").replacingOccurrences(of: ".csv", with: "")) ?? 0
            return num2 < num1
        }

        var recentLogs: [String] = []

        for fileName in sortedFiles {
            let fileURL = URL(fileURLWithPath: folderPath).appendingPathComponent(fileName)
            guard let fileContent = try? String(contentsOf: fileURL, encoding: .utf8) else { continue }
            let lines = fileContent.components(separatedBy: "\n").filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }

            // Take from newest line to older line
            for line in lines.reversed() {
                recentLogs.append(line)
                if recentLogs.count >= Self.maxReadLines {
                    break
                }
            }

            if recentLogs.count >= Self.maxReadLines {
                break
            }
        }

        return recentLogs
    }
}

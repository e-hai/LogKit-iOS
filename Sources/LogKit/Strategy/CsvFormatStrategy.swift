import Foundation

public final class CsvFormatStrategy: FormatStrategy {
    private let dateFormatter: DateFormatter
    private let logStrategy: LogStrategy
    private let tag: String?

    private static let defaultTag = "LOG_KIT"
    private static let separator = ","
    private static let newLine = "\n"

    private init(builder: Builder) {
        self.dateFormatter = builder.dateFormatter
        self.logStrategy = builder.logStrategy
        self.tag = builder.tag
    }

    public func log(priority: LogPriority, onceOnlyTag: String?, message: String) {
        let formatTag = self.formatTag(onceOnlyTag)
        let now = Date()
        let timestamp = Int64(now.timeIntervalSince1970 * 1000)
        let dateString = dateFormatter.string(from: now)
        let levelName = Utils.logLevelName(priority)

        var builder = ""
        // 1. timestamp
        builder.append("\(timestamp)")
        builder.append(Self.separator)

        // 2. dateString
        builder.append(dateString)
        builder.append(Self.separator)

        // 3. level
        builder.append(levelName)
        builder.append(Self.separator)

        // 4. tag
        builder.append(formatTag ?? Self.defaultTag)
        builder.append(Self.separator)

        // 5. message (replace newline with space to keep CSV single line per log)
        let sanitizedMessage = message.replacingOccurrences(of: "\n", with: " ")
        builder.append(sanitizedMessage)
        builder.append(Self.newLine)

        logStrategy.log(priority: priority, tag: formatTag, message: builder)
    }

    private func formatTag(_ tag: String?) -> String? {
        if let tag = tag, !tag.isEmpty, self.tag != tag {
            return "\(self.tag ?? Self.defaultTag)-\(tag)"
        }
        return self.tag
    }

    public static func newBuilder() -> Builder {
        return Builder()
    }

    public final class Builder {
        fileprivate var dateFormatter: DateFormatter
        fileprivate var logStrategy: LogStrategy = ConsoleLogStrategy.shared
        fileprivate var tag: String? = CsvFormatStrategy.defaultTag

        public init() {
            let df = DateFormatter()
            df.locale = Locale(identifier: "en_US_POSIX")
            df.dateFormat = "yyyy.MM.dd HH:mm:ss.SSS"
            self.dateFormatter = df
        }

        @discardableResult
        public func dateFormat(_ format: String) -> Self {
            self.dateFormatter.dateFormat = format
            return self
        }

        @discardableResult
        public func logStrategy(_ strategy: LogStrategy) -> Self {
            self.logStrategy = strategy
            return self
        }

        @discardableResult
        public func tag(_ tag: String?) -> Self {
            self.tag = tag
            return self
        }

        public func build() -> CsvFormatStrategy {
            return CsvFormatStrategy(builder: self)
        }
    }
}

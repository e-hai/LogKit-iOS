import Foundation

public protocol LogAdapter: AnyObject {
    func isLoggable(priority: LogPriority, tag: String?) -> Bool
    func log(priority: LogPriority, tag: String?, message: String)
}

public extension LogAdapter {
    func isLoggable(priority: LogPriority, tag: String?) -> Bool {
        return true
    }
}

public final class DefaultLogAdapter: LogAdapter {
    private let formatStrategy: FormatStrategy

    public init(formatStrategy: FormatStrategy) {
        self.formatStrategy = formatStrategy
    }

    public func isLoggable(priority: LogPriority, tag: String?) -> Bool {
        return true
    }

    public func log(priority: LogPriority, tag: String?, message: String) {
        formatStrategy.log(priority: priority, onceOnlyTag: tag, message: message)
    }

    public static func createConsoleAdapter(
        formatStrategy: FormatStrategy = PrettyFormatStrategy.newBuilder().build()
    ) -> LogAdapter {
        return DefaultLogAdapter(formatStrategy: formatStrategy)
    }

    public static func createDiskAdapter(
        formatStrategy: FormatStrategy = CsvFormatStrategy.newBuilder().build()
    ) -> LogAdapter {
        return DefaultLogAdapter(formatStrategy: formatStrategy)
    }
}

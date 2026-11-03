import Foundation
#if canImport(OSLog)
import OSLog
#endif

public protocol LogStrategy: AnyObject {
    func log(priority: LogPriority, tag: String?, message: String)
}

public final class ConsoleLogStrategy: LogStrategy {
    public static let shared = ConsoleLogStrategy()

    public init() {}

    public func log(priority: LogPriority, tag: String?, message: String) {
        let tagStr = tag ?? "LOG_KIT"
        #if canImport(OSLog)
        if #available(iOS 14.0, macOS 11.0, *) {
            let logger = Logger(subsystem: "com.kit.log", category: tagStr)
            switch priority {
            case .verbose:
                logger.trace("\(message, privacy: .public)")
            case .debug:
                logger.debug("\(message, privacy: .public)")
            case .info:
                logger.info("\(message, privacy: .public)")
            case .warn:
                logger.warning("\(message, privacy: .public)")
            case .error, .assert:
                logger.error("\(message, privacy: .public)")
            }
            return
        }
        #endif
        print("[\(tagStr)] [\(priority.name)] \(message)")
    }
}

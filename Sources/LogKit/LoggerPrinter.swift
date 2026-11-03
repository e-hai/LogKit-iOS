import Foundation

public final class LoggerPrinter {
    private let lock = NSRecursiveLock()
    private var logAdapters: [LogAdapter] = []
    private static let tempTagKey = "LogKit_ThreadLocal_TempTag"

    public init() {}

    @discardableResult
    public func t(_ tag: String?) -> LoggerPrinter {
        if let tag = tag {
            Thread.current.threadDictionary[Self.tempTagKey] = tag
        }
        return this
    }

    private var this: LoggerPrinter { self }

    public func d(_ message: String, _ args: CVarArg...) {
        log(priority: .debug, error: nil, message: format(message, args: args))
    }

    public func d(_ obj: Any?) {
        log(priority: .debug, error: nil, message: Utils.toString(obj))
    }

    public func e(_ message: String, _ args: CVarArg...) {
        log(priority: .error, error: nil, message: format(message, args: args))
    }

    public func e(_ error: Error?, _ message: String, _ args: CVarArg...) {
        log(priority: .error, error: error, message: format(message, args: args))
    }

    public func w(_ message: String, _ args: CVarArg...) {
        log(priority: .warn, error: nil, message: format(message, args: args))
    }

    public func i(_ message: String, _ args: CVarArg...) {
        log(priority: .info, error: nil, message: format(message, args: args))
    }

    public func v(_ message: String, _ args: CVarArg...) {
        log(priority: .verbose, error: nil, message: format(message, args: args))
    }

    public func wtf(_ message: String, _ args: CVarArg...) {
        log(priority: .assert, error: nil, message: format(message, args: args))
    }

    public func json(_ jsonString: String?) {
        guard let jsonString = jsonString?.trimmingCharacters(in: .whitespacesAndNewlines), !jsonString.isEmpty else {
            d("Empty/Null json content")
            return
        }

        guard let data = jsonString.data(using: .utf8) else {
            e("Invalid Json")
            return
        }

        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
            let prettyData = try JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted, .sortedKeys])
            if let formatted = String(data: prettyData, encoding: .utf8) {
                d(formatted)
                return
            }
        } catch {
            e("Invalid Json: \(error)")
        }
    }

    public func xml(_ xmlString: String?) {
        guard let xmlString = xmlString?.trimmingCharacters(in: .whitespacesAndNewlines), !xmlString.isEmpty else {
            d("Empty/Null xml content")
            return
        }

        // Lightweight XML indent formatter
        var formatted = ""
        var indentLevel = 0
        let lines = xmlString.replacingOccurrences(of: "><", with: ">\n<").components(separatedBy: "\n")

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            guard !trimmed.isEmpty else { continue }

            if trimmed.hasPrefix("</") {
                indentLevel = max(0, indentLevel - 1)
            }

            let indent = String(repeating: "  ", count: indentLevel)
            formatted.append("\(indent)\(trimmed)\n")

            if trimmed.hasPrefix("<") && !trimmed.hasPrefix("</") && !trimmed.hasSuffix("/>") && !trimmed.hasPrefix("<?") {
                indentLevel += 1
            }
        }

        d(formatted.trimmingCharacters(in: .whitespacesAndNewlines))
    }

    public func log(priority: LogPriority, tag: String?, message: String?, error: Error?) {
        lock.lock()
        defer { lock.unlock() }

        var finalMessage = message
        if let error = error, let msg = finalMessage {
            finalMessage = "\(msg) : \(Utils.getStackTraceString(error))"
        } else if let error = error, finalMessage == nil {
            finalMessage = Utils.getStackTraceString(error)
        }

        let outputMessage = (finalMessage?.isEmpty == false) ? finalMessage! : "Empty/NULL log message"

        for adapter in logAdapters {
            if adapter.isLoggable(priority: priority, tag: tag) {
                adapter.log(priority: priority, tag: tag, message: outputMessage)
            }
        }
    }

    public func addAdapter(_ adapter: LogAdapter) {
        lock.lock()
        defer { lock.unlock() }
        logAdapters.append(adapter)
    }

    public func clearLogAdapters() {
        lock.lock()
        defer { lock.unlock() }
        logAdapters.removeAll()
    }

    private func log(priority: LogPriority, error: Error?, message: String) {
        let tag = getTag()
        log(priority: priority, tag: tag, message: message, error: error)
    }

    private func getTag() -> String? {
        if let tag = Thread.current.threadDictionary[Self.tempTagKey] as? String {
            Thread.current.threadDictionary.removeObject(forKey: Self.tempTagKey)
            return tag
        }
        return nil
    }

    private func format(_ message: String, args: [CVarArg]) -> String {
        if args.isEmpty {
            return message
        }
        return String(format: message, arguments: args)
    }
}

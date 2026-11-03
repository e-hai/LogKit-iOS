import Foundation

public enum LogPriority: Int, Comparable, Sendable, CaseIterable {
    case verbose = 2
    case debug = 3
    case info = 4
    case warn = 5
    case error = 6
    case assert = 7

    public static func < (lhs: LogPriority, rhs: LogPriority) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }

    public var name: String {
        switch self {
        case .verbose: return "VERBOSE"
        case .debug:   return "DEBUG"
        case .info:    return "INFO"
        case .warn:    return "WARN"
        case .error:   return "ERROR"
        case .assert:  return "ASSERT"
        }
    }

    public var shortName: String {
        switch self {
        case .verbose: return "V"
        case .debug:   return "D"
        case .info:    return "I"
        case .warn:    return "W"
        case .error:   return "E"
        case .assert:  return "A"
        }
    }
}

public enum Utils {
    public static func logLevelName(_ priority: LogPriority) -> String {
        return priority.name
    }

    public static func toString(_ obj: Any?) -> String {
        guard let obj = obj else {
            return "nil"
        }
        if let string = obj as? String {
            return string
        }
        return String(describing: obj)
    }

    public static func getStackTraceString(_ error: Error?) -> String {
        guard let error = error else { return "" }
        if let customString = (error as CustomStringConvertible).description as String? {
            return "\(type(of: error)): \(customString)"
        }
        return "\(error)"
    }
}

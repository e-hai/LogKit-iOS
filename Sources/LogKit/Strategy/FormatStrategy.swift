import Foundation

public protocol FormatStrategy: AnyObject {
    func log(priority: LogPriority, onceOnlyTag: String?, message: String)
}

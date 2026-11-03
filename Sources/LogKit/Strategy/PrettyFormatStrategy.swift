import Foundation

public final class PrettyFormatStrategy: FormatStrategy {
    private let methodCount: Int
    private let methodOffset: Int
    private let showThreadInfo: BooleanLiteralType
    private let logStrategy: LogStrategy
    private let tag: String?

    private static let chunkSize = 4000
    private static let minStackOffset = 2
    private static let defaultTag = "LOG_KIT"

    private static let topLeftCorner = "┌"
    private static let bottomLeftCorner = "└"
    private static let middleCorner = "├"
    private static let horizontalLine = "│"
    private static let doubleDivider = String(repeating: "─", count: 56)
    private static let singleDivider = String(repeating: "┄", count: 56)

    private static let topBorder = "\(topLeftCorner)\(doubleDivider)\(doubleDivider)"
    private static let bottomBorder = "\(bottomLeftCorner)\(doubleDivider)\(doubleDivider)"
    private static let middleBorder = "\(middleCorner)\(singleDivider)\(singleDivider)"

    private init(builder: Builder) {
        self.methodCount = builder.methodCount
        self.methodOffset = builder.methodOffset
        self.showThreadInfo = builder.showThreadInfo
        self.logStrategy = builder.logStrategy
        self.tag = builder.tag
    }

    public func log(priority: LogPriority, onceOnlyTag: String?, message: String) {
        let formatTag = self.formatTag(onceOnlyTag)

        logTopBorder(priority: priority, tag: formatTag)
        logHeaderContent(priority: priority, tag: formatTag, methodCount: methodCount)

        let utf8Bytes = Array(message.utf8)
        let length = utf8Bytes.count

        if length <= Self.chunkSize {
            if methodCount > 0 {
                logDivider(priority: priority, tag: formatTag)
            }
            logContent(priority: priority, tag: formatTag, chunk: message)
            logBottomBorder(priority: priority, tag: formatTag)
            return
        }

        if methodCount > 0 {
            logDivider(priority: priority, tag: formatTag)
        }

        var i = 0
        while i < length {
            let count = min(length - i, Self.chunkSize)
            let subData = Data(utf8Bytes[i..<(i + count)])
            let chunkString = String(data: subData, encoding: .utf8) ?? ""
            logContent(priority: priority, tag: formatTag, chunk: chunkString)
            i += Self.chunkSize
        }
        logBottomBorder(priority: priority, tag: formatTag)
    }

    private func logTopBorder(priority: LogPriority, tag: String?) {
        logChunk(priority: priority, tag: tag, chunk: Self.topBorder)
    }

    private func logHeaderContent(priority: LogPriority, tag: String?, methodCount: Int) {
        let symbols = Thread.callStackSymbols
        if showThreadInfo {
            let threadName = Thread.isMainThread ? "main" : (Thread.current.name?.isEmpty == false ? Thread.current.name! : "background")
            logChunk(priority: priority, tag: tag, chunk: "\(Self.horizontalLine) Thread: \(threadName)")
            logDivider(priority: priority, tag: tag)
        }

        guard methodCount > 0 else { return }

        let stackOffset = getStackOffset(symbols: symbols) + methodOffset
        var count = methodCount
        if stackOffset + methodCount > symbols.count {
            count = max(0, symbols.count - stackOffset)
        }

        guard count > 0 else { return }

        var level = ""
        for i in (1...count).reversed() {
            let stackIndex = i + stackOffset
            guard stackIndex < symbols.count else { continue }
            let symbol = cleanStackSymbol(symbols[stackIndex])
            let line = "\(Self.horizontalLine) \(level)\(symbol)"
            level += " "
            logChunk(priority: priority, tag: tag, chunk: line)
        }
    }

    private func logBottomBorder(priority: LogPriority, tag: String?) {
        logChunk(priority: priority, tag: tag, chunk: Self.bottomBorder)
    }

    private func logDivider(priority: LogPriority, tag: String?) {
        logChunk(priority: priority, tag: tag, chunk: Self.middleBorder)
    }

    private func logContent(priority: LogPriority, tag: String?, chunk: String) {
        let lines = chunk.components(separatedBy: "\n")
        for line in lines {
            logChunk(priority: priority, tag: tag, chunk: "\(Self.horizontalLine) \(line)")
        }
    }

    private func logChunk(priority: LogPriority, tag: String?, chunk: String) {
        logStrategy.log(priority: priority, tag: tag, message: chunk)
    }

    private func formatTag(_ tag: String?) -> String? {
        if let tag = tag, !tag.isEmpty, self.tag != tag {
            return "\(self.tag ?? Self.defaultTag)-\(tag)"
        }
        return self.tag
    }

    private func getStackOffset(symbols: [String]) -> Int {
        var i = Self.minStackOffset
        while i < symbols.count {
            let s = symbols[i]
            if !s.contains("LogKit") && !s.contains("PrettyFormatStrategy") && !s.contains("LoggerPrinter") {
                return max(0, i - 1)
            }
            i += 1
        }
        return Self.minStackOffset
    }

    private func cleanStackSymbol(_ symbol: String) -> String {
        // Typical symbol format: 2   MyApp   0x0000000100003cb0 $s5MyApp10doSomethingyyF + 48
        let components = symbol.components(separatedBy: CharacterSet.whitespaces).filter { !$0.isEmpty }
        if components.count >= 4 {
            let module = components[1]
            let method = components[3...].joined(separator: " ")
            return "\(module).\(method)"
        }
        return symbol
    }

    public static func newBuilder() -> Builder {
        return Builder()
    }

    public final class Builder {
        fileprivate var methodCount: Int = 2
        fileprivate var methodOffset: Int = 0
        fileprivate var showThreadInfo: Bool = true
        fileprivate var logStrategy: LogStrategy = ConsoleLogStrategy.shared
        fileprivate var tag: String? = PrettyFormatStrategy.defaultTag

        public init() {}

        @discardableResult
        public func methodCount(_ count: Int) -> Self {
            self.methodCount = count
            return self
        }

        @discardableResult
        public func methodOffset(_ offset: Int) -> Self {
            self.methodOffset = offset
            return self
        }

        @discardableResult
        public func showThreadInfo(_ show: Bool) -> Self {
            self.showThreadInfo = show
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

        public func build() -> PrettyFormatStrategy {
            return PrettyFormatStrategy(builder: self)
        }
    }
}

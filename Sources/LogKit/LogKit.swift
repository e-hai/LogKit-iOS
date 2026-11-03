import Foundation
#if canImport(UIKit)
import UIKit
import SwiftUI
#endif

public final class LogKit {
    public static let shared = LogKit()

    private static let defaultTag = "LogKit"
    private var printer = LoggerPrinter()
    private var diskStrategy: DiskLogWriteReadStrategy?

    public init() {}

    // MARK: - Configuration & Adapters

    public static func printer(_ printer: LoggerPrinter) {
        shared.printer = printer
    }

    public static func addLogAdapter(_ adapter: LogAdapter) {
        shared.printer.addAdapter(adapter)
    }

    public static func clearLogAdapters() {
        shared.printer.clearLogAdapters()
    }

    @discardableResult
    public static func t(_ tag: String?) -> LoggerPrinter {
        return shared.printer.t(tag)
    }

    // MARK: - Initialization Presets

    public static func initOnlyConsoleLog() {
        clearLogAdapters()
        addLogAdapter(DefaultLogAdapter.createConsoleAdapter())
    }

    public static func initOnlyDiskLog(folderPath: String? = nil) {
        clearLogAdapters()
        let strategy = DiskLogWriteReadStrategy(folderPath: folderPath)
        shared.diskStrategy = strategy
        let csvFormatStrategy = CsvFormatStrategy.newBuilder()
            .logStrategy(strategy)
            .build()
        addLogAdapter(DefaultLogAdapter.createDiskAdapter(formatStrategy: csvFormatStrategy))
    }

    public static func initAllLog(folderPath: String? = nil) {
        clearLogAdapters()
        addLogAdapter(DefaultLogAdapter.createConsoleAdapter())
        let strategy = DiskLogWriteReadStrategy(folderPath: folderPath)
        shared.diskStrategy = strategy
        let csvFormatStrategy = CsvFormatStrategy.newBuilder()
            .logStrategy(strategy)
            .build()
        addLogAdapter(DefaultLogAdapter.createDiskAdapter(formatStrategy: csvFormatStrategy))
    }

    public static func readLog(completion: @escaping ([String]) -> Void) {
        if let diskStrategy = shared.diskStrategy {
            diskStrategy.readLog(completion: completion)
        } else {
            completion([])
        }
    }

    // MARK: - UI Launcher

    #if canImport(UIKit)
    @MainActor
    public static func showLogUI(from presenter: UIViewController) {
        let logView = LogScreen(onBackClick: {
            presenter.dismiss(animated: true)
        })
        let hostingController = UIHostingController(rootView: logView)
        hostingController.modalPresentationStyle = .fullScreen
        presenter.present(hostingController, animated: true)
    }
    #endif

    // MARK: - Logging APIs

    public static func log(priority: LogPriority, tag: String?, message: String?, error: Error?) {
        shared.printer.log(priority: priority, tag: tag, message: message, error: error)
    }

    public static func d(_ tag: String, _ message: String) {
        shared.printer.t(tag).d(message)
    }

    public static func d(_ message: String, _ args: CVarArg...) {
        shared.printer.t(defaultTag).d(String(format: message, arguments: args))
    }

    public static func d(_ obj: Any?) {
        shared.printer.t(defaultTag).d(obj)
    }

    public static func e(_ tag: String, _ message: String) {
        shared.printer.t(tag).e(message)
    }

    public static func e(_ message: String, _ args: CVarArg...) {
        shared.printer.t(defaultTag).e(String(format: message, arguments: args))
    }

    public static func e(_ tag: String, error: Error?, _ message: String) {
        shared.printer.t(tag).e(error, message)
    }

    public static func e(error: Error?, _ message: String, _ args: CVarArg...) {
        shared.printer.t(defaultTag).e(error, String(format: message, arguments: args))
    }

    public static func i(_ tag: String, _ message: String) {
        shared.printer.t(tag).i(message)
    }

    public static func i(_ message: String, _ args: CVarArg...) {
        shared.printer.t(defaultTag).i(String(format: message, arguments: args))
    }

    public static func v(_ tag: String, _ message: String) {
        shared.printer.t(tag).v(message)
    }

    public static func v(_ message: String, _ args: CVarArg...) {
        shared.printer.t(defaultTag).v(String(format: message, arguments: args))
    }

    public static func w(_ tag: String, _ message: String) {
        shared.printer.t(tag).w(message)
    }

    public static func w(_ message: String, _ args: CVarArg...) {
        shared.printer.t(defaultTag).w(String(format: message, arguments: args))
    }

    public static func wtf(_ tag: String, _ message: String) {
        shared.printer.t(tag).wtf(message)
    }

    public static func wtf(_ message: String, _ args: CVarArg...) {
        shared.printer.t(defaultTag).wtf(String(format: message, arguments: args))
    }

    public static func json(_ tag: String, _ jsonString: String?) {
        shared.printer.t(tag).json(jsonString)
    }

    public static func json(_ jsonString: String?) {
        shared.printer.t(defaultTag).json(jsonString)
    }

    public static func xml(_ tag: String, _ xmlString: String?) {
        shared.printer.t(tag).xml(xmlString)
    }

    public static func xml(_ xmlString: String?) {
        shared.printer.t(defaultTag).xml(xmlString)
    }
}

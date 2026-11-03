import Foundation

public struct LogInfo: Identifiable, Hashable, Sendable {
    public let id: UUID
    public let date: Int64
    public let dateString: String
    public let priority: String
    public let tag: String
    public let message: String

    public init(
        id: UUID = UUID(),
        date: Int64,
        dateString: String,
        priority: String,
        tag: String,
        message: String
    ) {
        self.id = id
        self.date = date
        self.dateString = dateString
        self.priority = priority
        self.tag = tag
        self.message = message
    }
}

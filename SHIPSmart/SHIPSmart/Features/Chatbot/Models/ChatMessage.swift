import Foundation

public struct ChatMessage: Identifiable, Equatable {
    public let id: UUID
    public let timestamp: Date
    public let content: String
    public let isUser: Bool
    public var showButtons: Bool
    
    public init(
        id: UUID = UUID(), 
        timestamp: Date = Date(),
        content: String,
        isUser: Bool,
        showButtons: Bool = false
    ) {
        self.id = id
        self.timestamp = timestamp
        self.content = content
        self.isUser = isUser
        self.showButtons = showButtons
    }
    
    public static func == (lhs: ChatMessage, rhs: ChatMessage) -> Bool {
        lhs.id == rhs.id
    }
} 
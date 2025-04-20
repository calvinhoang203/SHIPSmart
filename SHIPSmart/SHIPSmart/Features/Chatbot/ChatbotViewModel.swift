import Foundation
import SwiftUI
import Combine

struct Message: Identifiable {
    let id: String
    let content: String
    let isUser: Bool
    let timestamp: Date
}

@MainActor
class ChatbotViewModel: ObservableObject {
    @Published var messages: [Message] = []
    @Published var inputMessage = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let api = CerebrasAPI()
    
    init() {
        messages.append(Message(
            id: UUID().uuidString,
            content: "Hello! I'm your SHIPSmart assistant. How can I help you today?",
            isUser: false,
            timestamp: Date()
        ))
    }
    
    func sendMessage() async {
        guard !inputMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let messageToSend = inputMessage
        inputMessage = ""
        
        let userMessage = Message(
            id: UUID().uuidString,
            content: messageToSend,
            isUser: true,
            timestamp: Date()
        )
        messages.append(userMessage)
        
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await api.sendMessage(messageToSend)
            let assistantMessage = Message(
                id: UUID().uuidString,
                content: response,
                isUser: false,
                timestamp: Date()
            )
            messages.append(assistantMessage)
        } catch {
            print("Failed to send message: \(error)")
            errorMessage = "Failed to send message. Please try again."
            messages.append(Message(
                id: UUID().uuidString,
                content: "I apologize, but I'm having trouble responding right now. Please try again.",
                isUser: false,
                timestamp: Date()
            ))
        }
        
        isLoading = false
    }
}

// MARK: - API Response Models
struct AgentResponse: Codable {
    let id: String
}

struct MessageResponse: Codable {
    let messages: [AgentMessage]
}

struct AgentMessage: Codable {
    let role: String
    let content: String
} 

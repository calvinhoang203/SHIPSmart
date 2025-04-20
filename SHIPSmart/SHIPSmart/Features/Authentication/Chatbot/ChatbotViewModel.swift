import Foundation
import SwiftUI
import Combine

struct Message: Identifiable, Equatable {
    let id: String
    var content: String
    let isUser: Bool
    let timestamp: Date
    var isError: Bool = false
    var isStreaming: Bool = false
    
    static func == (lhs: Message, rhs: Message) -> Bool {
        lhs.id == rhs.id &&
        lhs.content == rhs.content &&
        lhs.isUser == rhs.isUser &&
        lhs.isError == rhs.isError &&
        lhs.isStreaming == rhs.isStreaming
    }
}

@MainActor
class ChatbotViewModel: ObservableObject {
    @Published var messages: [Message] = []
    @Published var inputMessage = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let api = CerebrasAPI()
    private var currentStreamingMessage: Message?
    
    init() {
        addWelcomeMessage()
    }
    
    private func addWelcomeMessage() {
        messages.append(Message(
            id: UUID().uuidString,
            content: "Hello! I'm SHIPSmart, your UC SHIP assistant. How can I help you today?",
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
        
        // Create a streaming message
        let streamingMessage = Message(
            id: UUID().uuidString,
            content: "",
            isUser: false,
            timestamp: Date(),
            isStreaming: true
        )
        currentStreamingMessage = streamingMessage
        messages.append(streamingMessage)
        
        do {
            let response = try await api.sendMessage(messageToSend)
            
            // Update the streaming message with the complete response
            if let index = messages.firstIndex(where: { $0.id == streamingMessage.id }) {
                messages[index].content = response
                messages[index].isStreaming = false
            }
            
        } catch APIError.serverError(let statusCode) {
            errorMessage = "Server error (status code: \(statusCode)). Please try again later."
            addErrorMessage()
        } catch APIError.invalidResponse {
            errorMessage = "Invalid response from the server. Please try again."
            addErrorMessage()
        } catch {
            errorMessage = "An unexpected error occurred. Please try again."
            addErrorMessage()
        }
        
        isLoading = false
        currentStreamingMessage = nil
    }
    
    private func addErrorMessage() {
        // Remove the streaming message if it exists
        if let streamingMessage = currentStreamingMessage,
           let index = messages.firstIndex(where: { $0.id == streamingMessage.id }) {
            messages.remove(at: index)
        }
        
        messages.append(Message(
            id: UUID().uuidString,
            content: errorMessage ?? "An error occurred. Please try again.",
            isUser: false,
            timestamp: Date(),
            isError: true
        ))
    }
}

// API Response Models
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

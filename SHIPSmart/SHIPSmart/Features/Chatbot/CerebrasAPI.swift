import Foundation

@MainActor
class CerebrasAPI: ObservableObject {
    private let session: URLSession
    private let apiKey = "csk-n8jpex53cwk58hvpx9ch6jvjpe4eh48p9f38vdjphj2tkcxr"
    @Published var isLoading = false
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func sendMessage(_ content: String) async throws -> String {
        isLoading = true
        defer { isLoading = false }
        
        let url = URL(string: "https://api.cerebras.ai/v1/chat")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        let message: [String: String] = ["role": "user", "content": content]
        let body: [String: Any] = [
            "messages": [message],
            "model": "gpt-4-1106-preview"
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, _) = try await session.data(for: request)
        if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
           let choices = json["choices"] as? [[String: Any]],
           let firstChoice = choices.first,
           let messageDict = firstChoice["message"] as? [String: Any],
           let responseContent = messageDict["content"] as? String {
            return responseContent
        }
        
        return "I'm sorry, I couldn't process that request."
    }
} 

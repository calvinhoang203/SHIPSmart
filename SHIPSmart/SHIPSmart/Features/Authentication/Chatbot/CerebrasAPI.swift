import Foundation

@MainActor
class CerebrasAPI: ObservableObject {
    private let session: URLSession
    private let apiKey = ""
    @Published var isLoading = false
    
    private let systemPrompt = """
    You are SHIPSmart, a helpful assistant for UC SHIP (University of California Student Health Insurance Plan) members. 
        Your role is to:
        1. Help students understand their health insurance benefits
        2. Assist with finding in-network providers
        3. Explain coverage details and limitations
        4. Guide through the claims process
        5. Help with appointment scheduling
        6. Answer general health insurance questions
        
        Always be:
        - Professional and friendly
        - Clear and concise
        - Accurate with insurance information
        - Helpful in guiding next steps
        - Patient with questions
        
        If you're unsure about specific coverage details, direct the student to contact the SHIP office directly.

    """
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func sendMessage(_ content: String) async throws -> String {
        isLoading = true
        defer { isLoading = false }
        
        let url = URL(string: "https://api.cerebras.ai/v1/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("SHIPSmart/1.0", forHTTPHeaderField: "User-Agent")
        
        // Create the request body
        let requestBody: [String: Any] = [
            "messages": [
                ["role": "system", "content": systemPrompt],
                ["role": "user", "content": content]
            ],
            "model": "llama-4-scout-17b-16e-instruct",
            "stream": false,
            "temperature": 1,
            "top_p": 1,
            "max_tokens": 8192
        ]
        
        // Encode the request body
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch {
            print("Error encoding request: \(error)")
            throw APIError.encodingError
        }
        
        // Make the request
        let (data, response) = try await session.data(for: request)
        
        // Print response for debugging
        if let responseString = String(data: data, encoding: .utf8) {
            print("Raw response: \(responseString)")
        }
        
        // Validate response
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        // Handle HTTP errors
        switch httpResponse.statusCode {
        case 200: break // Success
        case 401: throw APIError.unauthorized
        case 429: throw APIError.rateLimitExceeded
        default: throw APIError.serverError(statusCode: httpResponse.statusCode)
        }
        
        // Parse response
        do {
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            
            guard let choices = json?["choices"] as? [[String: Any]],
                  let firstChoice = choices.first,
                  let message = firstChoice["message"] as? [String: Any],
                  let content = message["content"] as? String else {
                print("Failed to parse response: \(String(describing: json))")
                throw APIError.invalidResponse
            }
            
            return content
            
        } catch {
            print("Error parsing response: \(error)")
            throw APIError.decodingError
        }
    }
}

enum APIError: Error, LocalizedError {
    case invalidResponse
    case serverError(statusCode: Int)
    case unauthorized
    case rateLimitExceeded
    case encodingError
    case decodingError
    
    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid response from server"
        case .serverError(let code):
            return "Server error (status code: \(code))"
        case .unauthorized:
            return "Unauthorized. Please check your API key"
        case .rateLimitExceeded:
            return "Rate limit exceeded. Please try again later"
        case .encodingError:
            return "Error preparing request"
        case .decodingError:
            return "Error parsing response"
        }
    }
} 

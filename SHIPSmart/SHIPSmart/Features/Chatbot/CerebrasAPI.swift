import Foundation

// MARK: - Configuration
enum CerebrasConfig {
    static let baseURL = URL(string: "https://api.cerebras.ai")!
    static let apiKey = "csk-n8jpex53cwk58hvpx9ch6jvjpe4eh48p9f38vdjphj2tkcxr"
}

// MARK: - Models
struct CerebrasMessage: Codable {
    let role: String
    let content: String
    let tool_call_id: String?
    
    init(role: String, content: String, tool_call_id: String? = nil) {
        self.role = role
        self.content = content
        self.tool_call_id = tool_call_id
    }
}

struct ToolCall: Codable {
    let id: String
    let function: FunctionCall
    let type: String
}

struct FunctionCall: Codable {
    let name: String
    let arguments: String
}

struct Tool: Codable {
    let type: String
    let function: ToolFunction
}

struct ToolFunction: Codable {
    let name: String
    let description: String
    let parameters: Parameters
    let strict: Bool
}

struct Parameters: Codable {
    let type: String
    let properties: [String: PropertyDetails]
    let required: [String]
}

struct PropertyDetails: Codable {
    let type: String
    let description: String
}

struct CerebrasRequest: Codable {
    let messages: [CerebrasMessage]
    let model: String
    let tools: [Tool]?
    let parallel_tool_calls: Bool?
    let stream: Bool
    let max_completion_tokens: Int
    let temperature: Double
    let top_p: Double
    
    init(messages: [CerebrasMessage], tools: [Tool]? = nil, stream: Bool = false) {
        self.messages = messages
        self.model = "llama-4-scout-17b-16e-instruct"
        self.tools = tools
        self.parallel_tool_calls = false
        self.stream = stream
        self.max_completion_tokens = 8192
        self.temperature = 0.39
        self.top_p = 1
    }
}

struct CerebrasResponse: Codable {
    let id: String
    let choices: [Choice]
    let created: Int
    let model: String
    let object: String
    let usage: Usage?
    
    struct Choice: Codable {
        let index: Int
        let message: CerebrasMessage?
        let delta: Delta?
        let finish_reason: String?
        let tool_calls: [ToolCall]?
    }
    
    struct Delta: Codable {
        let content: String?
    }
    
    struct Usage: Codable {
        let prompt_tokens: Int
        let completion_tokens: Int
        let total_tokens: Int
    }
}

// MARK: - Errors
enum CerebrasError: Error {
    case apiError(String)
    case noResponseContent
    case networkError(Error)
    case invalidURL
    
    var localizedDescription: String {
        switch self {
        case .apiError(let message):
            return "API Error: \(message)"
        case .noResponseContent:
            return "No response content received"
        case .networkError(let error):
            return "Network Error: \(error.localizedDescription)"
        case .invalidURL:
            return "Invalid URL"
        }
    }
}

// MARK: - API Client
actor CerebrasAPI {
    private let apiKey = "csk-n8jpex53cwk58hvpx9ch6jvjpe4eh48p9f38vdjphj2tkcxr"
    private let baseURL = URL(string: "https://api.cerebras.ai")!
    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    private let systemPrompt: String
    private let tools: [Tool]
    
    init() {
        // Configure session for reliability
        let config = URLSessionConfiguration.ephemeral
        config.multipathServiceType = .none
        config.allowsExpensiveNetworkAccess = true
        config.allowsConstrainedNetworkAccess = true
        config.timeoutIntervalForRequest = 60
        config.timeoutIntervalForResource = 300
        config.httpAdditionalHeaders = [
            "Content-Type": "application/json",
            "Accept": "application/json",
            "User-Agent": "SHIPSmart/1.0 (iOS)"
        ]
        
        self.session = URLSession(configuration: config)
        self.decoder = JSONDecoder()
        self.encoder = JSONEncoder()
        
        // Set up system prompt with policy information
        self.systemPrompt = """
        You are a helpful shipping assistant for SHIPSmart. You have access to the following important policy information:

        SPD275958 -8 2024 -25 Benefit Booklet
        Anthem PPO Plan - PPO Network
        University of California Student Health Insurance Plan
        UC DAVIS - Students and Dependents
        2024 -25

        Important Contact Numbers:
        - UC Davis Student Health and Counseling Services: 1-530-752-2349
        - Appointments: 1-530-752-2349
        - Counseling and psychological services/Advice Nurse: 1-530-752-2349
        - After Hours: 1-800-391-2793
        - UC SHIP Member Services: 1-866-940-8306
        - Academic Health Plans (AHP): 1-855-427-3167
        - Email: ucship@ahpservice.com
        - LiveHealth Online: 1-888-548-3432
        - Anthem Nurseline: 1-877-351-3457
        - Future Moms: 1-866-664-5404

        Important Locations:
        - SHCS Medical Services at the Student Health & Wellness Center: 930 Blue Ridge Road, across the street from the ARC
        - SHCS Counseling Services: 219 North Hall, next to Dutton Hall and South Hall

        When answering questions, always:
        1. Reference specific policy numbers and details when relevant
        2. Provide accurate contact information when appropriate
        3. Be clear about which services are available at which locations
        4. Maintain a professional and helpful tone
        5. If you're unsure about specific policy details, direct users to the appropriate contact number
        """
        
        // Set up tools
        self.tools = [
            Tool(
                type: "function",
                function: ToolFunction(
                    name: "search_policy",
                    description: "Search through policy information to find relevant details",
                    parameters: Parameters(
                        type: "object",
                        properties: [
                            "query": PropertyDetails(
                                type: "string",
                                description: "The search query to find policy information"
                            )
                        ],
                        required: ["query"]
                    ),
                    strict: true
                )
            )
        ]
    }
    
    func sendMessage(_ content: String, stream: Bool = false) async throws -> String {
        let messages = [
            CerebrasMessage(role: "system", content: systemPrompt),
            CerebrasMessage(role: "user", content: content)
        ]
        
        let request = CerebrasRequest(messages: messages, tools: tools, stream: stream)
        let body = try encoder.encode(request)
        
        let url = baseURL.appendingPathComponent("v1/chat/completions")
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        urlRequest.httpBody = body
        
        print("Making request to: \(url.absoluteString)")
        
        do {
            if stream {
                let (asyncBytes, response) = try await session.bytes(for: urlRequest)
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("Invalid response type")
                    throw URLError(.badServerResponse)
                }
                
                print("Response status code: \(httpResponse.statusCode)")
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    let data = try await asyncBytes.reduce(into: Data()) { $0.append($1) }
                    if let errorJson = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let errorMessage = errorJson["message"] as? String {
                        print("API Error: \(errorMessage)")
                        throw URLError(.badServerResponse, userInfo: [NSLocalizedDescriptionKey: errorMessage])
                    }
                    throw URLError(.badServerResponse)
                }
                
                var fullResponse = ""
                for try await line in asyncBytes.lines {
                    if line.hasPrefix("data: "), let data = line.dropFirst(6).data(using: .utf8) {
                        if let chunk = try? decoder.decode(CerebrasResponse.self, from: data),
                           let content = chunk.choices.first?.delta?.content {
                            fullResponse += content
                        }
                    }
                }
                return fullResponse
            } else {
                let (data, response) = try await session.data(for: urlRequest)
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("Invalid response type")
                    throw URLError(.badServerResponse)
                }
                
                print("Response status code: \(httpResponse.statusCode)")
                
                if let responseString = String(data: data, encoding: .utf8) {
                    print("Response data: \(responseString)")
                }
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    if let errorJson = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let errorMessage = errorJson["message"] as? String {
                        print("API Error: \(errorMessage)")
                        throw URLError(.badServerResponse, userInfo: [NSLocalizedDescriptionKey: errorMessage])
                    }
                    throw URLError(.badServerResponse)
                }
                
                let cerebrasResponse = try decoder.decode(CerebrasResponse.self, from: data)
                
                // Handle tool calls if present
                if let toolCalls = cerebrasResponse.choices.first?.tool_calls {
                    var updatedMessages = messages
                    
                    for toolCall in toolCalls {
                        if toolCall.function.name == "search_policy" {
                            let arguments = try JSONDecoder().decode([String: String].self, from: Data(toolCall.function.arguments.utf8))
                            if let query = arguments["query"] {
                                // Here we would implement actual policy search logic
                                let searchResult = "Found relevant policy information for: \(query)"
                                updatedMessages.append(CerebrasMessage(
                                    role: "tool",
                                    content: searchResult,
                                    tool_call_id: toolCall.id
                                ))
                            }
                        }
                    }
                    
                    // Make another request with the tool results
                    let finalRequest = CerebrasRequest(messages: updatedMessages)
                    let finalBody = try encoder.encode(finalRequest)
                    urlRequest.httpBody = finalBody
                    
                    let (finalData, finalResponse) = try await session.data(for: urlRequest)
                    
                    guard let finalHttpResponse = finalResponse as? HTTPURLResponse,
                          (200...299).contains(finalHttpResponse.statusCode) else {
                        throw URLError(.badServerResponse)
                    }
                    
                    let finalCerebrasResponse = try decoder.decode(CerebrasResponse.self, from: finalData)
                    
                    guard let messageContent = finalCerebrasResponse.choices.first?.message?.content else {
                        throw URLError(.cannotParseResponse)
                    }
                    
                    return messageContent
                }
                
                guard let messageContent = cerebrasResponse.choices.first?.message?.content else {
                    print("No message content in response")
                    throw URLError(.cannotParseResponse)
                }
                
                return messageContent
            }
        } catch let error as URLError {
            print("Network error: \(error.localizedDescription)")
            if error.code == .notConnectedToInternet {
                throw URLError(.notConnectedToInternet, userInfo: [NSLocalizedDescriptionKey: "Please check your internet connection and try again."])
            }
            throw error
        } catch let error as DecodingError {
            print("Decoding error: \(error)")
            throw URLError(.cannotParseResponse, userInfo: [NSLocalizedDescriptionKey: "Failed to parse the API response."])
        } catch {
            print("Unexpected error: \(error)")
            throw error
        }
    }
} 
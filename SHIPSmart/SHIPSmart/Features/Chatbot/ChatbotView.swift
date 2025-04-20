import SwiftUI
import NaturalLanguage

// MARK: - Models
enum Chat {
    // Add message types to better handle different responses
    enum MessageIntent {
        case greeting
        case insurance
        case appointment
        case other
    }
    
    struct Message: Identifiable, Equatable {
        let id: UUID
        let content: String
        let isUser: Bool
        var showButtons: Bool
        var isError: Bool
        
        init(
            id: UUID = UUID(),
            content: String,
            isUser: Bool,
            showButtons: Bool = false,
            isError: Bool = false
        ) {
            self.id = id
            self.content = content
            self.isUser = isUser
            self.showButtons = showButtons
            self.isError = isError
        }
    }
    
    struct BubbleView: View {
        let message: Message
        let onYesPressed: () -> Void
        let onNoPressed: () -> Void
        
        var body: some View {
            HStack {
                if message.isUser {
                    Spacer()
                }
                
                VStack(alignment: message.isUser ? .trailing : .leading, spacing: 8) {
                    HStack {
                        if !message.isUser {
                            Image("Bot Icon")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .clipShape(Circle())
                                .padding(.trailing, 8)
                        }
                        
                        Text(message.content)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(
                                message.isError ? Color.red.opacity(0.1) :
                                    message.isUser ? Color.blue : Color(.systemGray6)
                            )
                            .foregroundColor(
                                message.isError ? .red :
                                    message.isUser ? .white : .black
                            )
                            .cornerRadius(20)
                    }
                    
                    if message.showButtons {
                        HStack(spacing: 20) {
                            Button(action: onYesPressed) {
                                Text("Yes")
                                    .fontWeight(.medium)
                                    .foregroundColor(.white)
                                    .frame(width: 100)
                                    .padding(.vertical, 12)
                                    .background(Color.green)
                                    .cornerRadius(25)
                            }
                            
                            Button(action: onNoPressed) {
                                Text("No")
                                    .fontWeight(.medium)
                                    .foregroundColor(.white)
                                    .frame(width: 100)
                                    .padding(.vertical, 12)
                                    .background(Color.red)
                                    .cornerRadius(25)
                            }
                        }
                        .padding(.top, 8)
                    }
                }
                
                if !message.isUser {
                    Spacer()
                }
            }
            .padding(.horizontal)
        }
    }
}

// MARK: - Input Validation
extension Chat {
    enum InputValidation {
        // Common greetings
        static let greetings = Set([
            "hi", "hey", "hello", "good morning", "good afternoon", 
            "good evening", "morning", "afternoon", "evening"
        ])
        
        // Insurance-related keywords
        static let insuranceKeywords = Set([
            "benefits", "coverage", "insurance", "covered", "plan",
            "medical", "health", "dental", "vision", "prescription",
            "copay", "deductible", "premium"
        ])
        
        static let validShortPhrases = Set([
            "yes", "no", "ok", "okay", "thanks",
            "thank you", "bye", "goodbye", "sure", "please"
        ])
        
        // Common English words to help detect meaningful content
        static let commonEnglishWords = Set([
            "i", "you", "he", "she", "it", "we", "they",
            "am", "is", "are", "was", "were",
            "have", "has", "had",
            "do", "does", "did",
            "can", "could", "will", "would", "should",
            "my", "your", "his", "her", "its", "our", "their",
            "this", "that", "these", "those",
            "what", "when", "where", "why", "how",
            "need", "want", "like", "help", "know", "tell", "show",
            "find", "get", "see", "look", "ask"
        ])
        
        // Appointment-related keywords
        static let appointmentKeywords = Set([
            "appointment", "schedule", "book", "visit", "see a doctor",
            "doctor", "consultation", "checkup", "check-up", "meet",
            "available", "slot", "time", "date"
        ])
        
        static func isGibberish(_ text: String) -> Bool {
            // Check for repeating characters (more than 2 in a row)
            let repeatingPattern = text.contains(regex: #"(.)\1{2,}"#)
            if repeatingPattern {
                return true
            }
            
            // Check for random consonant strings
            let consonantPattern = text.contains(regex: #"[bcdfghjklmnpqrstvwxz]{5,}"#)
            if consonantPattern {
                return true
            }
            
            // Split into words
            let words = text.lowercased().split(separator: " ").map(String.init)
            
            // Check if any word is in our known valid words
            let knownWords = greetings.union(insuranceKeywords).union(validShortPhrases).union(commonEnglishWords)
            let hasKnownWord = words.contains { knownWords.contains($0) }
            
            // If the text has no known words and is longer than 3 characters, consider it gibberish
            if !hasKnownWord && text.count > 3 {
                return true
            }
            
            return false
        }
        
        static func validateInput(_ text: String) -> (isValid: Bool, error: String?) {
            let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
            let lowercasedText = trimmedText.lowercased()
            
            // Check for empty input
            guard !trimmedText.isEmpty else {
                return (false, "Please enter a message.")
            }
            
            // Check for gibberish
            if isGibberish(trimmedText) {
                return (false, "I don't understand your message. Could you please rephrase it?")
            }
            
            // Allow greetings and common phrases
            if greetings.contains(lowercasedText) || validShortPhrases.contains(lowercasedText) {
                return (true, nil)
            }
            
            // For other inputs, check for minimum length
            guard trimmedText.count >= 2 else {
                return (false, "Your message is too short. Please provide more details.")
            }
            
            // For longer messages, check for basic meaning
            let tagger = NLTagger(tagSchemes: [.lexicalClass])
            tagger.string = trimmedText
            
            var hasVerb = false
            var hasNoun = false
            var hasInterjection = false
            var wordCount = 0
            
            tagger.enumerateTags(in: trimmedText.startIndex..<trimmedText.endIndex, unit: .word, scheme: .lexicalClass) { tag, tokenRange in
                if tag == .verb { hasVerb = true }
                if tag == .noun { hasNoun = true }
                if tag == .interjection { hasInterjection = true }
                wordCount += 1
                return true
            }
            
            // For longer inputs (more than 2 words), require proper sentence structure
            if wordCount > 2 && !hasVerb && !hasNoun {
                return (false, "Please provide a complete sentence or question.")
            }
            
            // Check sentiment only for longer phrases
            if trimmedText.count > 5 {
                let tagger2 = NLTagger(tagSchemes: [.sentimentScore])
                tagger2.string = trimmedText
                
                if let sentiment = tagger2.tag(at: trimmedText.startIndex, unit: .paragraph, scheme: .sentimentScore).0,
                   let score = Double(sentiment.rawValue),
                   score == 0 {
                    // Only reject if we haven't found any valid structure
                    if !hasVerb && !hasNoun && !hasInterjection {
                        return (false, "I don't understand your message. Could you please rephrase it?")
                    }
                }
            }
            
            return (true, nil)
        }
        
        static func determineIntent(_ text: String) -> MessageIntent {
            let words = text.lowercased().split(separator: " ").map(String.init)
            let wordSet = Set(words)
            
            // Check if it's a greeting
            if !greetings.intersection(wordSet).isEmpty || greetings.contains(text.lowercased()) {
                return .greeting
            }
            
            // Check if it's appointment related
            if !appointmentKeywords.intersection(wordSet).isEmpty {
                return .appointment
            }
            
            // Check if it's insurance related
            if !insuranceKeywords.intersection(wordSet).isEmpty {
                return .insurance
            }
            
            return .other
        }
    }
}

// Add String extension for regex
extension String {
    func contains(regex pattern: String) -> Bool {
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            return false
        }
        let range = NSRange(location: 0, length: utf16.count)
        return regex.firstMatch(in: self, options: [], range: range) != nil
    }
}

// MARK: - Main View
struct ChatbotView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showWelcome = true
    @State private var messageText = ""
    @State private var messages: [Chat.Message] = []
    @State private var hasShownInsuranceInfo = false
    @State private var showScheduleView = false
    
    var body: some View {
        ZStack {
            if showWelcome {
                welcomeView
            } else {
                chatView
            }
        }
        .sheet(isPresented: $showScheduleView) {
            ScheduleView()
        }
    }
    
    private var welcomeView: some View {
        VStack {
            HStack {
                Button(action: {}) {
                    Image("Menu Icon")
                        .resizable()
                        .frame(width: 24, height: 24)
                }
                Spacer()
                Button(action: { dismiss() }) {
                    Image("Option Icon")
                        .resizable()
                        .frame(width: 24, height: 24)
                }
            }
            .padding()
            
            Spacer()
            
            Image("Bot Icon")
                .resizable()
                .frame(width: 120, height: 120)
                .clipShape(Circle())
                .padding(.bottom, 20)
            
            Text("Hello, I'm SHIPSmart!")
                .font(.title)
                .fontWeight(.bold)
                .padding(.bottom, 8)
            
            Text("How can I help you today?")
                .font(.title2)
                .foregroundColor(.gray)
            
            Spacer()
            
            Button(action: { showWelcome = false }) {
                Text("Get Started")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(25)
            }
            .padding()
        }
    }
    
    private var chatView: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: {}) {
                    Image("Menu Icon")
                        .resizable()
                        .frame(width: 24, height: 24)
                }
                Spacer()
                Button(action: { dismiss() }) {
                    Image("Option Icon")
                        .resizable()
                        .frame(width: 24, height: 24)
                }
            }
            .padding()
            
            // Chat messages
            ScrollView {
                LazyVStack(spacing: 20) {
                    if messages.isEmpty {
                        Chat.BubbleView(
                            message: Chat.Message(
                                content: "Hi! I'm SHIPSmart!\nHow can I help you today?",
                                isUser: false
                            ),
                            onYesPressed: {},
                            onNoPressed: {}
                        )
                    }
                    
                    ForEach(messages) { message in
                        Chat.BubbleView(
                            message: message,
                            onYesPressed: { handleYesResponse() },
                            onNoPressed: { handleNoResponse() }
                        )
                    }
                }
                .padding(.vertical)
            }
            
            // Message input
            HStack(spacing: 12) {
                TextField("Enter your message", text: $messageText)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(25)
                
                Button(action: sendMessage) {
                    Image(systemName: "arrow.up.circle.fill")
                        .resizable()
                        .frame(width: 32, height: 32)
                        .foregroundColor(.blue)
                }
            }
            .padding()
        }
    }
    
    private func sendMessage() {
        let text = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        
        // Validate input
        let validation = Chat.InputValidation.validateInput(text)
        
        // Add user message
        messages.append(Chat.Message(
            content: text,
            isUser: true,
            isError: !validation.isValid
        ))
        
        messageText = ""
        
        // If input is invalid, show error message
        if !validation.isValid {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                messages.append(Chat.Message(
                    content: validation.error ?? "I don't understand your message. Could you please rephrase it?",
                    isUser: false,
                    isError: true
                ))
            }
            return
        }
        
        // Determine the intent of the message
        let intent = Chat.InputValidation.determineIntent(text)
        
        // Generate appropriate response based on intent
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            switch intent {
            case .greeting:
                messages.append(Chat.Message(
                    content: "Hello! How can I help you today?",
                    isUser: false
                ))
                
            case .appointment:
                messages.append(Chat.Message(
                    content: "I'll help you schedule an appointment. You can choose from our available doctors and time slots.",
                    isUser: false
                ))
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    showScheduleView = true
                }
                
            case .insurance:
                if !hasShownInsuranceInfo {
                    messages.append(Chat.Message(
                        content: """
                        Here are the benefits and coverage details of your UC SHIP insurance:
                        
                        Medical Coverage:
                        • Primary care visits: $17 copay
                        • Specialist visits: $25 copay
                        • Emergency room: $125 copay
                        • Urgent care: $25 copay
                        
                        Prescription Coverage:
                        • Generic: $5 copay
                        • Brand name: $25 copay
                        • Specialty: $25 copay
                        
                        Would you like to know more specific details about any of these benefits?
                        """,
                        isUser: false,
                        showButtons: true
                    ))
                    hasShownInsuranceInfo = true
                } else {
                    messages.append(Chat.Message(
                        content: "Which specific aspect of your insurance coverage would you like to know more about?",
                        isUser: false
                    ))
                }
                
            case .other:
                if messages.count == 1 {
                    messages.append(Chat.Message(
                        content: """
                        Sure! To get started, I'll need to look up your UC SHIP info. Could you please share the following:
                        · Student ID
                        · Date of Birth (MM/DD/YYYY)
                        · Medical ID (if available)
                        """,
                        isUser: false
                    ))
                } else if messages.count == 3 {
                    messages.append(Chat.Message(
                        content: """
                        Got it! Just to confirm, here's what I have:
                        · Student ID: 012345678
                        · Date of Birth: 01/23/2006
                        · Medical ID: UCSHIP123456
                        Does everything look correct?
                        """,
                        isUser: false,
                        showButtons: true
                    ))
                } else {
                    messages.append(Chat.Message(
                        content: "I understand. How else can I assist you today?",
                        isUser: false
                    ))
                }
            }
        }
    }
    
    private func handleYesResponse() {
        messages.append(Chat.Message(
            content: "Great! I'll proceed with looking up your benefits.",
            isUser: false
        ))
    }
    
    private func handleNoResponse() {
        messages.append(Chat.Message(
            content: "I apologize for the confusion. Could you please provide the correct information?",
            isUser: false
        ))
    }
}

#Preview {
    ChatbotView()
} 

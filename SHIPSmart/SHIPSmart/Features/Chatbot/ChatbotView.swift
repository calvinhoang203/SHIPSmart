import SwiftUI
import NaturalLanguage

// MARK: - Models and Components

enum ChatComponents {
    struct Message: Identifiable {
        var id = UUID()
        let content: String
        let isUser: Bool
        var isError: Bool
        var showButtons: Bool
        var showDoctors: Bool
        
        init(
            content: String,
            isUser: Bool,
            isError: Bool = false,
            showButtons: Bool = false,
            showDoctors: Bool = false
        ) {
            self.id = UUID()
            self.content = content
            self.isUser = isUser
            self.isError = isError
            self.showButtons = showButtons
            self.showDoctors = showDoctors
        }
    }
    
    struct Doctor: Identifiable {
        let id = UUID()
        let name: String
        let specialty: String
        let image: String
        let rating: Double
    }
    
    struct DoctorCard: View {
        let doctor: Doctor
        let onSelect: (Doctor) -> Void
        
        var body: some View {
            Button(action: { onSelect(doctor) }) {
                Image(doctor.image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 350, height: 90)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
    }
    
    struct BubbleView: View {
        let message: Message
        let onYesPressed: () -> Void
        let onNoPressed: () -> Void
        let onDoctorSelected: ((Doctor) -> Void)?
        
        private let doctors = [
            Doctor(name: "Dr. Jane Smith", specialty: "Primary Care", image: "Doctor 1", rating: 4.5),
            Doctor(name: "Dr. Michael Chen", specialty: "Dentistry",   image: "Doctor 2", rating: 4.8),
            Doctor(name: "Dr. Sarah Johnson", specialty: "Mental Health", image: "Doctor 3", rating: 5.0)
        ]
        
        var body: some View {
            VStack(spacing: 16) {
                HStack {
                    if message.isUser { Spacer() }
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
                                    message.isError
                                        ? Color.red.opacity(0.1)
                                        : (message.isUser ? Color.blue : Color(.systemGray6))
                                )
                                .foregroundColor(
                                    message.isError ? .red : (message.isUser ? .white : .primary)
                                )
                                .cornerRadius(20)
                        }
                        
                        if message.showButtons {
                            HStack(spacing: 20) {
                                Button("Yes", action: onYesPressed)
                                    .fontWeight(.medium)
                                    .foregroundColor(.white)
                                    .frame(width: 120)
                                    .padding(.vertical, 12)
                                    .background(Color.green)
                                    .cornerRadius(25)
                                Button("No", action: onNoPressed)
                                    .fontWeight(.medium)
                                    .foregroundColor(.white)
                                    .frame(width: 120)
                                    .padding(.vertical, 12)
                                    .background(Color.red)
                                    .cornerRadius(25)
                            }
                        }
                        
                        if message.showDoctors {
                            VStack(spacing: 16) {
                                ForEach(doctors) { doc in
                                    DoctorCard(doctor: doc, onSelect: onDoctorSelected!)
                                }
                            }
                        }
                    }
                    if !message.isUser { Spacer() }
                }
                .padding(.horizontal)
            }
        }
    }
    
    enum MessageIntent { case greeting, insurance, appointment, other }
    
    enum InputValidation {
        static let greetings: Set<String> = ["hi","hey","hello","good morning","good afternoon","good evening","morning","afternoon","evening"]
        static let insuranceKeywords: Set<String> = ["benefits","coverage","insurance","covered","plan","medical","health","dental","vision","prescription","copay","deductible","premium"]
        static let appointmentKeywords: Set<String> = ["appointment","appointments","schedule","book","visit","see a doctor","doctor","consultation","checkup","check-up","meet","available","slot","time","date"]
        static let validShort: Set<String> = ["yes","no","ok","okay","thanks","thank you","bye","goodbye","sure","please"]
        static let commonWords: Set<String> = ["i","you","he","she","it","we","they","am","is","are","was","were","have","has","had","do","does","did","can","could","will","would","should","my","your","his","her","its","our","their","this","that","these","those","what","when","where","why","how","need","want","like","help","know","tell","show","find","get","see","look","ask"]
        
        static func containsGibberish(_ text: String) -> Bool {
            if text.contains(regex: #"(.)\1{2,}"#) { return true }
            if text.contains(regex: #"[bcdfghjklmnpqrstvwxz]{5,}"#) { return true }
            let words = text.lowercased().split(separator: " ").map(String.init)
            let known = greetings
                .union(insuranceKeywords)
                .union(validShort)
                .union(commonWords)
                .union(appointmentKeywords)
            return !words.contains(where: { known.contains($0) }) && text.count > 3
        }
        
        static func validate(_ text: String) -> (Bool,String?) {
            let t = text.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !t.isEmpty else { return (false, "Please enter a message.") }
            if containsGibberish(t) { return (false, "I don't understand your message. Could you please rephrase it?") }
            let lower = t.lowercased()
            if greetings.contains(lower) || validShort.contains(lower) { return (true,nil) }
            guard t.count >= 2 else { return (false, "Your message is too short. Please provide more details.") }
            let tagger = NLTagger(tagSchemes: [.lexicalClass])
            tagger.string = t
            var hasVerb = false, hasNoun = false, count = 0
            tagger.enumerateTags(in: t.startIndex..<t.endIndex, unit: .word, scheme: .lexicalClass) { tag, _ in
                if tag == .verb { hasVerb = true }
                if tag == .noun { hasNoun = true }
                count += 1
                return true
            }
            if count > 2 && !hasVerb && !hasNoun {
                return (false, "Please provide a complete sentence or question.")
            }
            return (true,nil)
        }
        
        static func intent(of text: String) -> MessageIntent {
            let lower = text.lowercased()
            if appointmentKeywords.contains(where: { lower.contains($0) }) { return .appointment }
            if greetings.contains(where: { lower.contains($0) })    { return .greeting }
            if insuranceKeywords.contains(where: { lower.contains($0) }) { return .insurance }
            return .other
        }
    }
}

extension String {
    func contains(regex pattern: String) -> Bool {
        guard let r = try? NSRegularExpression(pattern: pattern) else { return false }
        return r.firstMatch(in: self, options: [], range: NSRange(startIndex..., in: self)) != nil
    }
}

// Three‑Dot Typing Indicator
struct ThreeDotIndicator: View {
    @State private var phase = 0
    let timing: TimeInterval = 0.4
    
    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<3) { idx in
                Circle()
                    .frame(width: 8, height: 8)
                    .opacity(phase == idx ? 1 : 0.3)
            }
        }
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: timing, repeats: true) { _ in
                phase = (phase + 1) % 3
            }
        }
    }
}

// MARK: - Main View

struct ChatbotView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var api = CerebrasAPI()
    @State private var messages: [ChatComponents.Message] = []
    @State private var inputText = ""
    @State private var isTyping = false
    
    @State private var selectedDoctor: ChatComponents.Doctor?
    @State private var isBookingConfirmation = false
    
    var body: some View {
        VStack(spacing: 0) {
            chatHeader
            
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(messages) { m in
                        ChatComponents.BubbleView(
                            message: m,
                            onYesPressed: handleYesResponse,
                            onNoPressed: handleNoResponse,
                            onDoctorSelected: handleDoctorSelected
                        )
                    }
                    if isTyping {
                        HStack {
                            ThreeDotIndicator()
                            Spacer()
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            
            inputArea
        }
        .onAppear(perform: addWelcomeMessage)
    }
    
    private var chatHeader: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
                    .foregroundColor(.blue)
            }
            Spacer()
            Text("Chat with SHIPSmart")
                .font(.headline)
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
        .shadow(radius: 1)
    }
    
    private var inputArea: some View {
        HStack(spacing: 12) {
            TextField("Type a message…", text: $inputText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .onSubmit { sendMessage() }
            
            Button(action: sendMessage) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(inputText.isEmpty ? .gray : .blue)
            }
            .disabled(inputText.isEmpty)
        }
        .padding()
        .background(Color(.systemBackground))
    }
    
    // MARK: - Helpers
    
    private func withLoading(_ work: @escaping () async -> Void) {
        isTyping = true
        Task {
            // always show loading first
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            await work()
            isTyping = false
        }
    }
    
    private func addWelcomeMessage() {
        messages.append(.init(
            content: "Hello! I'm SHIPSmart, your UC SHIP assistant. How can I help you today?",
            isUser: false, isError: false, showButtons: false, showDoctors: false
        ))
    }
    
    private func sendMessage() {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        
        messages.append(.init(content: text, isUser: true))
        inputText = ""
        
        let intent = ChatComponents.InputValidation.intent(of: text)
        if intent == .appointment {
            withLoading {
                messages.append(.init(
                    content: "I'll help you schedule an appointment. Please choose from our available doctors below:",
                    isUser: false, showDoctors: true))
            }
            return
        }
        
        let (valid, error) = ChatComponents.InputValidation.validate(text)
        if !valid {
            withLoading {
                messages.append(.init(
                    content: error!, isUser: false, isError: true))
            }
            return
        }
        
        withLoading {
            do {
                let response = try await api.sendMessage(text)
                messages.append(.init(
                    content: response,
                    isUser: false,
                    showButtons: response.contains("Does everything look correct?"),
                    showDoctors: response.contains("choose from available doctors")
                ))
            } catch {
                messages.append(.init(
                    content: "Sorry, I encountered an error. Please try again.",
                    isUser: false, isError: true))
            }
        }
    }
    
    private func handleYesResponse() {
        if isBookingConfirmation, let doctor = selectedDoctor {
            messages.append(.init(content: "Yes", isUser: true))
            withLoading {
                messages.append(.init(
                    content: "🎉 Your appointment with \(doctor.name) has been booked! Anything else I can help with?",
                    isUser: false, showButtons: true))
                isBookingConfirmation = false
                selectedDoctor = nil
            }
        } else {
            reply("yes")
        }
    }
    
    private func handleNoResponse() {
        messages.append(.init(content: "No", isUser: true))
        // final “anything else?” handler
        if !isBookingConfirmation,
           let last = messages.last(where: { !$0.isUser && $0.showButtons })
        {
            withLoading {
                messages.append(.init(
                    content: "Alright! Glad I could help. Have a wonderful day!",
                    isUser: false))
            }
            return
        }
        reply("no")
    }
    
    private func reply(_ answer: String) {
        withLoading {
            do {
                let response = try await api.sendMessage(answer)
                messages.append(.init(
                    content: response,
                    isUser: false,
                    showButtons: response.contains("Does everything look correct?"),
                    showDoctors: response.contains("choose from available doctors")
                ))
            } catch {
                messages.append(.init(
                    content: "Sorry, I encountered an error. Please try again.",
                    isUser: false, isError: true))
            }
        }
    }
    
    private func handleDoctorSelected(_ doctor: ChatComponents.Doctor) {
        selectedDoctor = doctor
        isBookingConfirmation = true
        withLoading {
            messages.append(.init(
                content: "Great choice! \(doctor.name) is available next week. Would you like me to book a slot?",
                isUser: false, showButtons: true))
        }
    }
}

// MARK: - Preview

#Preview {
    ChatbotView()
}

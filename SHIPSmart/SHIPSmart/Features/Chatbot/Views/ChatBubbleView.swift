import SwiftUI

public struct ChatBubbleView: View {
    private let message: ChatMessage
    private let onYesPressed: () -> Void
    private let onNoPressed: () -> Void
    
    public init(
        message: ChatMessage,
        onYesPressed: @escaping () -> Void,
        onNoPressed: @escaping () -> Void
    ) {
        self.message = message
        self.onYesPressed = onYesPressed
        self.onNoPressed = onNoPressed
    }
    
    public var body: some View {
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
                        .background(message.isUser ? Color.blue : Color(.systemGray6))
                        .foregroundColor(message.isUser ? .white : .black)
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
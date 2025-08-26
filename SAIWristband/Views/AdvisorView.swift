import SwiftUI

struct AdvisorView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var messageText = ""
    @State private var messages: [ChatMessage] = [
        ChatMessage(
            id: UUID(),
            content: "AI Health Suggestions\nToday's suggestion: Try to incorporate more green vegetables into your diet to improve your vitamin intake. Consider a 20-minute afternoon walk for better cardiovascular health.",
            isUser: false,
            timestamp: Date()
        ),
        ChatMessage(
            id: UUID(),
            content: "Keep the rainbow law in mind. Choose a variety of vegetables of different colors (dark green, red/orange, purple, white, etc.) every day or every week as much as possible. The richer the color, the more comprehensive the nutrition.",
            isUser: false,
            timestamp: Date()
        )
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // 自定义导航栏
            customNavigationBar(onBack: {
                dismiss()
            })
            
            // 分割线
            Divider()
                .background(Color.gray.opacity(0.3))
            
            // 聊天界面内容
            ScrollView {
                LazyVStack(spacing: 16) {
                    // 顶部插画（来自设计稿）
                    
                    MessageBubble(message: messages[0])
                    
                    HStack {
                        Spacer()
                        AsyncImage(url: Bundle.main.url(forResource: "advisor_illustration-3c1daa", withExtension: "png")) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        } placeholder: {
                            Rectangle()
                                .fill(Color(red: 0.969, green: 0.961, blue: 1.0))
                        }
                        .frame(width: 100, height: 100)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    .padding(.trailing, 16)
                    .padding(.vertical, 8)
                    
                    MessageBubble(message: messages[1])
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
            }
            
            // 底部输入框
            bottomInputView
        }
        .background(Color.white)
        .navigationBarHidden(true)
    }
    
    // 自定义导航栏
    struct customNavigationBar: View {
        let onBack: () -> Void
        
        var body: some View {
            HStack {
                // 返回按钮
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(Color(red: 0.03, green: 0.03, blue: 0.03))
                        .frame(width: 44, height: 44)
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                }
                
                Spacer()
                
                // 标题
                Text("Blood Glucose testing")
                    .font(.custom("Montserrat", size: 18))
                    .fontWeight(.regular)
                    .foregroundColor(Color(red: 0.03, green: 0.03, blue: 0.03))
                
                Spacer()
                
                // 占位视图保持对称
                Color.clear
                    .frame(width: 44, height: 44)
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 16)
            .background(Color.white)
        }
    }
    
    // 底部输入框
    private var bottomInputView: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                // 输入框
                HStack {
                    TextField("Type your question here...", text: $messageText)
                        .font(.system(size: 14, weight: .regular, design: .default))
                        .foregroundColor(Color(red: 0.012, green: 0.012, blue: 0.012))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 9.5)
                }
                .frame(height: 36)
                .background(Color(red: 0.918, green: 0.886, blue: 0.933))
                .cornerRadius(8)
                
                Spacer()
                
                // 发送按钮
                Button(action: sendMessage) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(Color(red: 0.427, green: 0.235, blue: 0.463))
                }
                .frame(width: 32, height: 32)
            }
            .padding(.horizontal, 31)
            .padding(.vertical, 15)
        }
        .background(Color.white)
        .shadow(color: Color.black.opacity(0.16), radius: 8, x: 0, y: -2)
    }
    
    private func sendMessage() {
        guard !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let userMessage = ChatMessage(
            id: UUID(),
            content: messageText,
            isUser: true,
            timestamp: Date()
        )
        
        messages.append(userMessage)
        messageText = ""
        
        // 模拟AI回复
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let aiResponse = ChatMessage(
                id: UUID(),
                content: "Thank you for your question. I'm here to help you with health advice based on your data. How can I assist you today?",
                isUser: false,
                timestamp: Date()
            )
            messages.append(aiResponse)
        }
    }
}

// 消息气泡组件
struct MessageBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.isUser {
                Spacer()
                userMessageBubble
            } else {
                aiMessageBubble
                Spacer()
            }
        }
    }
    
    private var userMessageBubble: some View {
        Text(message.content)
            .font(.system(size: 14, weight: .regular, design: .default))
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(red: 0.427, green: 0.235, blue: 0.463))
            .cornerRadius(20)
            .frame(maxWidth: UIScreen.main.bounds.width * 0.7, alignment: .trailing)
    }
    
    private var aiMessageBubble: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(message.content)
                .font(.system(size: 14, weight: .regular, design: .default))
                .foregroundColor(Color(red: 0.129, green: 0.137, blue: 0.251))
                .padding(.horizontal, 32)
                .padding(.vertical, 16)
                .background(Color(red: 0.969, green: 0.961, blue: 1.0))
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color(red: 0.898, green: 0.906, blue: 0.925), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.16), radius: 8, x: 0, y: 2)
                .frame(maxWidth: UIScreen.main.bounds.width * 0.8, alignment: .leading)
        }
    }
}

// 聊天消息模型
struct ChatMessage: Identifiable {
    let id: UUID
    let content: String
    let isUser: Bool
    let timestamp: Date
}

#Preview {
    AdvisorView()
}

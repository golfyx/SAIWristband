//
//  LoginView.swift
//  SAIWristband
//
//  Created by golfy xiong on 2025/8/22.
//

import SwiftUI

// MARK: - Haptic Feedback Helper
struct HapticFeedback {
    static let impact = UIImpactFeedbackGenerator(style: .medium)
    static let selection = UISelectionFeedbackGenerator()
    static let notification = UINotificationFeedbackGenerator()
}

struct LoginView: View {
    @EnvironmentObject var appState: AppState
    @State private var emailOrMobile = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showingSignUp = false
    @Binding var isLoggedIn: Bool
    @FocusState private var focusedField: Field?
    
    enum Field {
        case email, password
    }
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            
            // 根据设计稿 375×667 计算缩放比例
            let scaleX = screenWidth / 375.0
            let scaleY = screenHeight / 667.0
            let scale = min(scaleX, scaleY) // 使用较小的比例确保内容不会被裁剪
            
            ZStack {
                // 整体白色背景
                Color.white
                    .ignoresSafeArea()
                
                // 带阴影的白色容器
                VStack {
                    Spacer()
                    
                    VStack(spacing: 0) {
                        // 标题部分
                        VStack(spacing: scaled(4, scale)) {
                            Text("Welcome to")
                                .font(.custom("OpenSans-Bold", size: scaled(32, scale)))
                                .fontWeight(.bold)
                                .foregroundColor(Color(hex: "38143E"))
                            
                            Text("HealthWatch")
                                .font(.custom("OpenSans-Bold", size: scaled(32, scale)))
                            .fontWeight(.bold)
                                .foregroundColor(Color(hex: "38143E"))
                        }
                        .padding(.top, scaled(60, scale))
                        .padding(.bottom, scaled(46, scale))
                        
                        // 邮箱/手机号输入框
                        VStack(spacing: scaled(8, scale)) {
                            HealthWatchTextField(
                                placeholder: "Email/Mobile Number",
                                text: $emailOrMobile,
                                scale: scale
                            )
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                            .focused($focusedField, equals: .email)
                            .submitLabel(.next)
                            .onSubmit {
                                focusedField = .password
                            }
                        }
                        .padding(.horizontal, scaled(43, scale))
                        .padding(.bottom, scaled(8, scale))
                        
                        // 密码输入框
                        VStack(spacing: scaled(8, scale)) {
                            HealthWatchSecureField(
                                placeholder: "Password",
                                text: $password,
                                scale: scale
                            )
                            .focused($focusedField, equals: .password)
                            .submitLabel(.go)
                            .onSubmit {
                                handleLogin()
                            }
                        }
                        .padding(.horizontal, scaled(43, scale))
                        .padding(.bottom, scaled(15, scale))
                        
                        // 登录按钮
                        HealthWatchPrimaryButton(
                            title: isLoading ? "Logging in..." : "Login",
                            scale: scale,
                            isLoading: isLoading,
                            action: handleLogin
                        )
                        .disabled(emailOrMobile.isEmpty || password.isEmpty || isLoading)
                        .padding(.horizontal, scaled(43, scale))
                        .padding(.bottom, scaled(14, scale))
                        
                        // 注册按钮
                        HealthWatchSecondaryButton(
                            title: "Register",
                            scale: scale,
                            action: handleRegister
                        )
                        .padding(.horizontal, scaled(43, scale))
                        .padding(.bottom, scaled(31, scale))
                        
                        // 第三方登录部分 - 左边文字，右边图标组
                        HStack(alignment: .center) {
                            // 左侧标题
                            Text("Login with:")
                                .font(.custom("OpenSans-Regular", size: scaled(14, scale)))
                                .foregroundColor(Color(hex: "572D5F"))
                            
                            Spacer()
                            
                            // 右侧图标组
                            HStack(spacing: scaled(7, scale)) {
                                // 微信登录
                                ThirdPartyLoginButton(iconName: "message.fill", scale: scale)
                                
                                // Facebook 登录  
                                ThirdPartyLoginButton(iconName: "f.circle.fill", scale: scale)
                                
                                // Apple 登录
                                ThirdPartyLoginButton(iconName: "apple.logo", scale: scale)
                                
                                // Google 登录
                                ThirdPartyLoginButton(iconName: "globe", scale: scale)
                            }
                        }
                        .padding(.horizontal, scaled(43, scale))
                        .padding(.bottom, scaled(21, scale))
                        
                        // 忘记密码
                        Button(action: handleForgotPassword) {
                            Text("Forgot Password?")
                                .font(.custom("OpenSans-Regular", size: scaled(14, scale)))
                                .foregroundColor(Color(hex: "572D5F"))
                        }
                        .padding(.bottom, scaled(60, scale))
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 12 * scale)
                            .fill(Color.white)
                            .shadow(
                                color: Color.black.opacity(0.1),
                                radius: 5 * scale,
                                x: 1 * scale,
                                y: -1 * scale
                            )
                    )
                    .padding(.horizontal, scaled(28, scale))
                    
                    Spacer()
                }
            }
        }
        .navigationBarHidden(true)
        .alert("Error", isPresented: $showError) {
            Button("OK") {
                showError = false
            }
        } message: {
            Text(errorMessage)
        }
        .fullScreenCover(isPresented: $showingSignUp) {
            SignUpView()
        }
    }
    
    // MARK: - Helper Function
    private func scaled(_ value: CGFloat, _ scale: CGFloat) -> CGFloat {
        return value * scale
    }
    
    private func handleLogin() {
        // 触觉反馈
        HapticFeedback.impact.impactOccurred()
        
        // 校验管理员账号（本地写死）
        let trimmedAccount = emailOrMobile.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPassword = password
        
        guard !trimmedAccount.isEmpty else {
            showErrorMessage("Please enter your email or mobile number")
            return
        }
        guard !trimmedPassword.isEmpty else {
            showErrorMessage("Please enter your password")
            return
        }
        
        // 显示加载状态
        isLoading = true
        focusedField = nil
        
        // 本地验证：只有管理员账号允许登录
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            if trimmedAccount.lowercased() == "admin" && trimmedPassword == "admin123" {
                isLoading = false
                HapticFeedback.notification.notificationOccurred(.success)
                // 更新全局状态为管理员用户
                let adminUser = User(id: "0", name: "Administrator", email: "admin@local", avatarURL: nil)
                appState.login(user: adminUser)
                isLoggedIn = true
            } else {
                isLoading = false
                showErrorMessage("仅管理员账号可登录：账号 admin，密码 admin123")
            }
        }
    }
    
    private func handleRegister() {
        // 触觉反馈
        HapticFeedback.selection.selectionChanged()
        showingSignUp = true
    }
    
    private func handleForgotPassword() {
        // 触觉反馈
        HapticFeedback.selection.selectionChanged()
        print("忘记密码")
    }
    
    private func showErrorMessage(_ message: String) {
        errorMessage = message
        showError = true
        HapticFeedback.notification.notificationOccurred(.error)
    }
}

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Custom Text Field
struct HealthWatchTextField: View {
    let placeholder: String
    @Binding var text: String
    let scale: CGFloat
    
    var body: some View {
        TextField(placeholder, text: $text)
            .font(.custom("OpenSans-Regular", size: 14 * scale))
            .foregroundColor(.primary)
            .padding(.horizontal, 8 * scale)
            .padding(.vertical, 10 * scale)
            .background(
                RoundedRectangle(cornerRadius: 8 * scale)
                    .fill(Color(hex: "E6E6E6"))
                    .shadow(
                        color: Color.black.opacity(0.16),
                        radius: 4 * scale,
                        x: 0,
                        y: 2 * scale
                    )
            )
            .frame(height: 38 * scale)
            .overlay(
                RoundedRectangle(cornerRadius: 8 * scale)
                    .stroke(Color.clear, lineWidth: 0)
            )
            // 增强可访问性
            .accessibilityLabel(placeholder)
            .accessibilityHint("Enter your email address or mobile number")
    }
}

// MARK: - Custom Secure Field
struct HealthWatchSecureField: View {
    let placeholder: String
    @Binding var text: String
    let scale: CGFloat
    
    var body: some View {
        SecureField(placeholder, text: $text)
            .font(.custom("OpenSans-Regular", size: 14 * scale))
            .foregroundColor(.primary)
            .padding(.horizontal, 8 * scale)
            .padding(.vertical, 10 * scale)
            .background(
                RoundedRectangle(cornerRadius: 8 * scale)
                    .fill(Color(hex: "E6E6E6"))
                    .shadow(
                        color: Color.black.opacity(0.16),
                        radius: 4 * scale,
                        x: 0,
                        y: 2 * scale
                    )
            )
            .frame(height: 38 * scale)
            .overlay(
                RoundedRectangle(cornerRadius: 8 * scale)
                    .stroke(Color.clear, lineWidth: 0)
            )
            // 增强可访问性
            .accessibilityLabel(placeholder)
            .accessibilityHint("Enter your password")
    }
}

// MARK: - Primary Button
struct HealthWatchPrimaryButton: View {
    let title: String
    let scale: CGFloat
    var isLoading: Bool = false
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                }
                Text(title)
                    .font(.custom("OpenSans-Regular", size: 14 * scale))
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 36 * scale)
            .background(
                RoundedRectangle(cornerRadius: 8 * scale)
                    .fill(Color(hex: "9A1AF2"))
                    .shadow(
                        color: Color.black.opacity(0.16),
                        radius: 4 * scale,
                        x: 0,
                        y: 2 * scale
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(isLoading)
        .opacity(isLoading ? 0.8 : 1.0)
        // 增强可访问性
        .accessibilityLabel(isLoading ? "Logging in, please wait" : "Login")
        .accessibilityHint("Double tap to log in with your credentials")
    }
}

// MARK: - Secondary Button
struct HealthWatchSecondaryButton: View {
    let title: String
    let scale: CGFloat
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.custom("OpenSans-Regular", size: 14 * scale))
                .foregroundColor(Color(hex: "572D5F"))
                .frame(maxWidth: .infinity)
                .frame(height: 38 * scale)
                .background(
                    RoundedRectangle(cornerRadius: 8 * scale)
                        .fill(Color.white)
                        .shadow(
                            color: Color.black.opacity(0.16),
                            radius: 4 * scale,
                            x: 0,
                            y: 2 * scale
                        )
                )
        }
        .buttonStyle(PlainButtonStyle())
        // 增强可访问性
        .accessibilityLabel(title)
        .accessibilityHint("Double tap to create a new account")
    }
}

// MARK: - Third Party Login Button
struct ThirdPartyLoginButton: View {
    let iconName: String
    let scale: CGFloat
    
    var body: some View {
        Button(action: {
            // 第三方登录逻辑
            HapticFeedback.selection.selectionChanged()
        }) {
            Image(systemName: iconName)
                .font(.system(size: 12 * scale))
                .foregroundColor(Color(hex: "9A1AF2"))
                .frame(width: 19 * scale, height: 19 * scale)
                .background(
                    RoundedRectangle(cornerRadius: 6 * scale)
                        .fill(Color.white)
                        .shadow(
                            color: Color.black.opacity(0.16),
                            radius: 4 * scale,
                            x: 0,
                            y: 2 * scale
                        )
                )
        }
        .buttonStyle(PlainButtonStyle())
        // 增强可访问性
        .accessibilityLabel(getAccessibilityLabel(for: iconName))
        .accessibilityHint("Double tap to sign in with this service")
    }
    
    private func getAccessibilityLabel(for iconName: String) -> String {
        switch iconName {
        case "apple.logo": return "Sign in with Apple"
        case "globe": return "Sign in with Google"
        case "f.circle.fill": return "Sign in with Facebook"
        case "message.fill": return "Sign in with WeChat"
        default: return "Third party sign in"
        }
    }
}

#Preview {
    LoginView(isLoggedIn: .constant(false))
}

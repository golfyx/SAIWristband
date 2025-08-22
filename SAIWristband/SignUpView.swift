//
//  SignUpView.swift
//  SAIWristband
//
//  Created by golfy xiong on 2025/8/22.
//

import SwiftUI

struct SignUpView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var appState: AppState
    
    @State private var email: String = ""
    @State private var verificationCode: String = ""
    @State private var isEmailValid: Bool = true
    @State private var isVerificationCodeValid: Bool = true
    @State private var showingLogin = false
    @State private var isLoading = false
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    @FocusState private var focusedField: Field?
    
    enum Field {
        case email, verificationCode
    }
    
    // 基于 375x667 (@1x) 设计稿的缩放比例
    private let baseWidth: CGFloat = 375
    private var scaleFactor: CGFloat {
        UIScreen.main.bounds.width / baseWidth
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 整体白色背景
                Color.white
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 0) {
                        // Logo区域
                        VStack(spacing: 0) {
                            Spacer()
                                .frame(height: scaled(73.5))
                            
                            // HealthWatch Logo
                            Image("health_watch_logo")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: scaled(132), height: scaled(134))
                                .shadow(color: .black.opacity(0.08), radius: 0, x: 0, y: 0)
                        }
                        
                        Spacer()
                            .frame(height: scaled(49))
                        
                        // 标题区域
                        VStack(spacing: scaled(10)) {
                            // HealthWatch 主标题
                            Text("HealthWatch")
                                .font(.system(size: scaled(34), weight: .bold, design: .monospaced))
                                .foregroundColor(Color(red: 0.22, green: 0.08, blue: 0.24)) // #38143E
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                            
                            // 副标题
                            Text("Sign up for health insights")
                                .font(.system(size: scaled(16), weight: .regular, design: .monospaced))
                                .foregroundColor(Color(red: 0.22, green: 0.08, blue: 0.24)) // #38143E
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                        }
                        
                        Spacer()
                            .frame(height: scaled(45))
                        
                        // 表单区域
                        VStack(spacing: scaled(20)) {
                            // 邮箱输入区域
                            VStack(alignment: .leading, spacing: scaled(8)) {
                                // 邮箱标签
                                HStack {
                                    Text("Email *")
                                        .font(.system(size: scaled(14), weight: .bold, design: .monospaced))
                                        .foregroundColor(Color(red: 0.34, green: 0.18, blue: 0.37)) // #572D5F
                                    Spacer()
                                }
                                .padding(.horizontal, scaled(24))
                                
                                // 邮箱输入框
                                CustomInputField(
                                    text: $email,
                                    placeholder: "user@example.com",
                                    isValid: $isEmailValid,
                                    keyboardType: .emailAddress,
                                    showVisibilityToggle: false,
                                    iconName: "envelope"
                                )
                                .focused($focusedField, equals: .email)
                                .submitLabel(.next)
                                .onSubmit {
                                    focusedField = .verificationCode
                                }
                                .padding(.horizontal, scaled(20))
                            }
                            
                            // 验证码输入区域
                            VStack(alignment: .leading, spacing: scaled(8)) {
                                // 验证码标签
                                HStack {
                                    Text("Verification Code *")
                                        .font(.system(size: scaled(14), weight: .bold, design: .monospaced))
                                        .foregroundColor(Color(red: 0.34, green: 0.18, blue: 0.37)) // #572D5F
                                    Spacer()
                                }
                                .padding(.horizontal, scaled(24))
                                
                                // 验证码输入框
                                CustomInputField(
                                    text: $verificationCode,
                                    placeholder: "************",
                                    isValid: $isVerificationCodeValid,
                                    keyboardType: .numberPad,
                                    showVisibilityToggle: true,
                                    iconName: "lock"
                                )
                                .focused($focusedField, equals: .verificationCode)
                                .submitLabel(.done)
                                .onSubmit {
                                    handleSignUp()
                                }
                                .padding(.horizontal, scaled(20))
                            }
                        }
                        
                        Spacer()
                            .frame(height: scaled(32))
                        
                        // 注册按钮
                        Button(action: handleSignUp) {
                            HStack {
                                Spacer()
                                Text("Register")
                                    .font(.system(size: scaled(16), weight: .bold, design: .monospaced))
                                    .foregroundColor(.white)
                                Spacer()
                            }
                            .frame(width: scaled(334), height: scaled(47))
                            .background(Color(red: 0.6, green: 0.1, blue: 0.95)) // #9A1AF2
                            .cornerRadius(0) // 无圆角，符合设计
                            .overlay(
                                RoundedRectangle(cornerRadius: 0)
                                    .stroke(Color.black, lineWidth: 1)
                            )
                            .shadow(color: .black.opacity(0.8), radius: 0, x: 2, y: 2) // 2px 2px 阴影
                        }
                        .buttonStyle(PlainButtonStyle())
                        .disabled(isLoading || email.isEmpty || verificationCode.isEmpty)
                        .opacity(isLoading || email.isEmpty || verificationCode.isEmpty ? 0.6 : 1.0)
                        
                        Spacer()
                            .frame(height: scaled(16))
                        
                        // 已有账号登录区域 - 左右布局
                        HStack(alignment: .center, spacing: scaled(12)) {
                            // 左侧文字
                            Text("Already a member?")
                                .font(.system(size: scaled(14), weight: .regular, design: .monospaced))
                                .foregroundColor(Color(red: 0.34, green: 0.18, blue: 0.37)) // #572D5F
                            
                            // 右侧登录按钮
                            Button(action: {
                                showingLogin = true
                            }) {
                                HStack(spacing: scaled(2)) {
                                    Text("Log")
                                        .font(.system(size: scaled(14), weight: .bold, design: .monospaced))
                                        .foregroundColor(Color(red: 0.34, green: 0.18, blue: 0.37)) // #572D5F
                                    Text("in")
                                        .font(.system(size: scaled(14), weight: .bold, design: .monospaced))
                                        .foregroundColor(Color(red: 0.34, green: 0.18, blue: 0.37)) // #572D5F
                                }
                                .padding(.horizontal, scaled(9))
                                .padding(.vertical, scaled(2.5))
                                .background(Color.white)
                                .cornerRadius(scaled(4))
                                .overlay(
                                    RoundedRectangle(cornerRadius: scaled(4))
                                        .stroke(Color.clear, lineWidth: 0)
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        
                        // 底部间距
                        Spacer()
                            .frame(height: scaled(40))
                    }
                    .frame(minHeight: geometry.size.height)
                }
            }
        }
        .navigationBarHidden(true)
        .alert("Error", isPresented: $showErrorAlert) {
            Button("OK") {
                showErrorAlert = false
            }
        } message: {
            Text(errorMessage)
        }
        .fullScreenCover(isPresented: $showingLogin) {
            LoginView(isLoggedIn: $appState.isLoggedIn)
        }
    }
    
    // 缩放函数，基于设计稿尺寸
    private func scaled(_ value: CGFloat) -> CGFloat {
        return value * scaleFactor
    }
    
    // 处理注册逻辑
    private func handleSignUp() {
        // 验证邮箱格式
        isEmailValid = isValidEmail(email)
        isVerificationCodeValid = !verificationCode.isEmpty && verificationCode.count >= 6
        
        // 检查邮箱是否为空
        if email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            showError("Please enter your email address")
            focusedField = .email
            return
        }
        
        // 检查邮箱格式
        if !isEmailValid {
            showError("Please enter a valid email address")
            focusedField = .email
            return
        }
        
        // 检查验证码是否为空
        if verificationCode.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            showError("Please enter the verification code")
            focusedField = .verificationCode
            return
        }
        
        // 检查验证码长度
        if verificationCode.count < 6 {
            showError("Verification code must be at least 6 characters")
            focusedField = .verificationCode
            return
        }
        
        if isEmailValid && isVerificationCodeValid {
            isLoading = true
            focusedField = nil // 收起键盘
            
            // 模拟注册请求
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                isLoading = false
                appState.isLoggedIn = true
                dismiss()
            }
        }
    }
    
    // 显示错误信息
    private func showError(_ message: String) {
        errorMessage = message
        showErrorAlert = true
    }
    
    // 邮箱格式验证
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
}

// 自定义输入框组件
struct CustomInputField: View {
    @Binding var text: String
    let placeholder: String
    @Binding var isValid: Bool
    let keyboardType: UIKeyboardType
    let showVisibilityToggle: Bool
    let iconName: String?
    
    @State private var isSecure: Bool = true
    @FocusState private var isFocused: Bool
    
    // 基于设计稿的缩放
    private let baseWidth: CGFloat = 375
    private var scaleFactor: CGFloat {
        UIScreen.main.bounds.width / baseWidth
    }
    
    private func scaled(_ value: CGFloat) -> CGFloat {
        return value * scaleFactor
    }
    
    var body: some View {
        ZStack {
            // 输入框背景
            RoundedRectangle(cornerRadius: 0)
                .fill(Color.white)
                .frame(height: scaled(48))
                .background(
                    RoundedRectangle(cornerRadius: 0)
                        .fill(Color(red: 0.9, green: 0.9, blue: 0.9).opacity(0.6)) // rgba(230, 230, 230, 0.6)
                        .shadow(color: .black.opacity(0.16), radius: 4, x: 0, y: 2)
                )
            
            HStack {
                // 输入框
                Group {
                    if showVisibilityToggle && isSecure {
                        SecureField("", text: $text)
                            .focused($isFocused)
                    } else {
                        TextField("", text: $text)
                            .focused($isFocused)
                            .keyboardType(keyboardType)
                    }
                }
                .font(.system(size: scaled(14), weight: .regular, design: .monospaced))
                .foregroundColor(Color(red: 0.29, green: 0.29, blue: 0.29)) // #4B4B4B
                .placeholder(when: text.isEmpty) {
                    Text(placeholder)
                        .font(.system(size: scaled(14), weight: .regular, design: .monospaced))
                        .foregroundColor(Color(red: 0.29, green: 0.29, blue: 0.29)) // #4B4B4B
                }
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                
                Spacer()
                
                // 图标区域
                HStack(spacing: scaled(8)) {
                    // 主图标（邮箱或锁）
                    if let iconName = iconName {
                        Image(systemName: iconName)
                            .font(.system(size: scaled(14)))
                            .foregroundColor(Color(red: 0.34, green: 0.18, blue: 0.37)) // #572D5F
                    }
                }
            }
            .padding(.horizontal, scaled(12))
        }
        .background(
            RoundedRectangle(cornerRadius: 0)
                .stroke(isValid ? Color.clear : Color.red, lineWidth: 1)
        )
    }
}

// 占位符扩展
extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {
        
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}



#Preview {
    SignUpView()
        .environmentObject(AppState())
}

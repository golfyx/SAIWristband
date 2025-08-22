//
//  WelcomeView.swift
//  SAIWristband
//
//  Created by golfy xiong on 2025/8/22.
//

import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject var appState: AppState
    @State private var showingLogin = false
    @State private var showingSignUp = false
    
    var body: some View {
        // 硬编码登录，直接显示主页
        if appState.isLoggedIn {
            TabBarView()
        } else {
            ZStack {
                // 背景颜色
                Color.white
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // 上半部分 - 背景图片区域
                    ZStack {
                        // 背景图片 - 自适应尺寸，扩展到安全区域
                        Image("welcome_background")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .clipped()
                            .ignoresSafeArea(.all, edges: .top) // 忽略顶部安全区域
                        
                        // 渐变遮罩层
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.black.opacity(0.3),
                                Color.clear,
                                Color.black.opacity(0.6)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .ignoresSafeArea(.all, edges: .top)
                    }
                    
                    // 固定间距：图片到按钮48像素
                    Spacer()
                        .frame(height: 88)
                    
                    // 按钮区域
                    VStack(spacing: 16) {
                        // 登录按钮 - 硬编码登录
                        CustomButton(
                            title: "Log in",
                            backgroundColor: Color(red: 0.6, green: 0.1, blue: 0.95), // #9A1AF2
                            textColor: .white,
                            action: {
                                // 硬编码登录
                                appState.login(user: User.sampleUser)
                            }
                        )
                        .frame(width: UIScreen.main.bounds.width * 0.872) // 327/375 = 0.872，保持设计稿比例
                        
                        // 注册按钮
                        CustomButton(
                            title: "Sign Up",
                            backgroundColor: .clear,
                            textColor: Color(red: 0.6, green: 0.1, blue: 0.95),
                            borderColor: Color(red: 0.6, green: 0.1, blue: 0.95),
                            action: {
                                // 硬编码登录
                                appState.login(user: User.sampleUser)
                            }
                        )
                        .frame(width: UIScreen.main.bounds.width * 0.872)
                    }
                    
                    // 固定间距：按钮到安全区域48像素
                    Spacer()
                        .frame(height: 48)
                }
            }
            .onAppear {
                // 2秒后自动登录，模拟启动界面
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    appState.login(user: User.sampleUser)
                }
            }
        }
    }
}

// 自定义按钮组件
struct CustomButton: View {
    let title: String
    let backgroundColor: Color
    let textColor: Color
    var borderColor: Color?
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Spacer()
                Text(title)
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundColor(textColor)
                Spacer()
            }
            .frame(height: 48) // 保持触摸友好的尺寸
            .background(backgroundColor)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(borderColor ?? Color.clear, lineWidth: borderColor != nil ? 1 : 0)
            )
            .cornerRadius(8)
            .shadow(color: .black.opacity(0.16), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// 按钮按压效果
struct PressableButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

#Preview {
    WelcomeView()
}

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
                // 背景层 - 完全独立，不影响布局
                Color.clear
                    .background(
                        Image("Image2")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    )
                    .clipped()
                    .ignoresSafeArea()
                
                // 内容层 - 不受背景影响的主要布局
                VStack(spacing: 0) {
                    // 文字内容区域
                    VStack(alignment: .leading, spacing: 0) {
                        Spacer()
                        
                        // 标题组 1: "Time for" / "Well-being"
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Time for")
                                .font(.system(size: 48, weight: .black))
                                .foregroundColor(.white)
                            Text("Well-being")
                                .font(.system(size: 48, weight: .black))
                                .foregroundColor(.white)
                        }
                        .padding(.leading, 11)
                        
                        // 标题组 2: "Elegance" / "Unfolds"
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Elegance")
                                .font(.system(size: 48, weight: .black))
                                .foregroundColor(.white)
                            Text("Unfolds")
                                .font(.system(size: 48, weight: .black))
                                .foregroundColor(.white)
                        }
                        .padding(.top, 50)
                        .padding(.leading, 11)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Spacer()
                    }
                    
                    // 按钮和点的区域 - 固定在底部
                    VStack(spacing: 16) {
                        PrimaryButton(title: "Log in", width: 327, height: 48) {
                            showingLogin = true
                        }
                        
                        // 分页指示点
                        HStack(spacing: 20) {
                            PageDot(isActive: false, size: 12)  // 第一个点激活
                            PageDot(isActive: false, size: 12)
                            PageDot(isActive: false, size: 12)
                        }
                    }
                    .padding(.bottom, 20) // 距离底部的安全距离
                }
            }
            .fullScreenCover(isPresented: $showingLogin) {
                LoginView(
                    isLoggedIn: Binding(
                        get: { appState.isLoggedIn },
                        set: { appState.isLoggedIn = $0 }
                    )
                )
            }
        }
    }
}

// 自定义主按钮
private struct PrimaryButton: View {
    let title: String
    let width: CGFloat
    let height: CGFloat
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Spacer()
                Text(title)
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
                Spacer()
            }
            .frame(width: width, height: height)
            .background(Color(red: 123/255, green: 43/255, blue: 177/255)) // #7B2BB1
            .cornerRadius(8)
            .shadow(color: Color.black.opacity(0.16), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// 分页点
private struct PageDot: View {
    let isActive: Bool
    let size: CGFloat
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.white)
                .frame(width: size, height: size)
            if isActive {
                Circle()
                    .fill(Color(red: 123/255, green: 43/255, blue: 177/255))
                    .frame(width: size - 2, height: size - 2)
            } else {
                Circle()
                    .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                    .frame(width: size - 2, height: size - 2)
            }
        }
        .overlay(
            Circle()
                .stroke(Color.clear, lineWidth: 0)
        )
    }
}

// 旧的自定义按钮保留以兼容其他页面（未使用）
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

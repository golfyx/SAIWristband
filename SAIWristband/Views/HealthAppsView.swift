//
//  HealthAppsView.swift
//  SAIWristband
//
//  Created by golfy xiong on 2025/8/24.
//

import SwiftUI

struct HealthAppsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @State private var authorizedApps: [HealthApp] = [
        HealthApp(name: "Apple Health", imageName: "Image18", isEnabled: true),
        HealthApp(name: "Samsung Health", imageName: "Image19", isEnabled: true),
        HealthApp(name: "Google Health", imageName: "Image20", isEnabled: true),
        HealthApp(name: "Withings", imageName: "Image21", isEnabled: true)
    ]
    
    @State private var unauthorizedApps: [HealthApp] = [
        HealthApp(name: "Whoop", imageName: "Image22", isEnabled: false),
        HealthApp(name: "Oura", imageName: "Image23", isEnabled: false),
        HealthApp(name: "Garmin", imageName: "Image24", isEnabled: false),
        HealthApp(name: "Hearty", imageName: "Image25", isEnabled: false)
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // 自定义导航栏
            HealthAppsNavigationBar(title: "Apps")
            
            // 内容区域
            ScrollView {
                VStack(spacing: 24) {
                    // Authorized 部分
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Authorized")
                            .font(.system(size: 20, weight: .regular))
                            .foregroundColor(AppTheme.primary7Text(colorScheme))
                            .padding(.horizontal, 16)
                        
                        HealthAppsCard(
                            apps: $authorizedApps
                        )
                    }
                    
                    // Unauthorized 部分
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Unauthorized")
                            .font(.system(size: 20, weight: .regular))
                            .foregroundColor(AppTheme.primary7Text(colorScheme))
                            .padding(.horizontal, 16)
                        
                        HealthAppsCard(
                            apps: $unauthorizedApps
                        )
                    }
                }
                .padding(.top, 16)
            }
        }
        .background(AppTheme.background(colorScheme))
        .navigationBarHidden(true)
    }
}

// MARK: - 自定义导航栏
struct HealthAppsNavigationBar: View {
    @Environment(\.dismiss) private var dismiss
    let title: String
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(AppTheme.primaryText(colorScheme))
                }
                
                Spacer()
                
                Text(title)
                    .font(.system(size: 18, weight: .regular))
                    .foregroundColor(AppTheme.primaryText(colorScheme))
                
                Spacer()
                
                // 占位符，保持标题居中
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.clear)
            }
            .padding(.horizontal, 28)
            .padding(.top, 12)
            .padding(.bottom, 16)
            
            // 下分割线
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(height: 0.5)
        }
        .background(AppTheme.cardBackground(colorScheme))
        .glassBackground(RoundedRectangle(cornerRadius: 0))
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 2)
    }
}

// MARK: - 健康应用卡片
struct HealthAppsCard: View {
    @Binding var apps: [HealthApp]
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(apps.enumerated()), id: \.offset) { index, app in
                VStack(spacing: 0) {
                    HealthAppRow(app: $apps[index])
                    
                    // 添加分割线，最后一个不添加
                    if index < apps.count - 1 {
                        Rectangle()
                            .fill(colorScheme == .dark ? Color(hex: "9A1AF2") : Color(hex: "9B4F96"))
                            .frame(height: 1)
                            .padding(.horizontal, 28)
                    }
                }
            }
        }
        .padding(.vertical, 16)
        .background(colorScheme == .dark ? Color(hex: "191919") : AppTheme.primary10)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(colorScheme == .dark ? Color(hex: "9A1AF2").opacity(0.3) : Color.clear, lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.25), radius: 2, x: -2, y: 2)
        .padding(.horizontal, 16)
    }
}

// MARK: - 健康应用行
struct HealthAppRow: View {
    @Binding var app: HealthApp
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        HStack(spacing: 12) { // 减少间距从16到12
            // 应用图标
            Image(app.imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 40, height: 40)
                .cornerRadius(12)
            
            // 应用名称 - 调整布局确保文字完整显示
            Text(app.name)
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(AppTheme.primary12Text(colorScheme))
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // 开关按钮 - 进一步缩小尺寸
            Toggle("", isOn: $app.isEnabled)
                .toggleStyle(SwitchToggleStyle(tint: colorScheme == .dark ? Color(hex: "9A1AF2") : AppTheme.primary12))
                .scaleEffect(0.7) // 从0.8减少到0.7
                .frame(width: 40) // 固定开关按钮的宽度
        }
        .padding(.horizontal, 20) // 减少水平内边距从24到20
        .padding(.vertical, 12)
    }
}

// MARK: - 健康应用模型
struct HealthApp: Identifiable {
    let id = UUID()
    let name: String
    let imageName: String
    var isEnabled: Bool
}

#Preview {
    HealthAppsView()
}

//
//  HealthAppsView.swift
//  SAIWristband
//
//  Created by golfy xiong on 2025/8/24.
//

import SwiftUI

struct HealthAppsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var authorizedApps: [HealthApp] = [
        HealthApp(name: "Apple Health", iconName: "heart.fill", isEnabled: true, color: Color(red: 0.61, green: 0.31, blue: 0.59)),
        HealthApp(name: "Samsung Health", iconName: "heart.fill", isEnabled: true, color: Color(red: 0.61, green: 0.31, blue: 0.59)),
        HealthApp(name: "Google Health", iconName: "heart.fill", isEnabled: false, color: Color(red: 0.61, green: 0.31, blue: 0.59)),
        HealthApp(name: "Withings", iconName: "heart.fill", isEnabled: true, color: Color(red: 0.61, green: 0.31, blue: 0.59))
    ]
    
    @State private var unauthorizedApps: [HealthApp] = [
        HealthApp(name: "Whoop", iconName: "heart.fill", isEnabled: false, color: Color(red: 0.31, green: 0.33, blue: 0.61)),
        HealthApp(name: "Oura", iconName: "heart.fill", isEnabled: false, color: Color(red: 0.31, green: 0.33, blue: 0.61)),
        HealthApp(name: "Garmin", iconName: "heart.fill", isEnabled: false, color: Color(red: 0.31, green: 0.33, blue: 0.61)),
        HealthApp(name: "Hearty", iconName: "heart.fill", isEnabled: false, color: Color(red: 0.31, green: 0.33, blue: 0.61))
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
                            .foregroundColor(Color(red: 0.36, green: 0.0, blue: 0.62))
                            .padding(.horizontal, 16)
                        
                        HealthAppsCard(
                            apps: $authorizedApps,
                            backgroundColor: Color(red: 0.99, green: 0.96, blue: 1.0)
                        )
                    }
                    
                    // Unauthorized 部分
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Unauthorized")
                            .font(.system(size: 20, weight: .regular))
                            .foregroundColor(Color(red: 0.36, green: 0.0, blue: 0.62))
                            .padding(.horizontal, 16)
                        
                        HealthAppsCard(
                            apps: $unauthorizedApps,
                            backgroundColor: Color(red: 0.99, green: 0.96, blue: 1.0)
                        )
                    }
                }
                .padding(.top, 16)
            }
        }
        .background(Color.white)
        .navigationBarHidden(true)
    }
}

// MARK: - 自定义导航栏
struct HealthAppsNavigationBar: View {
    @Environment(\.dismiss) private var dismiss
    let title: String
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color(red: 0.01, green: 0.01, blue: 0.01))
                }
                
                Spacer()
                
                Text(title)
                    .font(.system(size: 18, weight: .regular))
                    .foregroundColor(Color(red: 0.01, green: 0.01, blue: 0.01))
                
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
        .background(Color.white)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 2)
    }
}

// MARK: - 健康应用卡片
struct HealthAppsCard: View {
    @Binding var apps: [HealthApp]
    let backgroundColor: Color
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(apps.enumerated()), id: \.offset) { index, app in
                VStack(spacing: 0) {
                    HealthAppRow(app: $apps[index])
                    
                    // 添加分割线，最后一个不添加
                    if index < apps.count - 1 {
                        Rectangle()
                            .fill(Color(red: 0.31, green: 0.33, blue: 0.61))
                            .frame(height: 1)
                            .padding(.horizontal, 28)
                    }
                }
            }
        }
        .padding(.vertical, 16)
        .background(backgroundColor)
        .cornerRadius(8)
        .shadow(color: .black.opacity(0.25), radius: 2, x: -2, y: 2)
        .padding(.horizontal, 16)
    }
}

// MARK: - 健康应用行
struct HealthAppRow: View {
    @Binding var app: HealthApp
    
    var body: some View {
        HStack(spacing: 16) {
            // 应用图标
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(app.color.opacity(0.1))
                    .frame(width: 40, height: 40)
                
                Image(systemName: app.iconName)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(app.color)
            }
            
            // 应用名称
            Text(app.name)
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(app.color)
                .lineLimit(1)
            
            Spacer()
            
            // 开关按钮
            Toggle("", isOn: $app.isEnabled)
                .toggleStyle(SwitchToggleStyle(tint: app.color))
                .scaleEffect(0.8)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
    }
}

// MARK: - 健康应用模型
struct HealthApp: Identifiable {
    let id = UUID()
    let name: String
    let iconName: String
    var isEnabled: Bool
    let color: Color
}

#Preview {
    HealthAppsView()
}

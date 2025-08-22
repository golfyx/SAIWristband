//
//  TabBarView.swift
//  SAIWristband
//
//  Created by golfy xiong on 2025/8/22.
//

import SwiftUI

struct TabBarView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // 主要内容区域
            TabView(selection: $selectedTab) {
                HomeView()
                    .tag(0)
                
                HealthView()
                    .tag(1)
                
                SharingView()
                    .tag(2)
            }
            
            // 自定义底部标签栏
            CustomTabBar(selectedTab: $selectedTab)
        }
        .ignoresSafeArea(.keyboard)
    }
}

// MARK: - 自定义标签栏
struct CustomTabBar: View {
    @Binding var selectedTab: Int
    
    var body: some View {
        HStack {
            // Home 标签
            TabBarButton(
                title: "Home",
                icon: "house.fill",
                isSelected: selectedTab == 0
            ) {
                selectedTab = 0
            }
            
            Spacer()
            
            // Health 标签
            TabBarButton(
                title: "Health",
                icon: "heart.fill",
                isSelected: selectedTab == 1
            ) {
                selectedTab = 1
            }
            
            Spacer()
            
            // Sharing 标签
            TabBarButton(
                title: "Sharing",
                icon: "square.and.arrow.up.fill",
                isSelected: selectedTab == 2
            ) {
                selectedTab = 2
            }
        }
        .padding(.horizontal, 32)
        .padding(.vertical, 12)
        .background(Color.white)
        .overlay(
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(height: 0.5),
            alignment: .top
        )
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: -2)
    }
}

// MARK: - 标签栏按钮
struct TabBarButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(isSelected ? Color(red: 0.6, green: 0.1, blue: 0.95) : Color.black)
                
                Text(title)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(isSelected ? Color(red: 0.6, green: 0.1, blue: 0.95) : Color.black)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - 占位符视图
struct HealthView: View {
    var body: some View {
        VStack {
            Text("Health")
                .font(.largeTitle)
                .padding()
            Text("健康页面正在开发中...")
                .font(.body)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
    }
}

struct SharingView: View {
    var body: some View {
        VStack {
            Text("Sharing")
                .font(.largeTitle)
                .padding()
            Text("分享页面正在开发中...")
                .font(.body)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
    }
}

#Preview {
    TabBarView()
}

//
//  MeditationView.swift
//  SAIWristband
//
//  Created by golfy xiong on 2025/8/24.
//

import SwiftUI

struct MeditationView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // 自定义导航栏
            MeditationNavigationBar()
            
            // 分割线
            Divider()
                .background(Color.gray.opacity(0.3))
            
            ScrollView {
                VStack(spacing: 24) {
                    // 搜索栏
                    SearchBar(searchText: $searchText)
                    
                    // Preference 部分
                    PreferenceSection()
                    
                    // Popular 部分
                    PopularSection()
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 60)
            }
        }
        .background(Color.white)
        .navigationBarHidden(true)
    }
}

// MARK: - 自定义导航栏
struct MeditationNavigationBar: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        HStack {
            // 返回按钮
            Button(action: {
                dismiss()
            }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color(red: 0.427, green: 0.282, blue: 0.510)) // #6D4882
                    .frame(width: 44, height: 44)
            }
            
            Spacer()
            
            // 标题
            Text("Meditation")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.primary)
            
            Spacer()
            
            // 占位符，保持标题居中
            Color.clear
                .frame(width: 44, height: 44)
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 12)
        .background(Color.white)
    }
}

// MARK: - 搜索栏
struct SearchBar: View {
    @Binding var searchText: String
    
    var body: some View {
        HStack(spacing: 12) {
            // 搜索输入框
            HStack {
                TextField("Search courses", text: $searchText)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(Color(red: 0.580, green: 0.639, blue: 0.722)) // #94A3B8
                
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(red: 0.902, green: 0.902, blue: 0.902)) // #E6E6E6
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color(red: 0.898, green: 0.902, blue: 0.922), lineWidth: 1) // #E5E7EB
            )
            .shadow(color: Color.black.opacity(0.16), radius: 4, x: 0, y: 2)
            
            // 搜索按钮
            Button(action: {
                // 执行搜索
            }) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                    .frame(width: 37, height: 37)
                    .background(Color(red: 0.482, green: 0.286, blue: 0.592)) // #7B4897
                    .clipShape(Circle())
            }
        }
    }
}

// MARK: - Preference 部分
struct PreferenceSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 标题
            Text("Preference:")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(Color(red: 0.427, green: 0.282, blue: 0.510)) // #6D4882
            
            // 按钮组
            VStack(spacing: 8) {
                // 第一行按钮
                HStack(spacing: 12) {
                    PreferenceButton(title: "Morning Vitality")
                    PreferenceButton(title: "Commute Calm")
                    PreferenceButton(title: "Desk Recharge")
                }
                
                // 第二行按钮
                HStack(spacing: 12) {
                    PreferenceButton(title: "Post-Yoga")
                    PreferenceButton(title: "Deep Sleep")
                }
            }
            
            // 两个视图
            HStack(spacing: 16) {
                PreferenceCard(
                    imageName: "sunset_meditation",
                    title: "Sunset Serenity",
                    backgroundColor: Color(red: 0.956, green: 0.882, blue: 0.859) // #F4E1DB
                )
                
                PreferenceCard(
                    imageName: "forest_meditation",
                    title: "Forest Pathway",
                    backgroundColor: Color(red: 0.956, green: 0.882, blue: 0.859) // #F4E1DB
                )
            }
        }
    }
}

// MARK: - Preference 按钮
struct PreferenceButton: View {
    let title: String
    
    var body: some View {
        Button(action: {
            // 按钮点击事件
        }) {
            Text(title)
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(Color(red: 0.376, green: 0.369, blue: 0.369)) // #605E5E
                .padding(.horizontal, 11)
                .padding(.vertical, 2.5)
                .background(Color(red: 0.925, green: 0.925, blue: 0.925)) // #ECECEC
                .cornerRadius(4)
                .shadow(color: Color.black.opacity(0.25), radius: 2, x: -2, y: 2)
        }
    }
}

// MARK: - Preference 卡片
struct PreferenceCard: View {
    let imageName: String
    let title: String
    let backgroundColor: Color
    
    var body: some View {
        VStack(spacing: 12) {
            // 图片占位符
            Rectangle()
                .fill(backgroundColor)
                .frame(height: 100)
                .overlay(
                    Image(systemName: "photo")
                        .font(.system(size: 24))
                        .foregroundColor(.gray)
                )
                .cornerRadius(8)
            
            // 标题
            Text(title)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(Color(red: 0.427, green: 0.282, blue: 0.510)) // #6D4882
                .multilineTextAlignment(.center)
            
            // 三个按钮
            HStack(spacing: 16) {
                ActionButton(icon: "heart", color: .red)
                ActionButton(icon: "bookmark", color: .blue)
                ActionButton(icon: "square.and.arrow.up", color: .green)
            }
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

// MARK: - 操作按钮
struct ActionButton: View {
    let icon: String
    let color: Color
    
    var body: some View {
        Button(action: {
            // 按钮点击事件
        }) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(color)
                .frame(width: 28, height: 28)
                .background(color.opacity(0.1))
                .clipShape(Circle())
        }
    }
}

// MARK: - Popular 部分
struct PopularSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 标题
            Text("popularization of science")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(Color(red: 0.290, green: 0.165, blue: 0.361)) // #4A2A5C
            
            // 图片和文字内容
            VStack(spacing: 12) {
                // 图片占位符
                Rectangle()
                    .fill(Color(red: 0.925, green: 0.882, blue: 0.859)) // #ECECEC
                    .frame(height: 155)
                    .overlay(
                        Image(systemName: "photo")
                            .font(.system(size: 32))
                            .foregroundColor(.gray)
                    )
                    .cornerRadius(8)
                
                // 文字内容
                VStack(alignment: .leading, spacing: 6) {
                    Text("Lorem ipsum dolor sit amet, consectetur")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(Color(red: 0.455, green: 0.408, blue: 0.478)) // #74687A
                        .lineLimit(nil)
                    
                    Text("adipiscing elit. Curabitur nec arcu molestie,")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(Color(red: 0.455, green: 0.408, blue: 0.478)) // #74687A
                        .lineLimit(nil)
                    
                    Text("mollis purus sit amet, sodales libero. Nulla id")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(Color(red: 0.455, green: 0.408, blue: 0.478)) // #74687A
                        .lineLimit(nil)
                    
                    Text("odio maximus, congue.")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(Color(red: 0.455, green: 0.408, blue: 0.478)) // #74687A
                        .lineLimit(nil)
                }
                .padding(.horizontal, 4)
            }
        }
    }
}

#Preview {
    MeditationView()
}

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
    @Environment(\.colorScheme) private var colorScheme
    
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
                .padding(.vertical, 20)
            }
        }
        .background(
            // 根据暗黑模式选择背景
            Group {
                if colorScheme == .dark {
                    // 暗黑模式：深色渐变背景
                    LinearGradient(
                        colors: [
                            Color(red: 0.1, green: 0.05, blue: 0.15),
                            Color(red: 0.15, green: 0.08, blue: 0.25)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                } else {
                    // 亮色模式：使用原图背景
                    Image("Image11")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                }
            }
            .ignoresSafeArea()
        )
        .navigationBarHidden(true)
    }
}

// MARK: - 自定义导航栏
struct MeditationNavigationBar: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        HStack {
            // 返回按钮
            Button(action: {
                dismiss()
            }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(MeditationTheme.primaryText(colorScheme))
                    .frame(width: 44, height: 44)
            }
            
            Spacer()
            
            // 标题
            Text("Meditation")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(MeditationTheme.primaryText(colorScheme))
            
            Spacer()
            
            // 占位符，保持标题居中
            Color.clear
                .frame(width: 44, height: 44)
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 12)
        .background(MeditationTheme.navigationBackground(colorScheme))
        .glassBackground(RoundedRectangle(cornerRadius: 0))
    }
}

// MARK: - 搜索栏
struct SearchBar: View {
    @Binding var searchText: String
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        HStack(spacing: 12) {
            // 搜索输入框
            HStack {
                TextField("Search courses", text: $searchText)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(MeditationTheme.searchText(colorScheme))
                
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(MeditationTheme.secondaryText(colorScheme))
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(MeditationTheme.searchBackground(colorScheme))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(MeditationTheme.searchBorder(colorScheme), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(MeditationTheme.shadowOpacity(colorScheme)), radius: 4, x: 0, y: 2)
            
            // 搜索按钮
            Button(action: {
                // 执行搜索
            }) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 28, weight: .medium))
                    .foregroundColor(MeditationTheme.accent(colorScheme))
            }
        }
    }
}

// MARK: - Preference 部分
struct PreferenceSection: View {
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 标题
            Text("Preference:")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(MeditationTheme.primary(colorScheme))
            
            // 按钮组
            VStack(spacing: 8) {
                // 第一行按钮
                HStack {
                    Spacer()
                    PreferenceButton(title: "Morning Vitality")
                    Spacer()
                    PreferenceButton(title: "Commute Calm")
                    Spacer()
                    PreferenceButton(title: "Desk Recharge")
                    Spacer()
                }
                
                // 第二行按钮
                HStack {
                    Spacer()
                    PreferenceButton(title: "Deep Sleep")
                    Spacer()
                    PreferenceButton(title: "Post-Yoga")
                    Spacer()
                }
            }
            
            // 两个视图
            HStack(spacing: 16) {
                PreferenceCard(
                    imageName: "Image12",
                    title: "Sunset Serenity",
                    backgroundColor: MeditationTheme.cardBackground(colorScheme)
                )
                
                PreferenceCard(
                    imageName: "Image13",
                    title: "Forest Pathway",
                    backgroundColor: MeditationTheme.cardBackground(colorScheme)
                )
            }
        }
    }
}

// MARK: - Preference 按钮
struct PreferenceButton: View {
    let title: String
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        Button(action: {
            // 按钮点击事件
        }) {
            Text(title)
                .font(.system(size: 10, weight: .regular))
                .foregroundColor(MeditationTheme.buttonText(colorScheme))
                .padding(.horizontal, 8)
                .padding(.vertical, 2.5)
                .background(MeditationTheme.buttonBackground(colorScheme))
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
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(spacing: 12) {
            Image(imageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .clipped()
                .cornerRadius(8)
            
            // 标题
            Text(title)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(MeditationTheme.primaryText(colorScheme))
                .multilineTextAlignment(.center)
            
            // 三个按钮
            HStack(spacing: 16) {
                ActionButton(icon: "heart", color: .red)
                ActionButton(icon: "bookmark", color: .blue)
                ActionButton(icon: "square.and.arrow.up", color: .green)
            }
        }
        .padding(12)
        .background(backgroundColor.opacity(0.6))
        .cornerRadius(12)
        .glassBackground(RoundedRectangle(cornerRadius: 12), opacity: 0.8)
        .shadow(color: Color.black.opacity(MeditationTheme.shadowOpacity(colorScheme)), radius: 4, x: 0, y: 2)
    }
}

// MARK: - 操作按钮
struct ActionButton: View {
    let icon: String
    let color: Color
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        Button(action: {
            // 按钮点击事件
        }) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(color)
                .frame(width: 28, height: 28)
                .background(
                    Circle()
                        .fill(color.opacity(colorScheme == .dark ? 0.2 : 0.1))
                )
                .glassBackground(Circle(), opacity: 0.6)
        }
    }
}

// MARK: - Popular 部分
struct PopularSection: View {
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 标题
            Text("popularization of science")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(MeditationTheme.primary(colorScheme))
            
            // 图片和文字内容
            VStack(spacing: 12) {
                // 图片
                Image("Image14")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 155)
                    .clipped()
                    .cornerRadius(8)
                
                // 文字内容
                VStack(alignment: .leading, spacing: 6) {
                    Text("Lorem ipsum dolor sit amet, consectetur")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(MeditationTheme.secondaryText(colorScheme))
                        .lineLimit(nil)
                    
                    Text("adipiscing elit. Curabitur nec arcu molestie,")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(MeditationTheme.secondaryText(colorScheme))
                        .lineLimit(nil)
                    
                    Text("mollis purus sit amet, sodales libero. Nulla id")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(MeditationTheme.secondaryText(colorScheme))
                        .lineLimit(nil)
                    
                    Text("odio maximus, congue.")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(MeditationTheme.secondaryText(colorScheme))
                        .lineLimit(nil)
                }
                .padding(.horizontal, 4)
            }
        }
        .padding(16)
    }
}

// MARK: - Meditation 主题颜色
enum MeditationTheme {
    static func primary(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color(red: 0.8, green: 0.6, blue: 0.9) : Color(red: 0.427, green: 0.282, blue: 0.510) // #6D4882
    }
    
    static func accent(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color(red: 0.9, green: 0.7, blue: 1.0) : Color(red: 0.482, green: 0.286, blue: 0.592) // #7B4897
    }
    
    static func primaryText(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color.white : Color(red: 0.290, green: 0.165, blue: 0.361) // #4A2A5C
    }
    
    static func secondaryText(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color.white.opacity(0.8) : Color(red: 0.455, green: 0.408, blue: 0.478) // #74687A
    }
    
    static func searchText(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color.white.opacity(0.7) : Color(red: 0.580, green: 0.639, blue: 0.722) // #94A3B8
    }
    
    static func searchBackground(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color.white.opacity(0.1) : Color(red: 0.902, green: 0.902, blue: 0.902) // #E6E6E6
    }
    
    static func searchBorder(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color.white.opacity(0.2) : Color(red: 0.898, green: 0.906, blue: 0.922) // #E5E7EB
    }
    
    static func buttonBackground(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color.white.opacity(0.15) : Color(red: 0.925, green: 0.925, blue: 0.925) // #ECECEC
    }
    
    static func buttonText(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color.white : Color(red: 0.376, green: 0.369, blue: 0.369) // #605E5E
    }
    
    static func cardBackground(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color(red: 0.2, green: 0.15, blue: 0.25).opacity(0.8) : Color(red: 0.956, green: 0.882, blue: 0.859) // #F4E1DB
    }
    
    static func sectionBackground(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color.white.opacity(0.08) : Color.white.opacity(0.9)
    }
    
    static func navigationBackground(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color.black.opacity(0.3) : Color.white.opacity(0.9)
    }
    
    static func shadowOpacity(_ colorScheme: ColorScheme) -> CGFloat {
        colorScheme == .dark ? 0.4 : 0.16
    }
}

#Preview {
    MeditationView()
}

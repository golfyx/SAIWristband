//
//  ProfileView.swift
//  SAIWristband
//
//  Created by golfy xiong on 2025/8/22.
//

import SwiftUI

struct ProfileView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var userProfile = UserProfile.sampleData
    @State private var healthReport = HealthReport.sampleData
    @State private var healthMedals = HealthMedals.sampleData
    @State private var achievements = Achievement.sampleData
    @State private var records = RecordItem.sampleData
    @State private var reminder = Reminder.sampleData
    @State private var isReminderEnabled = true
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let isPhone375 = screenWidth <= 375
            
            ScrollView {
                VStack(spacing: 0) {
                    // 自定义导航栏
                    ProfileNavigationBar {
                        presentationMode.wrappedValue.dismiss()
                    }
                    
                    // 分割线
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 1)
                    
                    VStack(spacing: isPhone375 ? 20 : 24) {
                        // 个人信息区域
                        UserInfoSection(userProfile: userProfile)
                        
                        // 健康报告区域
                        HealthReportSection(healthReport: healthReport)
                        
                        // 我的健康奖牌区域
                        HealthMedalsSection(healthMedals: healthMedals)
                        
                        // Achievement区域
                        AchievementSection(achievements: achievements)
                        
                        // 记录值区域
                        RecordsSection(records: records)
                        
                        // Reminder区域
                        ReminderSection(reminder: reminder, isEnabled: $isReminderEnabled)
                    }
                    .padding(.horizontal, isPhone375 ? 16 : 20)
                    .padding(.vertical, isPhone375 ? 16 : 20)
                    .padding(.bottom, 60) // 为TabBar留出空间
                }
            }
            .background(Color.white)
            .navigationBarHidden(true)
        }
    }
}

// MARK: - 个人页面导航栏
struct ProfileNavigationBar: View {
    let onBackTapped: () -> Void
    
    var body: some View {
        HStack {
            // 返回按钮
            Button(action: onBackTapped) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.black)
            }
            
            Spacer()
            
            // 标题
            Text("Profile")
                .font(.system(size: 18, weight: .regular))
                .foregroundColor(.black)
            
            Spacer()
            
            // 右侧图片按钮
            Button(action: {
                // 添加按钮点击动作
            }) {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.black)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.white)
    }
}

// MARK: - 个人信息区域
struct UserInfoSection: View {
    let userProfile: UserProfile
    
    var body: some View {
        VStack(spacing: 16) {
            // 上部分：头像和姓名
            HStack(alignment: .center, spacing: 16) {
                // 头像
                AsyncImage(url: Bundle.main.url(forResource: userProfile.avatarImage ?? "user_avatar", withExtension: "png")) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Circle()
                        .fill(Color(red: 0.84, green: 0.8, blue: 0.98))
                        .overlay(
                            Image(systemName: "person.fill")
                                .foregroundColor(Color(red: 0.34, green: 0.16, blue: 0.37))
                        )
                }
                .frame(width: 55, height: 55)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(Color(red: 0.9, green: 0.91, blue: 0.92), lineWidth: 1)
                )
                
                // 姓名
                Text(userProfile.name)
                    .font(.system(size: 24, weight: .regular))
                    .foregroundColor(.black)
                
                Spacer()
            }
            
            // 下部分：年龄、身高、体重信息卡片
            HStack(spacing: 16) {
                // 左侧信息
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(userProfile.age)y，\(userProfile.height)cm，\(String(format: "%.1f", userProfile.weight))kg")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.black)
                }
                
                Spacer()
                
                // 右侧箭头
                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundColor(Color(red: 0.6, green: 0.31, blue: 0.58))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 13)
                    .fill(Color(red: 0.8, green: 0.76, blue: 0.82).opacity(0.3))
            )
        }
        .padding(16)
        .background(Color(red: 0.97, green: 0.96, blue: 1.0))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(red: 0.76, green: 0.76, blue: 0.76), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
    }
}

// MARK: - 健康报告区域
struct HealthReportSection: View {
    let healthReport: HealthReport
    
    var body: some View {
        VStack(spacing: 16) {
            // 标题
            HStack {
                Text(healthReport.title)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.black)
                
                Spacer()
            }
            
            // 内容区域
            HStack(spacing: 16) {
                // 左侧图片
                AsyncImage(url: Bundle.main.url(forResource: healthReport.image, withExtension: "png")) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } placeholder: {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.2))
                }
                .frame(width: 109, height: 101)
                
                // 右侧文字内容
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(healthReport.description, id: \.self) { line in
                        Text(line)
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(Color(red: 0.52, green: 0.52, blue: 0.52))
                            .multilineTextAlignment(.leading)
                    }
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            // 按钮区域
            HStack(spacing: 12) {
                // Share按钮
                Button(action: {}) {
                    Text("Share")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(Color(red: 0.53, green: 0.13, blue: 0.75))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color(red: 0.93, green: 0.91, blue: 0.97))
                        .cornerRadius(9)
                        .overlay(
                            RoundedRectangle(cornerRadius: 9)
                                .stroke(Color(red: 0.53, green: 0.13, blue: 0.75), lineWidth: 1)
                        )
                }
                
                // Upload按钮
                Button(action: {}) {
                    Text("Upload")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color(red: 0.60, green: 0.10, blue: 0.95))
                        .cornerRadius(9)
                        .overlay(
                            RoundedRectangle(cornerRadius: 9)
                                .stroke(Color(red: 0.53, green: 0.13, blue: 0.75), lineWidth: 1)
                        )
                }
                
                Spacer()
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(red: 0.88, green: 0.88, blue: 0.88), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.25), radius: 2, x: -2, y: 2)
    }
}

// MARK: - 健康奖牌区域
struct HealthMedalsSection: View {
    let healthMedals: HealthMedals
    
    var body: some View {
        VStack(spacing: 16) {
            // 标题
            HStack {
                Text(healthMedals.title)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.black)
                
                Spacer()
            }
            
            // 内容
            VStack(alignment: .leading, spacing: 8) {
                Text(healthMedals.description.components(separatedBy: "\n").first ?? "")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(Color(red: 0.3, green: 0.2, blue: 0.41))
                
                Text(healthMedals.description.components(separatedBy: "\n").dropFirst().joined(separator: "\n"))
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(Color(red: 0.3, green: 0.2, blue: 0.41))
                    .lineSpacing(2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Edit Target按钮
            HStack {
                Button(action: {}) {
                    Text("Edit Target")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color(red: 0.60, green: 0.10, blue: 0.95))
                        .cornerRadius(9)
                        .overlay(
                            RoundedRectangle(cornerRadius: 9)
                                .stroke(Color(red: 0.53, green: 0.13, blue: 0.75), lineWidth: 1)
                        )
                }
                
                Spacer()
            }
        }
        .padding(16)
        .background(Color(red: 0.99, green: 0.96, blue: 1.0))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(red: 0.88, green: 0.88, blue: 0.88), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.25), radius: 2, x: -2, y: 2)
    }
}

// MARK: - 成就区域
struct AchievementSection: View {
    let achievements: [Achievement]
    
    var body: some View {
        VStack(spacing: 16) {
            // 标题行
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Achievement")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.black)
                    
                    Text("Unlocked!")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.black)
                }
                
                Spacer()
                
                // View all按钮
                Button(action: {}) {
                    Text("View all")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(Color(red: 0.53, green: 0.13, blue: 0.75))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color(red: 0.93, green: 0.91, blue: 0.97))
                        .cornerRadius(9)
                        .overlay(
                            RoundedRectangle(cornerRadius: 9)
                                .stroke(Color(red: 0.53, green: 0.13, blue: 0.75), lineWidth: 1)
                        )
                }
            }
            
            // 成就卡片滚动视图
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(achievements, id: \.id) { achievement in
                        AchievementCard(achievement: achievement)
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }
}

// MARK: - 单个成就卡片
struct AchievementCard: View {
    let achievement: Achievement
    
    var body: some View {
        VStack(spacing: 12) {
            // 奖牌图标区域
            ZStack {
                Circle()
                    .fill(Color(red: 0.60, green: 0.10, blue: 0.95))
                    .frame(width: 83, height: 83)
                    .overlay(
                        Circle()
                            .stroke(Color(red: 0.9, green: 0.91, blue: 0.92), lineWidth: 1)
                    )
                
                // 内部图标
                Circle()
                    .fill(Color.white)
                    .frame(width: 47, height: 47)
                    .overlay(
                        Image(systemName: "trophy.fill")
                            .font(.system(size: 24))
                            .foregroundColor(Color(red: 0.60, green: 0.10, blue: 0.95))
                    )
            }
            
            // 奖牌名称
            Text(achievement.medalName)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.black)
            
            // 成就描述
            Text(achievement.value)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
        }
        .frame(width: 126, height: 148)
        .background(Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(red: 0.88, green: 0.88, blue: 0.88), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.25), radius: 2, x: -2, y: 2)
    }
}

// MARK: - 记录值区域
struct RecordsSection: View {
    let records: [RecordItem]
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(records.enumerated()), id: \.offset) { index, record in
                VStack(spacing: 0) {
                    HStack {
                        Text(record.title)
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(Color(red: 0.24, green: 0.24, blue: 0.24))
                            .multilineTextAlignment(.leading)
                        
                        Spacer()
                        
                        Text(record.value)
                            .font(.system(size: 20, weight: .regular))
                            .foregroundColor(Color(red: 0.24, green: 0.24, blue: 0.24))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                    
                    // 分割线
                    if record.hasBottomLine {
                        Rectangle()
                            .fill(Color(red: 0.24, green: 0.24, blue: 0.24))
                            .frame(height: 1)
                            .padding(.horizontal, 16)
                    }
                }
            }
        }
        .background(Color(red: 0.99, green: 0.96, blue: 1.0))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(red: 0.88, green: 0.88, blue: 0.88), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.25), radius: 2, x: -2, y: 2)
    }
}

// MARK: - 提醒区域
struct ReminderSection: View {
    let reminder: Reminder
    @Binding var isEnabled: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            // 标题行
            HStack {
                Text(reminder.title)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.black)
                
                Spacer()
                
                // 图标
                Image(systemName: "bell.fill")
                    .font(.system(size: 20))
                    .foregroundColor(Color(red: 0.24, green: 0.24, blue: 0.24))
            }
            
            // 内容和时间
            VStack(alignment: .leading, spacing: 8) {
                Text(reminder.content)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(Color(red: 0.52, green: 0.52, blue: 0.52))
                
                Text(reminder.time)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(Color(red: 0.52, green: 0.52, blue: 0.52))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // 开关
            HStack {
                Spacer()
                
                Toggle("", isOn: $isEnabled)
                    .labelsHidden()
                    .scaleEffect(0.8)
                    .accentColor(Color(red: 0.60, green: 0.31, blue: 0.58))
            }
        }
        .padding(16)
        .background(Color(red: 0.24, green: 0.24, blue: 0.24).opacity(0.02))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(red: 0.88, green: 0.88, blue: 0.88), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.25), radius: 2, x: -2, y: 2)
    }
}

#Preview {
    ProfileView()
}

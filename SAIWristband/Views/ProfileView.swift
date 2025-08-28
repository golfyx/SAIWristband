//
//  ProfileView.swift
//  SAIWristband
//
//  Created by golfy xiong on 2025/8/22.
//

import SwiftUI

struct ProfileView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var appState: AppState
    @State private var userProfile = UserProfile.sampleData
    @State private var healthReport = HealthReport.sampleData
    @State private var healthMedals = HealthMedals.sampleData
    @State private var achievements = Achievement.sampleData
    @State private var records = RecordItem.sampleData
    @State private var reminder = Reminder.sampleData
    @State private var isReminderEnabled = true
    @State private var showingLogoutAlert = false
    
    @Environment(\.colorScheme) private var colorScheme
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let isPhone375 = screenWidth <= 375
            
            ScrollView {
                VStack(spacing: 0) {
                    // 自定义导航栏
                    ProfileNavigationBar {
                        presentationMode.wrappedValue.dismiss()
                    } onLogout: {
                        showingLogoutAlert = true
                    }
                    
                    // 分割线
                    Rectangle()
                        .fill(AppTheme.dividerColor(colorScheme))
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
            .background(AppTheme.background(colorScheme))
            .navigationBarHidden(true)
            .alert("Confirm Logout", isPresented: $showingLogoutAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Log Out", role: .destructive) {
                    appState.logout()
                }
            } message: {
                Text("Are you sure you want to log out?")
            }
        }
    }
}

// MARK: - 个人页面导航栏
struct ProfileNavigationBar: View {
    let onBackTapped: () -> Void
    let onLogout: () -> Void
    @Environment(\.colorScheme) private var colorScheme
    @State private var isDarkMode = false
    
    var body: some View {
        HStack {
            // 返回按钮
            Button(action: onBackTapped) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(AppTheme.primaryText(colorScheme))
            }
            
            Spacer()
            
            // 标题
            Text("Profile")
                .font(.system(size: 18, weight: .regular))
                .foregroundColor(AppTheme.primaryText(colorScheme))
            
            Spacer()
            
            // 右侧退出按钮
            Button(action: onLogout) {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                    .font(.system(size: 20))
                    .foregroundColor(AppTheme.primaryText(colorScheme))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(AppTheme.cardBackground(colorScheme))
        .glassBackground(RoundedRectangle(cornerRadius: 0))
    }
}

// MARK: - 个人信息区域
struct UserInfoSection: View {
    let userProfile: UserProfile
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(spacing: 16) {
            // 上部分：头像和姓名
            HStack(alignment: .center, spacing: 16) {
                // 头像
                Image("user_avatar")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .clipShape(Circle())
                    .frame(width: 52, height: 51)
                    .overlay(
                        Circle()
                            .stroke(AppTheme.separatorColor(colorScheme), lineWidth: 1)
                    )
                
                // 姓名
                Text(userProfile.name)
                    .font(.system(size: 24, weight: .regular))
                    .foregroundColor(AppTheme.primaryText(colorScheme))
                
                Spacer()
            }
            
            // 下部分：年龄、身高、体重信息卡片
            HStack(spacing: 16) {
                // 左侧信息
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(userProfile.age)y，\(userProfile.height)cm，\(String(format: "%.1f", userProfile.weight))kg")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(AppTheme.primaryText(colorScheme))
                }
                
                Spacer()
                
                // 右侧箭头
                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundColor(AppTheme.accent)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 13)
                    .fill(AppTheme.accent.opacity(0.15))
            )
        }
        .padding(16)
        .background(AppTheme.elevatedCardBackground(colorScheme))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(AppTheme.separatorColor(colorScheme), lineWidth: 1)
        )
        .shadow(
            color: AppTheme.shadowColor(colorScheme),
            radius: 4,
            x: 0,
            y: 2
        )
    }
}

// MARK: - 健康报告区域
struct HealthReportSection: View {
    let healthReport: HealthReport
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(spacing: 16) {
            // 标题
            HStack {
                Text(healthReport.title)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(AppTheme.primaryText(colorScheme))
                
                Spacer()
            }
            
            // 内容区域
            HStack(spacing: 16) {
                // 左侧图片
                Image("Image10")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .cornerRadius(12)
                    .frame(width: 109, height: 101)
                
                // 右侧文字内容
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(healthReport.description, id: \.self) { line in
                        Text(line)
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(AppTheme.secondaryText(colorScheme))
                            .multilineTextAlignment(.leading)
                    }
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            // 按钮区域
            HStack(spacing: 12) {
                Spacer()
                // Share按钮
                Button(action: {}) {
                    Text("Share")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(AppTheme.accent)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(AppTheme.accent.opacity(0.15))
                        .cornerRadius(9)
                        .overlay(
                            RoundedRectangle(cornerRadius: 9)
                                .stroke(AppTheme.accent, lineWidth: 1)
                        )
                }
                
                Spacer()
                
                // Upload按钮
                Button(action: {}) {
                    Text("Upload")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(AppTheme.accent)
                        .cornerRadius(9)
                        .overlay(
                            RoundedRectangle(cornerRadius: 9)
                                .stroke(AppTheme.accent, lineWidth: 1)
                        )
                }
                
                Spacer()
            }
        }
        .padding(16)
        .background(AppTheme.cardBackground(colorScheme))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(AppTheme.separatorColor(colorScheme), lineWidth: 1)
        )
        .shadow(
            color: AppTheme.shadowColor(colorScheme),
            radius: 2,
            x: -2,
            y: 2
        )
    }
}

// MARK: - 健康奖牌区域
struct HealthMedalsSection: View {
    let healthMedals: HealthMedals
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(spacing: 16) {
            // 标题
            HStack {
                Text(healthMedals.title)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(AppTheme.primaryText(colorScheme))
                
                Spacer()
            }
            
            // 内容
            VStack(alignment: .leading, spacing: 8) {
                Text(healthMedals.description.components(separatedBy: "\n").first ?? "")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(AppTheme.secondaryText(colorScheme))
                
                Text(healthMedals.description.components(separatedBy: "\n").dropFirst().joined(separator: "\n"))
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(AppTheme.primaryText(colorScheme))
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
                        .background(AppTheme.accent)
                        .cornerRadius(9)
                        .overlay(
                            RoundedRectangle(cornerRadius: 9)
                                .stroke(AppTheme.accent, lineWidth: 1)
                        )
                }
                
                Spacer()
            }
        }
        .padding(16)
        .background(AppTheme.elevatedCardBackground(colorScheme))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(AppTheme.separatorColor(colorScheme), lineWidth: 1)
        )
        .shadow(
            color: AppTheme.shadowColor(colorScheme),
            radius: 2,
            x: -2,
            y: 2
        )
    }
}

// MARK: - 成就区域
struct AchievementSection: View {
    let achievements: [Achievement]
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(spacing: 16) {
            // 标题行
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Achievement")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(AppTheme.primaryText(colorScheme))
                    
                    Text("Unlocked!")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(AppTheme.primaryText(colorScheme))
                }
                
                Spacer()
                
                // View all按钮
                Button(action: {}) {
                    Text("View all")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(AppTheme.accent)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(AppTheme.accent.opacity(0.15))
                        .cornerRadius(9)
                        .overlay(
                            RoundedRectangle(cornerRadius: 9)
                                .stroke(AppTheme.accent, lineWidth: 1)
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
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(spacing: 12) {
            // 奖牌图标区域
            ZStack {
                Circle()
                    .fill(Color(red: 0.60, green: 0.10, blue: 0.95))
                    .frame(width: 83, height: 83)
                    .overlay(
                        Circle()
                            .stroke(AppTheme.separatorColor(colorScheme), lineWidth: 1)
                    )
                
                // 内部图标
                Circle()
                    .fill(AppTheme.cardBackground(colorScheme))
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
                .foregroundColor(AppTheme.primaryText(colorScheme))
            
            // 成就描述
            Text(achievement.value)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(AppTheme.secondaryText(colorScheme))
                .multilineTextAlignment(.center)
        }
        .frame(width: 126, height: 148)
        .background(AppTheme.cardBackground(colorScheme))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(AppTheme.separatorColor(colorScheme), lineWidth: 1)
        )
        .shadow(
            color: AppTheme.shadowColor(colorScheme),
            radius: 2,
            x: -2,
            y: 2
        )
    }
}

// MARK: - 记录值区域
struct RecordsSection: View {
    let records: [RecordItem]
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(records.enumerated()), id: \.offset) { index, record in
                VStack(spacing: 0) {
                    HStack {
                        Text(record.title)
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(AppTheme.primaryText(colorScheme))
                            .multilineTextAlignment(.leading)
                        
                        Spacer()
                        
                        Text(record.value)
                            .font(.system(size: 20, weight: .regular))
                            .foregroundColor(AppTheme.primaryText(colorScheme))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                    
                    // 分割线
                    if record.hasBottomLine {
                        Rectangle()
                            .fill(AppTheme.separatorColor(colorScheme))
                            .frame(height: 1)
                            .padding(.horizontal, 16)
                    }
                }
            }
        }
        .background(AppTheme.elevatedCardBackground(colorScheme))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(AppTheme.separatorColor(colorScheme), lineWidth: 1)
        )
        .shadow(
            color: AppTheme.shadowColor(colorScheme),
            radius: 2,
            x: -2,
            y: 2
        )
    }
}

// MARK: - 提醒区域
struct ReminderSection: View {
    let reminder: Reminder
    @Binding var isEnabled: Bool
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(spacing: 16) {
            // 标题行
            HStack {
                Text(reminder.title)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(AppTheme.primaryText(colorScheme))
                
                Spacer()
                
                // 图标
                Image(systemName: "bell.fill")
                    .font(.system(size: 20))
                    .foregroundColor(AppTheme.secondaryText(colorScheme))
            }
            
            // 内容和时间
            VStack(alignment: .leading, spacing: 8) {
                Text(reminder.content)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(AppTheme.secondaryText(colorScheme))
                
                Text(reminder.time)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(AppTheme.secondaryText(colorScheme))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // 开关
            HStack {
                Spacer()
                
                Toggle("", isOn: $isEnabled)
                    .labelsHidden()
                    .scaleEffect(0.8)
                    .accentColor(AppTheme.accent)
            }
        }
        .padding(16)
        .background(AppTheme.cardBackground(colorScheme))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(AppTheme.separator, lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.25), radius: 2, x: -2, y: 2)
    }
}

#Preview {
    ProfileView()
}

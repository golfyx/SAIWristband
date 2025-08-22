//
//  ShareView.swift
//  SAIWristband
//
//  Created by golfy xiong on 2025/8/22.
//

import SwiftUI

struct ShareView: View {
    @State private var selectedShareType: ShareType = .healthReport
    @State private var showingShareSheet = false
    @State private var shareText = ""
    
    enum ShareType: String, CaseIterable {
        case healthReport = "健康报告"
        case achievement = "运动成就"
        case dailyData = "今日数据"
        
        var icon: String {
            switch self {
            case .healthReport: return "doc.text.fill"
            case .achievement: return "trophy.fill"
            case .dailyData: return "chart.bar.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .healthReport: return .blue
            case .achievement: return .yellow
            case .dailyData: return .green
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // 分享类型选择
                    shareTypeSelection
                    
                    // 分享预览
                    sharePreviewSection
                    
                    // 分享选项
                    shareOptionsSection
                    
                    // 历史分享
                    shareHistorySection
                    
                    Spacer(minLength: 20)
                }
                .padding(.horizontal, 16)
            }
            .navigationTitle("分享")
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(isPresented: $showingShareSheet) {
            ShareSheet(activityItems: [shareText])
        }
    }
    
    // 分享类型选择
    private var shareTypeSelection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("选择分享内容")
                .font(.headline)
                .fontWeight(.semibold)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(ShareType.allCases, id: \.self) { type in
                    ShareTypeCard(
                        type: type,
                        isSelected: selectedShareType == type,
                        onTap: {
                            selectedShareType = type
                        }
                    )
                }
            }
        }
    }
    
    // 分享预览
    private var sharePreviewSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("分享预览")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 16) {
                // 预览卡片
                VStack(spacing: 12) {
                    HStack {
                        Image(systemName: selectedShareType.icon)
                            .font(.title2)
                            .foregroundColor(selectedShareType.color)
                        
                        Text(selectedShareType.rawValue)
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Spacer()
                        
                        Text("SAI Wristband")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    Divider()
                    
                    // 根据分享类型显示不同内容
                    shareContentView
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                )
                
                // 分享按钮
                Button(action: {
                    generateShareText()
                    showingShareSheet = true
                }) {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                        Text("立即分享")
                    }
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color(red: 0.6, green: 0.1, blue: 0.95))
                    .cornerRadius(8)
                }
            }
        }
    }
    
    // 根据分享类型显示不同内容
    @ViewBuilder
    private var shareContentView: some View {
        switch selectedShareType {
        case .healthReport:
            healthReportContent
        case .achievement:
            achievementContent
        case .dailyData:
            dailyDataContent
        }
    }
    
    // 健康报告内容
    private var healthReportContent: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("本周健康总结")
                .font(.subheadline)
                .fontWeight(.medium)
            
            HStack {
                VStack(alignment: .leading) {
                    Text("平均心率")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("72 次/分")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.red)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("总步数")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("58,432 步")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                }
            }
            
            Text("睡眠质量良好，建议保持规律作息 😴")
                .font(.caption)
                .foregroundColor(.gray)
                .padding(.top, 4)
        }
    }
    
    // 运动成就内容
    private var achievementContent: some View {
        VStack(spacing: 12) {
            Image(systemName: "trophy.fill")
                .font(.system(size: 40))
                .foregroundColor(.yellow)
            
            Text("🎉 恭喜达成新成就！")
                .font(.headline)
                .fontWeight(.semibold)
            
            Text("连续7天达成步数目标")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            HStack {
                Text("目标: 10,000步")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.green.opacity(0.2))
                    .cornerRadius(4)
                
                Text("坚持: 7天")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.2))
                    .cornerRadius(4)
            }
        }
    }
    
    // 今日数据内容
    private var dailyDataContent: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("今日运动数据")
                .font(.subheadline)
                .fontWeight(.medium)
            
            VStack(spacing: 6) {
                HStack {
                    Image(systemName: "figure.walk")
                        .foregroundColor(.green)
                    Text("步数: 8,543 步")
                        .font(.subheadline)
                    Spacer()
                }
                
                HStack {
                    Image(systemName: "flame.fill")
                        .foregroundColor(.orange)
                    Text("卡路里: 324 卡")
                        .font(.subheadline)
                    Spacer()
                }
                
                HStack {
                    Image(systemName: "clock.fill")
                        .foregroundColor(.blue)
                    Text("活动时间: 2.5 小时")
                        .font(.subheadline)
                    Spacer()
                }
            }
            
            Text("今天的运动表现不错！继续保持 💪")
                .font(.caption)
                .foregroundColor(.gray)
                .padding(.top, 4)
        }
    }
    
    // 分享选项
    private var shareOptionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("分享选项")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 8) {
                ShareOptionRow(
                    icon: "photo",
                    title: "生成图片",
                    description: "创建美观的数据卡片",
                    action: {
                        // 生成图片分享
                    }
                )
                
                ShareOptionRow(
                    icon: "link",
                    title: "复制链接",
                    description: "分享到其他应用",
                    action: {
                        // 复制链接
                    }
                )
                
                ShareOptionRow(
                    icon: "calendar",
                    title: "定期分享",
                    description: "设置自动分享提醒",
                    action: {
                        // 设置定期分享
                    }
                )
            }
        }
    }
    
    // 历史分享
    private var shareHistorySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("分享历史")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 8) {
                ShareHistoryRow(
                    type: "健康报告",
                    date: "今天 14:30",
                    platform: "微信朋友圈"
                )
                
                ShareHistoryRow(
                    type: "运动成就",
                    date: "昨天 20:15",
                    platform: "微博"
                )
                
                ShareHistoryRow(
                    type: "今日数据",
                    date: "2天前",
                    platform: "QQ空间"
                )
            }
        }
    }
    
    // 生成分享文本
    private func generateShareText() {
        switch selectedShareType {
        case .healthReport:
            shareText = """
            📊 本周健康总结 - SAI Wristband
            
            💓 平均心率: 72 次/分
            👣 总步数: 58,432 步
            😴 睡眠质量良好，建议保持规律作息
            
            #健康生活 #智能手环
            """
        case .achievement:
            shareText = """
            🏆 新成就达成！- SAI Wristband
            
            🎉 连续7天达成步数目标
            🎯 目标: 10,000步
            ⏰ 坚持: 7天
            
            #运动打卡 #健康生活
            """
        case .dailyData:
            shareText = """
            📈 今日运动数据 - SAI Wristband
            
            👣 步数: 8,543 步
            🔥 卡路里: 324 卡
            ⏱️ 活动时间: 2.5 小时
            
            今天的运动表现不错！继续保持 💪
            #运动打卡
            """
        }
    }
}

// 分享类型卡片
struct ShareTypeCard: View {
    let type: ShareView.ShareType
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                Image(systemName: type.icon)
                    .font(.title3)
                    .foregroundColor(type.color)
                
                Text(type.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? type.color.opacity(0.2) : Color.gray.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(isSelected ? type.color : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// 分享选项行
struct ShareOptionRow: View {
    let icon: String
    let title: String
    let description: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(Color(red: 0.6, green: 0.1, blue: 0.95))
                    .frame(width: 20)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// 分享历史行
struct ShareHistoryRow: View {
    let type: String
    let date: String
    let platform: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(type)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(date)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Text(platform)
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(4)
        }
        .padding(.vertical, 4)
    }
}

// 分享面板
struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: nil
        )
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    ShareView()
}

//
//  TimelineSection.swift
//  SAIWristband
//
//  Created by golfy xiong on 2025/8/22.
//

import SwiftUI

// MARK: - 时间线区域
struct TimelineSection: View {
    let events: [TimelineEvent]
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(spacing: 16) {
            // 标题区域
            HStack {
                Text("Timeline")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(AppTheme.primaryText(colorScheme))
                
                Spacer()
            }
            
            // 带圆角带阴影的内容容器
            VStack(spacing: 0) {
                // 时间线卡片
                ForEach(events.indices, id: \.self) { index in
                    TimelineEventCard(
                        event: events[index],
                        isLast: index == events.count - 1
                    )
                }
                
                // 底部按钮
                TimelineBottomButton()
            }
            .padding(20)
            .background(AppTheme.cardBackground(colorScheme))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
        }
    }
}

// MARK: - 时间线事件卡片
struct TimelineEventCard: View {
    let event: TimelineEvent
    let isLast: Bool
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            // 左侧时间线指示器
            VStack(spacing: 6) {
                // 时间线图片（使用Figma设计中的图片）
                getTimelineIcon()
                    .frame(width: 19, height: 19)
                
                // 连接线（除了最后一个）
                if !isLast {
                    Rectangle()
                        .fill(AppTheme.accent.opacity(0.3))
                        .frame(width: 2, height: 22)
                }
            }
            
            // 卡片内容区域
            getCardView()
                .frame(maxWidth: .infinity)
        }
        .padding(.bottom, 10)
    }
    
    @ViewBuilder
    private func getTimelineIcon() -> some View {
        // 优先使用事件自带图片作为时间线左侧图标
        if let imageName = event.image, let uiImage = UIImage(named: imageName) {
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
        } else if let iconImage = UIImage(named: getTimelineIconName()) {
            // 其次根据事件类型显示预设时间线图片
            Image(uiImage: iconImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
        } else {
            // 兜底：如果找不到图片，使用默认的圆形背景
            Circle()
                .fill(event.isActive ? AppTheme.accent : AppTheme.cardBackground(colorScheme))
                .overlay(
                    Circle()
                        .stroke(AppTheme.accent.opacity(0.25), lineWidth: 3)
                )
        }
    }
    
    private func getTimelineIconName() -> String {
        switch event.title {
        case "Morning run":
            return "timeline_run_icon"
        case "Have a breakfast":
            return "Icon egg alt"
        case "Wake up":
            return "timeline_wakeup_icon"
        default:
            return "timeline_wakeup_icon"
        }
    }
    
    @ViewBuilder
    private func getCardView() -> some View {
        HStack(alignment: .center, spacing: 16) {
            // 左侧：时间和单位在同一行
            VStack(alignment: .leading, spacing: 2) {
                let timeComponents = event.time.components(separatedBy: " ")
                HStack(spacing: 4) {
                    Text(timeComponents.first ?? event.time)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(getTextColor())
                    
                    if timeComponents.count > 1 {
                        Text(timeComponents.last ?? "")
                            .font(.system(size: 10, weight: .regular))
                            .foregroundColor(getTextColor())
                    }
                }
            }
            .frame(width: 50, alignment: .leading)
            
            // 右侧：图片和内容在同一行，Y轴居中对齐
            HStack(alignment: .center, spacing: 10) {
                // 文字内容
                VStack(alignment: .leading) {
                    Text(event.title)
                        .font(.system(size: 17, weight: .regular))
                        .foregroundColor(getTextColor())
                        .lineLimit(1)
                }
                
                Spacer()
            }
        }
        .padding(.vertical, 10)
        .padding(.leading, 10)
        .background(getCardBackground())
        .overlay(getCardBorder())
        .cornerRadius(12)
    }
    
    private func getTextColor() -> Color {
        event.isActive ? AppTheme.accent : AppTheme.secondaryText(colorScheme)
    }
    
    private func getIconColor() -> Color {
        event.isActive ? AppTheme.accent : AppTheme.secondaryText(colorScheme)
    }
    
    private func getCardBackground() -> Color {
        switch event.cardType {
        case .solid:
            return AppTheme.cardBackground(colorScheme)
        case .dashed, .simple:
            return Color.clear
        }
    }
    
    private func getCardBorder() -> some View {
        Group {
            if event.cardType == .solid {
                // 实线边框 + 阴影
                RoundedRectangle(cornerRadius: 12)
                    .stroke(AppTheme.accent.opacity(0.25), lineWidth: 2)
                    .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
            } else {
                // 虚线边框（包括.dashed和.simple）
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        AppTheme.accent.opacity(0.25),
                        style: StrokeStyle(
                            lineWidth: 2,
                            dash: [4, 2]
                        )
                    )
            }
        }
    }
}

// MARK: - 底部按钮
struct TimelineBottomButton: View {
    @State private var showingFullTimeline = false
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        HStack {
            Spacer()
            
            Button(action: {
                showingFullTimeline = true
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "calendar")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(AppTheme.accent)
                     
                    // 右侧文字
                    Text("View full timeline")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(AppTheme.accent)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(AppTheme.accent.opacity(0.18))
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
            }
            
            Spacer()
        }
        .sheet(isPresented: $showingFullTimeline) {
            FullTimelineView()
        }
    }
}

#Preview {
    TimelineSection(events: TimelineEvent.sampleData)
        .padding()
}

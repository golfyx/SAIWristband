//
//  HealthView.swift
//  SAIWristband
//
//  Created by golfy xiong on 2025/8/24.
//

import SwiftUI

// MARK: - 图表类型枚举
enum ChartType {
    case heartRate
    case bloodPressure
    case hemoglobinA1c
    
    var title: String {
        switch self {
        case .heartRate:
            return "Resting Heart Rate"
        case .bloodPressure:
            return "Blood Pressure"
        case .hemoglobinA1c:
            return "Hemoglobin A1c"
        }
    }
    
    var chartImageName: String {
        switch self {
        case .heartRate:
            return "health heart charts"
        case .bloodPressure:
            return "health blood charts"
        case .hemoglobinA1c:
            return "health hemoglobin charts"
        }
    }
    
    var detailImageName: String {
        switch self {
        case .heartRate:
            return "health hr interpretation"
        case .bloodPressure:
            return "health blood interpretation"
        case .hemoglobinA1c:
            return "health hemoglobin interpretation"
        }
    }
}

struct HealthView: View {
    @Environment(\.colorScheme) private var colorScheme
    @State private var currentChartType: ChartType = .heartRate
    @State private var showingDetailView = false
    
    var body: some View {
        NavigationView {
            
            VStack(spacing: 0) {
                
                // 顶部导航栏
                HealthNavigationBar()
                
                // 分割线
                Divider()
                    .background(AppTheme.separator)
                
                ScrollView {
                    VStack(spacing: 0) {
                        
                        
                        VStack(spacing: 24) {
                            // Score模块
                            ScoreCard()
                            
                            // 图表模块
                            ChartCard(
                                chartType: $currentChartType,
                                onInterpretationTap: {
                                    showingDetailView = true
                                }
                            )
                            
                            // Tips模块
                            TipsCard(chartType: currentChartType)
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        .padding(.bottom, 60) // 为TabBar留出空间
                    }
                }
                .scrollIndicators(.hidden)
                .background(AppTheme.background(colorScheme))
                .navigationBarHidden(true)
                .sheet(isPresented: $showingDetailView) {
                    HealthDetailView(chartType: currentChartType)
                }
            }
        }
    }
}

// MARK: - 导航栏
struct HealthNavigationBar: View {
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        HStack {
            Spacer()
            Text("Health")
                .font(.system(size: 18, weight: .regular))
                .foregroundColor(AppTheme.primaryText(colorScheme))
            Spacer()
        }
        .padding(.horizontal, 28)
        .padding(.top, 12)
        .padding(.bottom, 16)
        .background(AppTheme.cardBackground(colorScheme))
    }
}

// MARK: - Score卡片
struct ScoreCard: View {
    @Environment(\.colorScheme) private var colorScheme
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading) {
            // 标题
            Text("Brain Fog Score")
                .font(.system(size: 20, weight: .regular))
                .foregroundColor(AppTheme.primaryText(colorScheme))
            
            // 图片
            Image("health score")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: .infinity)
            
            // 第一段文字
            Text("In great shape! Highly concentrated and efficient!")
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(AppTheme.primaryText(colorScheme))
            
            // 横线
            Rectangle()
                .fill(AppTheme.separatorColor(colorScheme))
                .frame(height: 1)
            
            // 第二段文字
            Text("Suitable for in-depth work, such as writing reports, analyzing data or learning.")
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(AppTheme.primaryText(colorScheme))
            
            // 展开的内容（health score hrv 图片）
            if isExpanded {
                Image("health score hrv")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
            
            // 箭头按钮
            HStack {
                Spacer()
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isExpanded.toggle()
                    }
                }) {
                    Image(isExpanded ? "health up arrow" : "health down arrow")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                }
                Spacer()
            }
            .padding(.bottom, 8)
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .background(AppTheme.cardBackground(colorScheme))
        .cornerRadius(12)
        .shadow(color: .black.opacity(AppTheme.shadowOpacity(colorScheme)), radius: 8, x: 0, y: 2)
    }
}

// MARK: - 图表卡片
struct ChartCard: View {
    @Binding var chartType: ChartType
    let onInterpretationTap: () -> Void
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 顶部：左中右结构
            HStack {
                Spacer()
                
                // 左箭头
                Button(action: {
                    switch chartType {
                    case .heartRate:
                        chartType = .hemoglobinA1c
                    case .bloodPressure:
                        chartType = .heartRate
                    case .hemoglobinA1c:
                        chartType = .bloodPressure
                    }
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(AppTheme.primaryText(colorScheme))
                }
                .frame(width: 24, height: 24)
                
                Spacer()
                    .frame(width: 10)
                
                // 中间标题
                Text(chartType.title)
                    .font(.system(size: 18, weight: .regular))
                    .foregroundColor(AppTheme.primaryText(colorScheme))
                
                Spacer()
                    .frame(width: 10)
                
                // 右箭头
                Button(action: {
                    switch chartType {
                    case .heartRate:
                        chartType = .bloodPressure
                    case .bloodPressure:
                        chartType = .hemoglobinA1c
                    case .hemoglobinA1c:
                        chartType = .heartRate
                    }
                }) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(AppTheme.primaryText(colorScheme))
                }
                .frame(width: 24, height: 24)
                
                Spacer()
            }
            .padding(.horizontal, 4)
            
            // 图表图片
            Image(chartType.chartImageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: .infinity)
            
            // Data interpretation按钮
            HStack {
                Spacer()
                Button(action: onInterpretationTap) {
                    Text("Data interpretation")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                        .background(AppTheme.accent)
                        .clipShape(Capsule())
                }
                Spacer()
            }
        }
        .padding(20)
        .background(AppTheme.cardBackground(colorScheme))
        .cornerRadius(12)
        .shadow(color: .black.opacity(AppTheme.shadowOpacity(colorScheme)), radius: 8, x: 0, y: 2)
    }
}

// MARK: - Tips卡片
struct TipsCard: View {
    let chartType: ChartType
    @Environment(\.colorScheme) private var colorScheme
    
    var imageName: String {
        switch chartType {
        case .heartRate:
            return "health explore"
        case .bloodPressure:
            return "health supplements"
        case .hemoglobinA1c:
            return "health experiment"
        }
    }
    
    var tipsText: String {
        switch chartType {
        case .heartRate:
            return "Explore a healthier you—one small change at a time—with guided nutrition and activity tips."
        case .bloodPressure:
            return "Discover scientifically-formulated supplements to support your wellness goals and fill nutritional gaps."
        case .hemoglobinA1c:
            return "Discover data-driven health insights with our innovative lab analysis tools."
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 图片
            Image(imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: .infinity)
            
            // Tips文字
            Text(tipsText)
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(AppTheme.primaryText(colorScheme))
        }
        .padding(20)
        .background(AppTheme.cardBackground(colorScheme))
        .cornerRadius(12)
        .shadow(color: .black.opacity(AppTheme.shadowOpacity(colorScheme)), radius: 8, x: 0, y: 2)
    }
}

#Preview {
    HealthView()
}

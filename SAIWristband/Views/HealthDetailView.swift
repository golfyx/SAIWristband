//
//  HealthDetailView.swift
//  SAIWristband
//
//  Created by golfy xiong on 2025/8/24.
//

import SwiftUI

struct HealthDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    let chartType: ChartType
    
    var body: some View {
        NavigationView {
            
            VStack(spacing: 0) {
                // 自定义导航栏
                HealthDetailNavigationBar(
                    title: chartType.title,
                    onBack: {
                        dismiss()
                    }
                )
                
                // 分割线
                Divider()
                    .background(AppTheme.separator)
                
                ScrollView {
                    
                    // 内容图片
                    Image(chartType.detailImageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity)
                        .padding(16)
                }
                .scrollIndicators(.hidden)
                .background(AppTheme.background(colorScheme))
                .navigationBarHidden(true)
            }
        }
    }
}

// MARK: - 详细界面导航栏
struct HealthDetailNavigationBar: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    let title: String
    let onBack: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: onBack) {
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

#Preview {
    HealthDetailView(chartType: .heartRate)
}

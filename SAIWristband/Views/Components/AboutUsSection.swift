//
//  AboutUsSection.swift
//  SAIWristband
//
//  Created by golfy xiong on 2025/8/22.
//

import SwiftUI

// MARK: - 关于我们区域
struct AboutUsSection: View {
    @Environment(\.colorScheme) private var colorScheme
    var body: some View {
        VStack(spacing: 16) {
            // 标题
            HStack {
                Text("About Us")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(AppTheme.primaryText(colorScheme))
                Spacer()
            }
            
            // 内容卡片
            VStack(alignment: .leading, spacing: 16) {
                // 图片
                Image("about_us_image")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 231)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                
                // 文本内容
                VStack(alignment: .leading, spacing: 8) {
                    Group {
                        Text("Lorem ipsum dolor sit amet, consectetur")
                        Text("adipiscing elit. Curabitur nec arcu molestie,")
                        Text("mollis purus sit amet, sodales libero. Nulla id")
                        Text("odio maximus, congue.")
                    }
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(AppTheme.secondaryText(colorScheme))
                }
            }
            .padding(16)
            .background(AppTheme.cardBackground(colorScheme))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.08), radius: 0, x: 0, y: 0)
        }
    }
}

#Preview {
    AboutUsSection()
        .padding()
}

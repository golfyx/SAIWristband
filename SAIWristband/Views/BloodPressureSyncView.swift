//
//  BloodPressureSyncView.swift
//  SAIWristband
//
//  Created by AI Assistant on 2025/8/26.
//

import SwiftUI

struct BloodPressureSyncView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    
    // 轮播项
    private let carouselItems: [(image: String, title: String)] = [
        ("Image26", "Place the mobile phone within 5 meters of the blood\npressure monitor and turn on OMRON Plus. \nThe measurement results can be automatically\nuploaded after the measurement is completed."),
        ("Image26", "Place the mobile phone within 5 meters of the blood\npressure monitor and turn on OMRON Plus. \nThe measurement results can be automatically\nuploaded after the measurement is completed.")
    ]
    @State private var currentPage: Int = 0
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 自定义导航栏
                CustomBPNavigationBar(title: "Blood pressure", onBack: {
                    dismiss()
                })
                
                // 下分割线
                Divider()
                    .background(Color.gray.opacity(0.3))
                
                // 内容
                GeometryReader { geo in
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 24) {
                            // 左上提示
                            HStack(alignment: .center, spacing: 12) {
                                Image(systemName: "info.circle.fill")
                                    .foregroundColor(AppTheme.accent)
                                    .font(.system(size: 20))
                                    .frame(width: 24, height: 24)
                                
                                Text("0+ reminder")
                                    .font(.system(size: 14, weight: .regular))
                                    .foregroundColor(AppTheme.accent)
                            }
                            .padding(.horizontal, 20)
                            
                            // 轮播图
                            VStack(alignment: .leading, spacing: 12) {
                                TabView(selection: $currentPage) {
                                    ForEach(0..<carouselItems.count, id: \.self) { index in
                                        VStack(spacing: 12) {
                                            Image(carouselItems[index].image)
                                                .resizable()
                                                .scaledToFit()
                                                .frame(maxWidth: .infinity)
                                                .frame(height: 200)
                                                .clipped()
                                            
                                            Text(carouselItems[index].title)
                                                .font(.system(size: 14))
                                                .foregroundColor(AppTheme.accent)
                                                .multilineTextAlignment(.center)
                                                .frame(maxWidth: .infinity)
                                                .fixedSize(horizontal: false, vertical: true)
                                        }
                                        .tag(index)
                                    }
                                }
                                .frame(minHeight: 300)
                                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))

                                // 自定义页码指示点（放在轮播图下方）
                                HStack(spacing: 6) {
                                    ForEach(0..<carouselItems.count, id: \.self) { index in
                                        Circle()
                                            .fill(index == currentPage ? AppTheme.accent : AppTheme.separator)
                                            .frame(width: (index == currentPage ? 8 : 6), height: (index == currentPage ? 8 : 6))
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.top, 2)
                            }
                            
                            // 按钮组
                            HStack(spacing: 16) {
                                RoundedButton(
                                    title: "Upload",
                                    systemImage: "tray.and.arrow.up",
                                    bgColor: AppTheme.accent
                                ) {
                                    // TODO: 文件上传处理
                                }
                                
                                RoundedButton(
                                    title: "Photo",
                                    systemImage: "photo.on.rectangle",
                                    bgColor: AppTheme.accent
                                ) {
                                    // TODO: 照片选择处理
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 20)
                        }
                        .padding(.top, 24)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
            .background(AppTheme.background(colorScheme))
            .navigationBarHidden(true)
        }
    }
}

// MARK: - 自定义导航栏
private struct CustomBPNavigationBar: View {
    let title: String
    let onBack: () -> Void
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        HStack {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(AppTheme.primaryText(colorScheme))
                    .frame(width: 44, height: 44)
                    .background(AppTheme.cardBackground(colorScheme))
                    .clipShape(Circle())
                    .contentShape(Circle())
                    .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
            }
            
            Spacer()
            
            Text(title)
                .font(.custom("Montserrat", size: 18))
                .fontWeight(.regular)
                .foregroundColor(AppTheme.primaryText(colorScheme))
            
            Spacer()
            
            Color.clear
                .frame(width: 44, height: 44)
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 16)
        .background(AppTheme.cardBackground(colorScheme))
        .glassBackground(RoundedRectangle(cornerRadius: 0))
    }
}

// MARK: - 圆角按钮
private struct RoundedButton: View {
    let title: String
    let systemImage: String
    let bgColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: systemImage)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 18, height: 18)
                Text(title)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .background(AppTheme.accent)
            .cornerRadius(12)
            .contentShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .accessibilityLabel(Text(title))
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    BloodPressureSyncView()
}



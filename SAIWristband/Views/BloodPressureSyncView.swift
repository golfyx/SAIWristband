//
//  BloodPressureSyncView.swift
//  SAIWristband
//
//  Created by AI Assistant on 2025/8/26.
//

import SwiftUI

struct BloodPressureSyncView: View {
    @Environment(\.dismiss) private var dismiss
    
    // 轮播项
    private let carouselItems: [(image: String, title: String)] = [
        ("watch1_image", "Pair your watch and start syncing"),
        ("watch2_image", "Keep the watch close to your iPhone"),
        ("watch3_image", "Ensure Bluetooth is enabled"),
        ("watch4_image", "Sync completes in seconds")
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
                    let s = geo.size.width / 375.0 // 按 @1x 375 适配比例
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 24 * s) {
                            // 左上提示
                            HStack(alignment: .center, spacing: 12 * s) {
                                Image(systemName: "info.circle.fill")
                                    .foregroundColor(Color(red: 0.30, green: 0.04, blue: 0.44))
                                    .font(.system(size: 20 * s))
                                    .frame(width: 24 * s, height: 24 * s)
                                
                                Text("0+ reminder")
                                    .font(.system(size: 14 * s, weight: .regular))
                                    .foregroundColor(Color(red: 0.30, green: 0.04, blue: 0.44))
                            }
                            .padding(.horizontal, 20 * s)
                            
                            // 轮播图
                            VStack(alignment: .leading, spacing: 12 * s) {
                                TabView(selection: $currentPage) {
                                    ForEach(0..<carouselItems.count, id: \.self) { index in
                                        VStack(spacing: 12 * s) {
                                            Image(carouselItems[index].image)
                                                .resizable()
                                                .scaledToFit()
                                                .frame(maxWidth: .infinity)
                                                .frame(height: 200 * s)
                                                .clipped()
                                            
                                            Text(carouselItems[index].title)
                                                .font(.system(size: 14 * s))
                                                .foregroundColor(Color(red: 0.30, green: 0.04, blue: 0.44))
                                                .multilineTextAlignment(.center)
                                                .frame(maxWidth: .infinity)
                                        }
                                        .padding(.horizontal, 20 * s)
                                        .tag(index)
                                    }
                                }
                                .frame(height: 250 * s)
                                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))

                                // 自定义页码指示点（放在轮播图下方）
                                HStack(spacing: 6 * s) {
                                    ForEach(0..<carouselItems.count, id: \.self) { index in
                                        Circle()
                                            .fill(index == currentPage ? Color(red: 0.30, green: 0.04, blue: 0.44) : Color.gray.opacity(0.3))
                                            .frame(width: (index == currentPage ? 8 : 6) * s, height: (index == currentPage ? 8 : 6) * s)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.top, 2 * s)
                            }
                            
                            // 按钮组
                            HStack(spacing: 16 * s) {
                                RoundedButton(
                                    title: "Upload",
                                    systemImage: "tray.and.arrow.up",
                                    bgColor: Color(red: 0.62, green: 0.48, blue: 0.72),
                                    scale: s
                                ) {
                                    // TODO: 文件上传处理
                                }
                                
                                RoundedButton(
                                    title: "Photo",
                                    systemImage: "photo.on.rectangle",
                                    bgColor: Color(red: 0.43, green: 0.24, blue: 0.46),
                                    scale: s
                                ) {
                                    // TODO: 照片选择处理
                                }
                            }
                            .padding(.horizontal, 20 * s)
                            .padding(.bottom, 20 * s)
                        }
                        .padding(.top, 24 * s)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
            .background(Color.white)
            .navigationBarHidden(true)
        }
    }
}

// MARK: - 自定义导航栏
private struct CustomBPNavigationBar: View {
    let title: String
    let onBack: () -> Void
    
    var body: some View {
        HStack {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(Color(red: 0.03, green: 0.03, blue: 0.03))
                    .frame(width: 44, height: 44)
                    .background(Color.white)
                    .clipShape(Circle())
                    .contentShape(Circle())
                    .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
            }
            
            Spacer()
            
            Text(title)
                .font(.custom("Montserrat", size: 18))
                .fontWeight(.regular)
                .foregroundColor(Color(red: 0.03, green: 0.03, blue: 0.03))
            
            Spacer()
            
            Color.clear
                .frame(width: 44, height: 44)
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 16)
        .background(Color.white)
    }
}

// MARK: - 圆角按钮
private struct RoundedButton: View {
    let title: String
    let systemImage: String
    let bgColor: Color
    let scale: CGFloat
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8 * scale) {
                Image(systemName: systemImage)
                    .font(.system(size: 16 * scale, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 18 * scale, height: 18 * scale)
                Text(title)
                    .font(.system(size: 14 * scale, weight: .bold))
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 44 * scale)
            .background(bgColor)
            .cornerRadius(12 * scale)
            .contentShape(RoundedRectangle(cornerRadius: 12 * scale, style: .continuous))
            .accessibilityLabel(Text(title))
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    BloodPressureSyncView()
}



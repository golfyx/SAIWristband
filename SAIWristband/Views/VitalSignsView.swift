//
//  VitalSignsView.swift
//  SAIWristband
//
//  Created by golfy xiong on 2025/8/22.
//

import SwiftUI

struct VitalSignsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 自定义导航栏
                CustomVitalSignsNavigationBar(onBack: {
                    dismiss()
                })
                
                // 分割线
                Divider()
                    .background(Color.gray.opacity(0.3))
                
                // 内容区域
                ScrollView {
                    VStack(spacing: 32) {
                        // Add health data 部分
                        AddHealthDataSection()
                        
                        // Select tests to start 部分
                        SelectTestsSection()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                    .padding(.bottom, 60)
                    .frame(maxWidth: .infinity)
                }
            }
            .background(AppTheme.background(colorScheme))
            .navigationBarHidden(true)
        }
    }
}

// MARK: - 自定义导航栏
struct CustomVitalSignsNavigationBar: View {
    let onBack: () -> Void
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        HStack {
            // 返回按钮
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(AppTheme.primaryText(colorScheme))
                    .frame(width: 44, height: 44)
                    .background(AppTheme.cardBackground(colorScheme))
                    .clipShape(Circle())
                    .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
            }
            
            Spacer()
            
            // 标题
            Text("Vital signs")
                .font(.custom("Montserrat", size: 18))
                .fontWeight(.regular)
                .foregroundColor(AppTheme.primaryText(colorScheme))
            
            Spacer()
            
            // 占位视图保持对称
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

// MARK: - Add Health Data 部分
struct AddHealthDataSection: View {
    @State private var showingBloodPressureSync = false
    @State private var showingBloodGlucose = false
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // 标题
            Text("Add health data")
                .font(.custom("Roboto Mono", size: 18))
                .fontWeight(.bold)
                .foregroundColor(AppTheme.primaryText(colorScheme))
            
            // 三个按钮
            VStack(spacing: 16) {
                HealthDataButton(
                    title: "Weight",
                    icon: "scalemass",
                    backgroundColor: Color(red: 0.62, green: 0.48, blue: 0.72)
                )
                
                Button(action: {
                    showingBloodPressureSync = true
                }) {
                    HealthDataButton(
                        title: "Blood pressure",
                        icon: "heart.fill",
                        backgroundColor: Color(red: 0.43, green: 0.24, blue: 0.46)
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                Button(action: {
                    showingBloodGlucose = true
                }) {
                    HealthDataButton(
                        title: "Blood sugar",
                        icon: "drop.triangle.fill",
                        backgroundColor: Color(red: 0.62, green: 0.48, blue: 0.72)
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .sheet(isPresented: $showingBloodPressureSync) {
            BloodPressureSyncView()
        }
        .sheet(isPresented: $showingBloodGlucose) {
            BloodGlucoseView()
        }
    }
}

// MARK: - Health Data 按钮
struct HealthDataButton: View {
    let title: String
    let icon: String
    let backgroundColor: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Spacer()

            // 左侧图标
            Image(systemName: icon)
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(.white)
                .frame(width: 24, height: 24)
            
            // 右侧文字
            Text(title)
                .font(.custom("Roboto", size: 16))
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(backgroundColor)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.08), radius: 0, x: 0, y: 0)
    }
}

// MARK: - Select Tests to Start 部分
struct SelectTestsSection: View {
    @Environment(\.colorScheme) private var colorScheme
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // 标题
            Text("Select Tests to Start")
                .font(.custom("Roboto Mono", size: 18))
                .fontWeight(.bold)
                .foregroundColor(AppTheme.primaryText(colorScheme))
            
            // 四个测试按钮 - 自定义布局
            VStack(spacing: 16) {
                // 上面一行
                HStack(spacing: 16) {
                    TestButton(
                        title: "Heart Rate",
                        icon: "heart.fill",
                        backgroundColor: Color(red: 0.62, green: 0.44, blue: 0.74),
                        isWide: false
                    )
                    
                    TestButton(
                        title: "Blood Oxygen",
                        icon: "lungs.fill",
                        backgroundColor: Color(red: 0.43, green: 0.24, blue: 0.46),
                        isWide: true
                    )
                }
                
                // 下面一行
                HStack(spacing: 16) {
                    TestButton(
                        title: "Electrocardiogram",
                        icon: "waveform.path.ecg",
                        backgroundColor: Color(red: 0.43, green: 0.24, blue: 0.46),
                        isWide: true
                    )
                    
                    TestButton(
                        title: "Respiration",
                        icon: "lungs",
                        backgroundColor: Color(red: 0.62, green: 0.44, blue: 0.74),
                        isWide: false
                    )
                }
            }
        }
    }
}

// MARK: - Test 按钮
struct TestButton: View {
    let title: String
    let icon: String
    let backgroundColor: Color
    let isWide: Bool
    
    var body: some View {
        Button(action: {
            // 处理按钮点击
            print("\(title) tapped")
        }) {
            HStack(spacing: 12) {
                // 图标
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(.white)
                    .frame(width: 24, height: 24)
                
                // 文字
                Text(title)
                    .font(.custom("Roboto", size: 16))
                    .fontWeight(.regular)
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }
            .frame(height: 75)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 16)
            .background(backgroundColor)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.1), radius: 0, x: 0, y: 0)
        }
        .buttonStyle(PlainButtonStyle())
        .frame(width: isWide ? nil : 170)
    }
}

#Preview {
    VitalSignsView()
}

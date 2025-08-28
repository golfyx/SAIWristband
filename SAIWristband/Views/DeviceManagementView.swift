//
//  DeviceManagementView.swift
//  SAIWristband
//
//  Created by golfy xiong on 2025/8/22.
//

import SwiftUI

struct DeviceManagementView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var connectedDevice = Device.connectedDevice
    @State private var deviceList = Device.sampleData
    @State private var healthReport = DeviceHealthReport.sampleData
    @State private var isNotificationEnabled = true
    
    @Environment(\.colorScheme) private var colorScheme
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    // 自定义导航栏
                    CustomDeviceNavigationBar {
                        presentationMode.wrappedValue.dismiss()
                    }
                    
                    // 分割线
                    Divider()
                        .background(AppTheme.separator)
                    
                    VStack(spacing: 0) {
                        // Manage Devices 标题
                        HStack {
                            Text("Manage Devices")
                                .font(.custom("Montserrat", size: 20))
                                .fontWeight(.regular)
                                .foregroundColor(AppTheme.primaryText(colorScheme))
                            Spacer()
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 24)
                        .padding(.bottom, 19) // 调整间距符合设计稿
                        
                        // 设备详细信息卡片
                        DeviceDetailCard(
                            device: connectedDevice,
                            isNotificationEnabled: $isNotificationEnabled
                        )
                        .padding(.horizontal, 24)
                        
                        Spacer()
                        
                        // 设备列表
                        DeviceListSection(devices: deviceList)
                    }
                }
            }
            .background(AppTheme.background(colorScheme))
            .navigationBarHidden(true)
        }
        .navigationBarHidden(true)
    }
}

// MARK: - 自定义设备页面导航栏
struct CustomDeviceNavigationBar: View {
    let onBackTapped: () -> Void
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        HStack {
            // 返回按钮
            Button(action: onBackTapped) {
                RoundedRectangle(cornerRadius: 9.5)
                    .fill(AppTheme.cardBackground(colorScheme))
                    .frame(width: 19, height: 19)
                    .overlay(
                        Image(systemName: "chevron.left")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(AppTheme.primaryText(colorScheme))
                    )
            }
            
            Spacer()
            
            // 导航标题
            Text("Devices")
                .font(.custom("Montserrat", size: 18))
                .fontWeight(.regular)
                .foregroundColor(AppTheme.primaryText(colorScheme))
            
            Spacer()
            
            // 空白区域（保持居中对称）
            Rectangle()
                .fill(Color.clear)
                .frame(width: 19, height: 19)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
        .background(AppTheme.cardBackground(colorScheme))
        .glassBackground(RoundedRectangle(cornerRadius: 0))
    }
}

// MARK: - 设备详细信息卡片
struct DeviceDetailCard: View {
    let device: Device
    @Binding var isNotificationEnabled: Bool
    @State private var showUnbindAlert = false
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(spacing: 0) {
            // 设备主要信息区域
            RoundedRectangle(cornerRadius: 22)
                .fill(AppTheme.cardBackground(colorScheme))
                .frame(height: 274)
                .overlay(
                    VStack(spacing: 0) {
                        // 设备图片和基本信息
                        HStack(spacing: 12) {
                            // 设备图片 - 使用实际的手表图片
                            Image("health_watch_logo")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 50, height: 50)
                                .clipShape(Circle())
                            
                            VStack(alignment: .leading, spacing: 8) {
                                // 设备名称
                                Text(device.name)
                                    .font(.custom("Montserrat", size: 16))
                                    .fontWeight(.regular)
                                    .foregroundColor(AppTheme.primaryText(colorScheme))
                                
                                // 连接状态
                                Text(device.connectionStatus.rawValue)
                                    .font(.custom("Montserrat", size: 12))
                                    .fontWeight(.regular)
                                    .foregroundColor(AppTheme.secondaryText(colorScheme))
                            }
                            
                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
                        
                        // 设备详细信息
                        VStack(spacing: 18) {
                            // 电量信息
                            if let batteryLevel = device.batteryLevel {
                                HStack(spacing: 0) {
                                    Text("Battery: \(batteryLevel)%")
                                        .font(.custom("Montserrat", size: 14))
                                        .fontWeight(.regular)
                                        .foregroundColor(AppTheme.primaryText(colorScheme))
                                    
                                    Spacer()
                                }
                                .padding(.leading, 16)
                            }
                            
                            // 使用时间
                            if let usageTime = device.usageTime {
                                HStack(spacing: 0) {
                                    Text("Usage Time: \(usageTime)")
                                        .font(.custom("Montserrat", size: 14))
                                        .fontWeight(.regular)
                                        .foregroundColor(AppTheme.primaryText(colorScheme))
                                    
                                    Spacer()
                                }
                                .padding(.leading, 16)
                            }
                            
                            // 设备型号
                            if let model = device.model {
                                HStack(spacing: 0) {
                                    Text("Model: \(model)")
                                        .font(.custom("Montserrat", size: 14))
                                        .fontWeight(.regular)
                                        .foregroundColor(AppTheme.primaryText(colorScheme))
                                    
                                    Spacer()
                                }
                                .padding(.leading, 16)
                            }
                            
                            // 通知设置
                            HStack {
                                Text("Notifications")
                                    .font(.custom("Montserrat", size: 14))
                                    .fontWeight(.regular)
                                    .foregroundColor(AppTheme.primaryText(colorScheme))
                                
                                Spacer()
                                
                                // 通知开关
                                Toggle("", isOn: $isNotificationEnabled)
//                                    .toggleStyle(CustomToggleStyle())
                                    .frame(width: 47, height: 23)
                            }
                            .padding(.horizontal, 16)
                        }
                        
                        Spacer()
                        
                        // 解绑按钮
                        Button(action: {
                            showUnbindAlert = true
                        }) {
                            HStack {
                                Spacer()
                                Text("Unbind Device")
                                    .font(.custom("Montserrat", size: 14))
                                    .fontWeight(.regular)
                                    .foregroundColor(.white)
                                Spacer()
                            }
                            .frame(height: 36)
                            .background(AppTheme.accent)
                            .cornerRadius(18)
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 16)
                        .alert("解绑设备", isPresented: $showUnbindAlert) {
                            Button("取消", role: .cancel) { }
                            Button("确认解绑", role: .destructive) {
                                // 处理解绑逻辑
                                print("Device unbound")
                            }
                        } message: {
                            Text("确定要解绑此设备吗？")
                        }
                    }
                )
                .shadow(color: .black.opacity(AppTheme.shadowOpacity(colorScheme)), radius: 10, x: 2, y: 0)
        }
    }
}

// MARK: - 自定义Toggle样式
struct CustomToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            // 背景
            RoundedRectangle(cornerRadius: 11.5)
                .fill(configuration.isOn ? AppTheme.accent : AppTheme.separator.opacity(0.5))
                .frame(width: 47, height: 23)
                .overlay(
                    RoundedRectangle(cornerRadius: 11.5)
                        .stroke(AppTheme.accent, lineWidth: 1)
                )
            
            // 滑块
            Circle()
                .fill(AppTheme.accent)
                .frame(width: 17, height: 16)
                .offset(x: configuration.isOn ? 13.25 : -13.25)
                .animation(.easeInOut(duration: 0.2), value: configuration.isOn)
        }
        .onTapGesture {
            configuration.isOn.toggle()
        }
    }
}

// MARK: - 设备列表区域
struct DeviceListSection: View {
    let devices: [Device]
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(devices.enumerated()), id: \.element.id) { index, device in
                DeviceListRow(device: device, isLast: index == devices.count - 1)
                    .padding(.horizontal, 16)
            }
        }
        .background(AppTheme.cardBackground(colorScheme))
        .cornerRadius(22)
        .shadow(color: .black.opacity(AppTheme.shadowOpacity(colorScheme)), radius: 10, x: 2, y: 0)
        .padding(.vertical, 16)
        .padding(22)
    }
}

// MARK: - 设备列表行
struct DeviceListRow: View {
    let device: Device
    let isLast: Bool
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 15) {
                // 设备图标 - 使用实际图片
                Image(getDeviceImageName(for: device.brand))
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 60, height: 60)
                    .background(Color.clear)
                
                // 设备信息
                VStack(alignment: .leading, spacing: 2) {
                    Text(device.brand)
                        .font(.custom("Montserrat", size: 18))
                        .fontWeight(.regular)
                        .foregroundColor(AppTheme.primaryText(colorScheme))
                    
                    Text(device.description)
                        .font(.custom("Montserrat", size: 14))
                        .fontWeight(.regular)
                        .foregroundColor(AppTheme.secondaryText(colorScheme))
                }
                
                Spacer()
                
                // 右箭头
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(AppTheme.accent.opacity(0.8))
            }
            .padding(.horizontal, 5)
            .frame(height: 80)
            
            // 分割线（除了最后一行）
            if !isLast {
                Rectangle()
                    .fill(AppTheme.separator)
                    .frame(height: 1)
            }
        }
    }
    
    private func getDeviceImageName(for brand: String) -> String {
        switch brand {
        case "Abbott":
            return "abbott_device"
        case "Omron":
            return "omron_device"
        case "Withings":
            return "withings_device"
        default:
            return "health_watch_logo"
        }
    }
}

#Preview {
    DeviceManagementView()
}

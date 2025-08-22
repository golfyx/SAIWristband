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
                        .background(Color.gray.opacity(0.3))
                    
                    VStack(spacing: 0) {
                        // Manage Devices 标题
                        HStack {
                            Text("Manage Devices")
                                .font(.custom("Montserrat", size: 20))
                                .fontWeight(.regular)
                                .foregroundColor(Color(red: 0.11, green: 0.11, blue: 0.11))
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
            .background(Color.white)
            .navigationBarHidden(true)
        }
        .navigationBarHidden(true)
    }
}

// MARK: - 自定义设备页面导航栏
struct CustomDeviceNavigationBar: View {
    let onBackTapped: () -> Void
    
    var body: some View {
        HStack {
            // 返回按钮
            Button(action: onBackTapped) {
                RoundedRectangle(cornerRadius: 9.5)
                    .fill(Color.white)
                    .frame(width: 19, height: 19)
                    .overlay(
                        Image(systemName: "chevron.left")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Color(red: 0.01, green: 0.01, blue: 0.01))
                    )
            }
            
            Spacer()
            
            // 导航标题
            Text("Devices")
                .font(.custom("Montserrat", size: 18))
                .fontWeight(.regular)
                .foregroundColor(Color(red: 0.01, green: 0.01, blue: 0.01))
            
            Spacer()
            
            // 空白区域（保持居中对称）
            Rectangle()
                .fill(Color.clear)
                .frame(width: 19, height: 19)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
        .background(Color.white)
    }
}

// MARK: - 设备详细信息卡片
struct DeviceDetailCard: View {
    let device: Device
    @Binding var isNotificationEnabled: Bool
    @State private var showUnbindAlert = false
    
    var body: some View {
        VStack(spacing: 0) {
            // 设备主要信息区域
            RoundedRectangle(cornerRadius: 22)
                .fill(Color.white)
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
                                .background(Color.clear)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                // 设备名称
                                Text(device.name)
                                    .font(.custom("Montserrat", size: 16))
                                    .fontWeight(.regular)
                                    .foregroundColor(Color(red: 0.01, green: 0.01, blue: 0.01))
                                
                                // 连接状态
                                Text(device.connectionStatus.rawValue)
                                    .font(.custom("Montserrat", size: 12))
                                    .fontWeight(.regular)
                                    .foregroundColor(Color(red: 0.56, green: 0.56, blue: 0.57))
                            }
                            
                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        
                        // 设备详细信息
                        VStack(spacing: 18) {
                            // 电量信息
                            if let batteryLevel = device.batteryLevel {
                                HStack(spacing: 0) {
                                    Text("Battery: \(batteryLevel)%")
                                        .font(.custom("Montserrat", size: 14))
                                        .fontWeight(.regular)
                                        .foregroundColor(Color(red: 0.01, green: 0.01, blue: 0.01))
                                    
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
                                        .foregroundColor(Color(red: 0.01, green: 0.01, blue: 0.01))
                                    
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
                                        .foregroundColor(Color(red: 0.01, green: 0.01, blue: 0.01))
                                    
                                    Spacer()
                                }
                                .padding(.leading, 16)
                            }
                            
                            // 通知设置
                            HStack {
                                Text("Notifications")
                                    .font(.custom("Montserrat", size: 14))
                                    .fontWeight(.regular)
                                    .foregroundColor(Color(red: 0.01, green: 0.01, blue: 0.01))
                                
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
                            .background(Color(red: 0.60, green: 0.10, blue: 0.95))
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
                .shadow(color: .black.opacity(0.1), radius: 5, x: 2, y: 0)
        }
    }
}

// MARK: - 自定义Toggle样式
struct CustomToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            // 背景
            RoundedRectangle(cornerRadius: 11.5)
                .fill(configuration.isOn ? Color(red: 0.61, green: 0.31, blue: 0.59) : Color.gray.opacity(0.3))
                .frame(width: 47, height: 23)
                .overlay(
                    RoundedRectangle(cornerRadius: 11.5)
                        .stroke(Color(red: 0.61, green: 0.31, blue: 0.59), lineWidth: 1)
                )
            
            // 滑块
            Circle()
                .fill(Color(red: 0.61, green: 0.31, blue: 0.59))
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
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(devices.enumerated()), id: \.element.id) { index, device in
                DeviceListRow(device: device, isLast: index == devices.count - 1)
                    .padding(.horizontal, 16)
            }
        }
        .background(Color.white)
        .cornerRadius(22)
        .shadow(color: .black.opacity(0.1), radius: 10, x: 2, y: 0)
        .padding(.vertical, 16)
        .padding(22)
    }
}

// MARK: - 设备列表行
struct DeviceListRow: View {
    let device: Device
    let isLast: Bool
    
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
                        .foregroundColor(Color(red: 0.01, green: 0.01, blue: 0.01))
                    
                    Text(device.description)
                        .font(.custom("Montserrat", size: 14))
                        .fontWeight(.regular)
                        .foregroundColor(Color(red: 0.01, green: 0.01, blue: 0.01))
                }
                
                Spacer()
                
                // 右箭头
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color(red: 0.76, green: 0.66, blue: 0.83))
            }
            .padding(.horizontal, 5)
            .frame(height: 80)
            
            // 分割线（除了最后一行）
            if !isLast {
                Rectangle()
                    .fill(Color(red: 0.76, green: 0.66, blue: 0.83))
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

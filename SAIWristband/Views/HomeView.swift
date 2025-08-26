//
//  HomeView.swift
//  SAIWristband
//
//  Created by golfy xiong on 2025/8/22.
//

import SwiftUI

struct HomeView: View {
    @State private var healthData = HealthSummary.sampleData
    @State private var timelineEvents = TimelineEvent.sampleData
    @State private var deviceInfo = DeviceInfo.sampleData
    @State private var showingProfile = false
    @State private var showingDeviceManagement = false
    @State private var showingFloatingMenu = false
    @State private var showingAdvisor = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    // 自定义导航栏
                    CustomNavigationBar(
                        deviceInfo: deviceInfo, 
                        showingProfile: $showingProfile,
                        showingDeviceManagement: $showingDeviceManagement
                    )
                    
                    // 分割线
                    Divider()
                        .background(Color.gray.opacity(0.3))
                    
                    VStack(spacing: 24) {
                        // 消息提示区域
                        MessageNotificationView()
                        
                        // 椭圆形测试数值卡片
                        TestValueCardsSection()
                        
                        // 健康概要区域
                        HealthSummarySection(
                            healthData: healthData,
                            showingFloatingMenu: $showingFloatingMenu
                        )
                        
                        // 时间线区域
                        TimelineSection(events: timelineEvents)
                        
                        // 关于我们区域
                        AboutUsSection()
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 60) // 为TabBar留出空间
                }
            }
            .background(Color.white)
            .navigationBarHidden(true)
            .sheet(isPresented: $showingProfile) {
                ProfileView()
            }
            .sheet(isPresented: $showingDeviceManagement) {
                DeviceManagementView()
            }
            .overlay(
                FloatingActionMenu(
                    isShowing: $showingFloatingMenu,
                    showingAdvisor: $showingAdvisor,
                    onDismiss: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showingFloatingMenu = false
                        }
                    }
                )
            )
        }
    }
}

// MARK: - 自定义导航栏
struct CustomNavigationBar: View {
    let deviceInfo: DeviceInfo
    @Binding var showingProfile: Bool
    @Binding var showingDeviceManagement: Bool
    
    var body: some View {
        HStack {
            // 左侧头像 - 添加点击手势
            Button(action: {
                showingProfile = true
            }) {
                AsyncImage(url: Bundle.main.url(forResource: "user_avatar", withExtension: "png")) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Circle()
                        .fill(Color(red: 0.84, green: 0.8, blue: 0.98))
                        .overlay(
                            Image(systemName: "person.fill")
                                .foregroundColor(Color(red: 0.34, green: 0.16, blue: 0.37))
                        )
                }
                .frame(width: 52, height: 51)
                .clipShape(Circle())
            }
            
            Spacer()
            
            // 右侧设备信息 - 添加点击手势
            Button(action: {
                showingDeviceManagement = true
            }) {
                HStack(spacing: 12) {
                    // 电池信息
                    HStack(spacing: 6) {
                        // 电池图标
                        ZStack {
                            RoundedRectangle(cornerRadius: 2)
                                .stroke(Color(red: 0.34, green: 0.16, blue: 0.37), lineWidth: 1)
                                .frame(width: 18, height: 9)
                            
                            // 电池正极
                            Rectangle()
                                .fill(Color(red: 0.34, green: 0.16, blue: 0.37))
                                .frame(width: 2, height: 4)
                                .offset(x: 10)
                            
                            // 电池电量
                            if deviceInfo.batteryLevel > 0 {
                                RoundedRectangle(cornerRadius: 1)
                                    .fill(Color(red: 0.34, green: 0.16, blue: 0.37))
                                    .frame(width: CGFloat(deviceInfo.batteryLevel) * 16 / 100, height: 7)
                                    .offset(x: -1)
                            }
                        }
                        
                        // 电量百分比
                        Text("\(deviceInfo.batteryLevel)%")
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(Color(red: 0.34, green: 0.16, blue: 0.37))
                    }
                    
                    // 手表图标
                    Image(systemName: deviceInfo.isConnected ? "applewatch" : "applewatch.slash")
                        .foregroundColor(Color(red: 0.34, green: 0.16, blue: 0.37))
                        .font(.system(size: 18))
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.white)
    }
}

// MARK: - 消息通知区域
struct MessageNotificationView: View {
    @State private var showNotification = true
    @State private var showingHealthApps = false
    
    var body: some View {
        VStack(spacing: 16) {
            
            // 消息提示卡片
            if showNotification {
                VStack(spacing: 0) {
                    // 顶部：标题和关闭按钮
                    HStack {
                        Text("Good morning, Jessica.")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.black)
                        
                        Spacer()
                        
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                showNotification = false
                            }
                        }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Color(red: 0.67, green: 0.58, blue: 0.95))
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 12)
                    
                    // 消息内容
                    VStack(alignment: .leading, spacing: 8) {
                        Text("You have already linked your Apple Health data. Would you like to proceed with linking your Google Fit data for more comprehensive health tracking?")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(Color(red: 0.24, green: 0.24, blue: 0.24))
                            .lineSpacing(2)
                            .multilineTextAlignment(.leading)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    
                    // 操作按钮
                    HStack(spacing: 12) {
                        // 取消按钮
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                showNotification = false
                            }
                        }) {
                            HStack {
                                Spacer()
                                Text("Cancel")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(Color(red: 0.67, green: 0.58, blue: 0.95))
                                Spacer()
                            }
                            .frame(height: 42)
                            .background(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.clear, lineWidth: 0)
                            )
                            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                        }
                        
                        // 继续按钮
                        Button(action: {
                            showingHealthApps = true
                        }) {
                            HStack {
                                Spacer()
                                Text("Continue")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.white)
                                Spacer()
                            }
                            .frame(height: 42)
                            .background(Color(red: 0.67, green: 0.58, blue: 0.95))
                            .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                    .padding(.top, 12)
                }
                .background(Color.white)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(red: 0.9, green: 0.91, blue: 0.92), lineWidth: 1)
                )
                .padding(.top, 22)
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
            }
            
        }
        .sheet(isPresented: $showingHealthApps) {
            HealthAppsView()
        }
    }
}

// MARK: - 健康概要区域
struct HealthSummarySection: View {
    let healthData: [HealthSummary]
    @Binding var showingFloatingMenu: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            // 标题区域
            HStack {
                Text("Abstract")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.black)
                
                Spacer()
                
                Button(action: {}) {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 18))
                        .foregroundColor(.black)
                        .rotationEffect(.degrees(90))
                }
            }
            
            // 健康指标卡片 - 垂直排列四个卡片
            VStack(spacing: 16) {
                ForEach(healthData.indices, id: \.self) { index in
                    HealthSummaryCard(data: healthData[index])
                }
            }
            
            // 右下角加号按钮
            HStack {
                Spacer()
                
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showingFloatingMenu.toggle()
                    }
                }) {
                    Image(systemName: "plus")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Color(red: 0.4, green: 0.26, blue: 0.65))
                        .frame(width: 44, height: 44)
                        .background(Color(red: 0.84, green: 0.8, blue: 0.98))
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
                }
            }
        }
    }
}

// MARK: - 健康概要卡片
struct HealthSummaryCard: View {
    let data: HealthSummary
    
    var body: some View {
        HStack(spacing: 16) {
            // 左边图标
            Image(systemName: data.icon)
                .font(.system(size: 30))
                .foregroundColor(Color(red: 0.60, green: 0.39, blue: 0.95))
                .frame(width: 40, height: 40)
            
            // 中间内容区域 - 垂直布局
            VStack(alignment: .leading, spacing: 4) {
                // 标题
                Text(data.type.rawValue)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(Color(red: 0.34, green: 0.16, blue: 0.37))
                
                // 数值
                HStack(spacing: 4) {
                    Text(data.value)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(Color(red: 0.34, green: 0.16, blue: 0.37))
                    
                    if !data.unit.isEmpty {
                        Text(data.unit)
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(Color(red: 0.34, green: 0.16, blue: 0.37))
                    }
                }
                
                // 状态
                Text(data.status.rawValue)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(Color(red: 0.34, green: 0.16, blue: 0.37))
            }
            
            Spacer()
            
            // 右边区域 - 图表和时间
            VStack(alignment: .trailing, spacing: 8) {
                // 右上角时间
                Text(data.time)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(Color(red: 0.34, green: 0.16, blue: 0.37))
                
                Spacer()
                
                // 图表（如果有的话）
                if let chartImage = data.chartImage {
                    AsyncImage(url: Bundle.main.url(forResource: chartImage, withExtension: "png")) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } placeholder: {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.gray.opacity(0.2))
                    }
                    .frame(width: 75, height: 40)
                }
            }
        }
        .padding(16)
        .frame(height: 96)
        .background(Color(red: 0.97, green: 0.96, blue: 1.0))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
    }
}

// MARK: - 椭圆形测试数值卡片区域
struct TestValueCardsSection: View {
    let testValues = TestValue.sampleData
    
    var body: some View {
        // 圆角矩形容器带阴影
        ZStack {
            // 圆角矩形背景
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(red: 0.97, green: 0.96, blue: 1.0))
                .frame(width: 350, height: 112)
                .shadow(color: .black.opacity(0.16), radius: 8, x: 0, y: 2)
            
            // 5个测试数值卡片
            HStack(spacing: 8) {
                ForEach(testValues.indices, id: \.self) { index in
                    TestValueCard(testValue: testValues[index])
                }
            }
            .padding(.horizontal, 13)
        }
        .frame(height: 112)
    }
}

// MARK: - 单个椭圆形测试数值卡片
struct TestValueCard: View {
    let testValue: TestValue
    
    var body: some View {
        VStack(spacing: 6) {
            // 图标
            Image(systemName: testValue.icon)
                .font(.system(size: 20))
                .foregroundColor(Color(red: 0.60, green: 0.39, blue: 0.95))
                .frame(height: 20)
            
            // 状态指示器（椭圆形线图，有边框）
            ZStack {
                // 椭圆背景（透明）
                RoundedRectangle(cornerRadius: 3)
                    .stroke(Color(red: 0.84, green: 0.80, blue: 0.98), lineWidth: 1)
                    .frame(width: 59, height: 33)
                
                // 中间两条横线（表示正常范围）
                VStack(spacing: 12) {
                    Rectangle()
                        .fill(Color(red: 0.34, green: 0.16, blue: 0.37))
                        .frame(width: 59, height: 3)
                    
                    Rectangle()
                        .fill(Color(red: 0.34, green: 0.16, blue: 0.37))
                        .frame(width: 59, height: 3)
                }
                
                // 状态圆圈（空心）
                Circle()
                    .stroke(testValue.isNormal ? Color(red: 0.13, green: 0.95, blue: 0.10) : Color(red: 0.10, green: 0.27, blue: 0.95), lineWidth: 1)
                    .frame(width: 7, height: 7)
                    .offset(x: testValue.indicatorPosition, y: testValue.verticalPosition)
            }
            
            VStack {
                // 数值
                Text(testValue.value)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(Color(red: 0.34, green: 0.16, blue: 0.37))
                
                // 单位
                Text(testValue.unit)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(Color(red: 0.34, green: 0.16, blue: 0.37))
            }
        }
        .frame(width: 59, height: 80)
        // 移除了背景色、圆角和阴影
    }
}

// MARK: - 测试数值数据模型
struct TestValue {
    let type: TestType
    let value: String
    let unit: String
    let isNormal: Bool
    let indicatorPosition: CGFloat // 圆圈在椭圆中的水平位置
    let verticalPosition: CGFloat // 圆圈在椭圆中的垂直位置（负数为上方，正数为下方）
    
    var icon: String {
        return type.iconName
    }
    
    enum TestType {
        case heartRate
        case bloodPressure
        case bloodSugar
        case temperature
        case bloodOxygen
        
        var iconName: String {
            switch self {
            case .heartRate:
                return "heart.fill"
            case .bloodPressure:
                return "drop.fill"
            case .bloodSugar:
                return "drop.triangle.fill"
            case .temperature:
                return "thermometer"
            case .bloodOxygen:
                return "lungs.fill"
            }
        }
    }
    
    static let sampleData: [TestValue] = [
        TestValue(type: .heartRate, value: "76", unit: "ms", isNormal: true, indicatorPosition: 0, verticalPosition: -8),
        TestValue(type: .heartRate, value: "59", unit: "bpm", isNormal: true, indicatorPosition: 5, verticalPosition: -5),
        TestValue(type: .bloodPressure, value: "14.3", unit: "BrPM", isNormal: true, indicatorPosition: -8, verticalPosition: -3),
        TestValue(type: .bloodSugar, value: "98", unit: "%", isNormal: true, indicatorPosition: 3, verticalPosition: -6),
        TestValue(type: .temperature, value: "34.5", unit: "℃", isNormal: false, indicatorPosition: -15, verticalPosition: 12)
    ]
}

#Preview {
    HomeView()
}

// MARK: - 浮动操作菜单
struct FloatingActionMenu: View {
    @Binding var isShowing: Bool
    @Binding var showingAdvisor: Bool
    let onDismiss: () -> Void
    @State private var showingVitalSigns = false
    @State private var showingAddTag = false
    @State private var showingMeditation = false
    
    var body: some View {
        ZStack {
            // 背景遮罩
            if isShowing {
                Color.black.opacity(0.6)
                    .ignoresSafeArea()
                    .transition(.opacity)
            }
            
            // 浮动菜单
            if isShowing {
                VStack {
                    Spacer()
                    
                    HStack {
                        Spacer()
                        
                        VStack(spacing: 16) {
                            // 菜单选项
                            FloatingMenuItem(
                                title: "Vital signs",
                                icon: "pencil.and.wrench",
                                action: {
                                    showingVitalSigns = true
                                    onDismiss()
                                }
                            )
                            
                            FloatingMenuItem(
                                title: "Add a tag",
                                icon: "tag",
                                action: {
                                    showingAddTag = true
                                    onDismiss()
                                }
                            )
                            
                            FloatingMenuItem(
                                title: "Advisor",
                                icon: "stethoscope",
                                action: {
                                    showingAdvisor = true
                                    onDismiss()
                                }
                            )
                            
                            FloatingMenuItem(
                                title: "Meditation",
                                icon: "figure.mind.and.body",
                                action: {
                                    showingMeditation = true
                                    onDismiss()
                                }
                            )
                            
                            // 关闭按钮
                            HStack {
                                Spacer()
                                
                                Button(action: onDismiss) {
                                    Image(systemName: "xmark")
                                        .font(.system(size: 20, weight: .medium))
                                        .foregroundColor(.white)
                                        .frame(width: 44, height: 44)
                                        .background(Color.white.opacity(0.2))
                                        .clipShape(Circle())
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 100) // 为底部导航栏留出空间
                    }
                }
                .transition(.asymmetric(
                    insertion: .scale(scale: 0.8).combined(with: .opacity),
                    removal: .scale(scale: 0.8).combined(with: .opacity)
                ))
            }
        }
        .animation(.easeInOut(duration: 0.3), value: isShowing)
        .sheet(isPresented: $showingVitalSigns) {
            VitalSignsView()
        }
        .sheet(isPresented: $showingAddTag) {
            AddTagView()
        }
        .sheet(isPresented: $showingAdvisor) {
            AdvisorView()
        }
        .sheet(isPresented: $showingMeditation) {
            MeditationView()
        }
    }
}

// MARK: - 浮动菜单项
struct FloatingMenuItem: View {
    let title: String
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Spacer()
                
                HStack(spacing: 12) {
                    // 标题（左边）
                    Text(title)
                        .font(.system(size: 18, weight: .regular))
                        .foregroundColor(.white)
                        .frame(width: 120, alignment: .leading)
                    
                    // 图标（右边）
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.white)
                        .frame(width: 43, height: 43)
                        .background(Color.white.opacity(0.1))
                        .clipShape(Circle())
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }
        }
    }
}

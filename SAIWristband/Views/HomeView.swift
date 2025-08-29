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
    @EnvironmentObject var appState: AppState
    @Environment(\.colorScheme) private var colorScheme
    
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
                        .background(AppTheme.separator)
                    
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
            .background(AppTheme.background(colorScheme))
            .navigationBarHidden(true)
            .sheet(isPresented: $showingProfile) {
                ProfileView()
                    .environmentObject(appState)
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
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        HStack {
            // 左侧头像 - 添加点击手势
            Button(action: {
                showingProfile = true
            }) {
                Image("user_avatar")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .clipShape(Circle())
                    .frame(width: 52, height: 51)
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
                                .stroke(colorScheme == .dark ? .white : AppTheme.accent, lineWidth: 1)
                                .frame(width: 18, height: 9)
                            
                            // 电池正极
                            Rectangle()
                                .fill(colorScheme == .dark ? .white : AppTheme.accent)
                                .frame(width: 2, height: 4)
                                .offset(x: 10)
                            
                            // 电池电量
                            if deviceInfo.batteryLevel > 0 {
                                RoundedRectangle(cornerRadius: 1)
                                    .fill(colorScheme == .dark ? .white : AppTheme.accent)
                                    .frame(width: CGFloat(deviceInfo.batteryLevel) * 16 / 100, height: 7)
                                    .offset(x: -1)
                            }
                        }
                        
                        // 电量百分比
                        Text("\(deviceInfo.batteryLevel)%")
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(colorScheme == .dark ? .white : AppTheme.accent)
                    }
                    
                    // 手表图标
                    Image(systemName: deviceInfo.isConnected ? "applewatch" : "applewatch.slash")
                        .foregroundColor(colorScheme == .dark ? .white : AppTheme.accent)
                        .font(.system(size: 18))
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(AppTheme.cardBackground(colorScheme))
        .glassBackground(RoundedRectangle(cornerRadius: 0))
    }
}

// MARK: - 消息通知区域
struct MessageNotificationView: View {
    @State private var showNotification = true
    @State private var showingHealthApps = false
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(spacing: 16) {
            
            // 消息提示卡片
            if showNotification {
                VStack(spacing: 0) {
                    // 顶部：标题和关闭按钮
                    HStack {
                        Text("Good morning, Jessica.")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(AppTheme.primaryText(colorScheme))
                        
                        Spacer()
                        
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                showNotification = false
                            }
                        }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(AppTheme.accent)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 12)
                    
                    // 消息内容
                    VStack(alignment: .leading, spacing: 8) {
                        Text("You have already linked your Apple Health data. Would you like to proceed with linking your Google Fit data for more comprehensive health tracking?")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(AppTheme.secondaryText(colorScheme))
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
                            .background(AppTheme.cardBackground(colorScheme))
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
                            .background(AppTheme.accent)
                            .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                    .padding(.top, 12)
                }
                .background(AppTheme.cardBackground(colorScheme))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(AppTheme.separator, lineWidth: 1)
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
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(spacing: 16) {
            // 标题区域
            HStack {
                Text("Abstract")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(AppTheme.primaryText(colorScheme))
                
                Spacer()
                
                // 右上角图片
                Button(action: {}) {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 18))
                        .foregroundColor(AppTheme.primaryText(colorScheme))
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
                        .foregroundColor(AppTheme.accent)
                        .frame(width: 44, height: 44)
                        .background(AppTheme.accent.opacity(0.18))
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
    @Environment(\.colorScheme) private var colorScheme
    @State private var showingBloodPressureSync = false
    @State private var showingBloodGlucose = false
    @State private var showingECGHistory = false
    @State private var showingHeartRhythmHistory = false
    @State private var showingBloodOxygenHistory = false
    
    // 计算属性：根据数据类型获取对应的图片名称
    private var imageName: String {
        switch data.type {
        case .heartRate:
            return "Image4"      // 第一行
        case .bloodPressure:
            return "Image5"      // 第二行
        case .bloodSugar:
            return "Image6"      // 第三行
        case .bloodOxygen:
            return "Image7"      // 第四行
        case .ecg:
            return "Image27"      // 第四行
        }
    }
    
    var body: some View {
        ZStack {
            HStack(spacing: 12) {
                // 左边图标
                    Image(data.icon)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 36, height: 36)
                
                // 中间内容区域 - 垂直布局
                VStack(alignment: .leading, spacing: 4) {
                    // 标题 - 使用更小的字体并限制行数
                    Text(data.type.rawValue)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(AppTheme.primaryText(colorScheme))
                        .lineLimit(2)
                        .minimumScaleFactor(0.7)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // 数值
                    HStack(spacing: 4) {
                        Text(data.value)
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(AppTheme.primaryText(colorScheme))
                        
                        if !data.unit.isEmpty {
                            Text(data.unit)
                                .font(.system(size: 12, weight: .regular))
                                .foregroundColor(AppTheme.secondaryText(colorScheme))
                        }
                    }
                    
                    // 状态
                    Text(data.status.rawValue)
                        .font(.system(size: 11, weight: .regular))
                        .foregroundColor(AppTheme.secondaryText(colorScheme))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer()
                
                // 右边区域 - 图表根据行数显示不同图片
                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 140, height: 60)
            }
            .overlay(
                // 右上角时间
                VStack {
                    HStack {
                        Spacer()
                        Text(data.time)
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(AppTheme.secondaryText(colorScheme))
                            .padding(.top, -8)
                            .padding(.trailing, -8)
                    }
                    Spacer()
                }
            )
        }
        .padding(16)
        .frame(height: 96)
        .background(AppTheme.elevatedCardBackground(colorScheme))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
        .onTapGesture {
            // 根据数据类型决定跳转到哪个视图
            switch data.type {
            case .heartRate:
                showingHeartRhythmHistory = true
            case .bloodPressure:
                showingBloodPressureSync = true
            case .bloodSugar:
                showingBloodGlucose = true
            case .bloodOxygen:
                showingBloodOxygenHistory = true
            case .ecg:
                showingECGHistory = true
            default:
                break
            }
        }
        .sheet(isPresented: $showingBloodPressureSync) {
            BloodPressureSyncView()
        }
        .sheet(isPresented: $showingBloodGlucose) {
            BloodGlucoseView()
        }
        .sheet(isPresented: $showingECGHistory) {
            ECGHistoryView()
        }
        .sheet(isPresented: $showingHeartRhythmHistory) {
            HeartRhythmHistoryView()
        }
        .sheet(isPresented: $showingBloodOxygenHistory) {
            BloodOxygenHistoryView()
        }
    }
}

// MARK: - 椭圆形测试数值卡片区域
struct TestValueCardsSection: View {
    let testValues = TestValue.sampleData
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        // 圆角矩形容器带阴影
        ZStack {
            // 圆角矩形背景
            RoundedRectangle(cornerRadius: 20)
                .fill(AppTheme.elevatedCardBackground(colorScheme))
                .frame(height: 112)
                .shadow(color: .black.opacity(0.16), radius: 8, x: 0, y: 2)
            
            // 5个测试数值卡片
            HStack(spacing: 15) {
                ForEach(testValues.indices, id: \.self) { index in
                    TestValueCard(testValue: testValues[index])
                }
            }
        }
        .frame(height: 112)
    }
}

// MARK: - 单个椭圆形测试数值卡片
struct TestValueCard: View {
    let testValue: TestValue
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(spacing: 6) {
            // 图标
            Image(testValue.icon)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .clipShape(Circle())
                .frame(width: 20, height: 20)
            
            // 状态指示器（椭圆形线图，有边框）
            ZStack {
                // 椭圆背景（透明）
                RoundedRectangle(cornerRadius: 3)
                    .stroke(AppTheme.accent.opacity(0.3), lineWidth: 1)
                    .frame(width: 59, height: 33)
                
                // 中间两条横线（表示正常范围）
                VStack(spacing: 12) {
                    Rectangle()
                        .fill(AppTheme.accent)
                        .frame(width: 59, height: 3)
                    
                    Rectangle()
                        .fill(AppTheme.accent)
                        .frame(width: 59, height: 3)
                }
                
                // 状态圆圈（空心）
                Circle()
                    .stroke(testValue.isNormal ? Color.green : AppTheme.accent, lineWidth: 1)
                    .frame(width: 7, height: 7)
                    .offset(x: testValue.indicatorPosition, y: testValue.verticalPosition)
            }
            
            VStack {
                // 数值
                Text(testValue.value)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(AppTheme.primaryText(colorScheme))
                
                // 单位
                Text(testValue.unit)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(AppTheme.secondaryText(colorScheme))
            }
        }
        .frame(width: 59, height: 80)
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
                return "Icon heart circle bolt"
            case .bloodPressure:
                return "Icon heart"
            case .bloodSugar:
                return "Icon bloodtype"
            case .temperature:
                return "Icon device thermostat"
            case .bloodOxygen:
                return "Icon lungs"
            }
        }
    }
    
    static let sampleData: [TestValue] = [
        TestValue(type: .heartRate, value: "76", unit: "ms", isNormal: true, indicatorPosition: 0, verticalPosition: -8),
        TestValue(type: .bloodPressure, value: "59", unit: "bpm", isNormal: true, indicatorPosition: 5, verticalPosition: -5),
        TestValue(type: .bloodOxygen, value: "14.3", unit: "BrPM", isNormal: true, indicatorPosition: -8, verticalPosition: -3),
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
                                icon: "pencil.slash",
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
    @Environment(\.colorScheme) private var colorScheme
    
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
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }
        }
    }
}

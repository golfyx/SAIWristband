//
//  BloodGlucoseView.swift
//  SAIWristband
//
//  Created by golfy xiong on 2025/8/25.
//

import SwiftUI
import Charts

struct BloodGlucoseView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    
    // 模拟血糖数据 - 按照设计稿精确数值
    @State private var glucoseData: [GlucoseDataPoint] = [
        GlucoseDataPoint(time: "00:00", value: 6.5),
        GlucoseDataPoint(time: "03:00", value: 5.8),
        GlucoseDataPoint(time: "06:00", value: 7.1),
        GlucoseDataPoint(time: "09:00", value: 8.5),
        GlucoseDataPoint(time: "12:00", value: 6.9),
        GlucoseDataPoint(time: "15:00", value: 5.4),
        GlucoseDataPoint(time: "16:31", value: 7.8),
        GlucoseDataPoint(time: "21:00", value: 6.1)
    ]
    
    // 扫描弹框状态
    @State private var showingScanSheet = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 自定义导航栏
                CustomBloodGlucoseNavigationBar(onBack: {
                    dismiss()
                })
                
                // 分割线
                Divider()
                    .background(Color.gray.opacity(0.3))
                
                // 内容区域
                ScrollView {
                    VStack(spacing: 32) {
                        // 最近24小时记录
                        Last24HoursSection(glucoseData: glucoseData)
                            .padding(.horizontal, 20)
                        
                        // 扫描按钮
                        ScanButtonSection {
                            showingScanSheet = true
                        }
                        
                        // 完成度
                        CompletionSection()
                    }
                    .padding(.top, 24)
                    .frame(maxWidth: .infinity)
                }
            }
//            .background(AppTheme.background(colorScheme))
            .navigationBarHidden(true)
            .sheet(isPresented: $showingScanSheet) {
                ScanSheetView()
                    .presentationDetents([.height(450)])
                    .presentationDragIndicator(.visible)
            }
        }
    }
}

// MARK: - 自定义导航栏
struct CustomBloodGlucoseNavigationBar: View {
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
            Text("Blood Glucose testing")
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

// MARK: - 最近24小时记录部分
struct Last24HoursSection: View {
    let glucoseData: [GlucoseDataPoint]
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(spacing: 24) {
            // 标题
            Text("The last 24 hours")
                .font(.custom("Noto Sans JP", size: 15))
                .fontWeight(.regular)
                .foregroundColor(colorScheme == .dark ? Color(hex: "9A1AF2") : Color(hex: "9A1AF2"))
                .frame(maxWidth: .infinity)
            
            // 结果部分
            HStack(spacing: 0) {
                // 左侧：时间范围百分比
                VStack(alignment: .center, spacing: 8) {
                    Text("Time within the range")
                        .font(.custom("Noto Sans JP", size: 12))
                        .fontWeight(.regular)
                        .foregroundColor(colorScheme == .dark ? Color(hex: "FFFFFF") : Color(hex: "785B97"))
                    
                    Text("100%")
                        .font(.custom("Noto Sans JP", size: 18))
                        .fontWeight(.bold)
                        .foregroundColor(colorScheme == .dark ? Color(hex: "9A1AF2") : Color(hex: "4D0B6F"))
                }
                
                Spacer()
                
                // 中间：最后读数
                VStack(alignment: .center, spacing: 8) {
                    Text("The last reading")
                        .font(.custom("Noto Sans JP", size: 12))
                        .fontWeight(.regular)
                        .foregroundColor(colorScheme == .dark ? Color(hex: "FFFFFF") : Color(hex: "785B97"))
                    
                    Text("17:44")
                        .font(.custom("Noto Sans JP", size: 18))
                        .fontWeight(.bold)
                        .foregroundColor(colorScheme == .dark ? Color(hex: "9A1AF2") : Color(hex: "4D0B6F"))
                }
                
                Spacer()
                
                // 右侧：平均值
                VStack(alignment: .center, spacing: 8) {
                    Text("Average")
                        .font(.custom("Noto Sans JP", size: 13))
                        .fontWeight(.regular)
                        .foregroundColor(colorScheme == .dark ? Color(hex: "FFFFFF") : Color(hex: "785B97"))
                    
                    Text("6 mmol/L")
                        .font(.custom("Noto Sans JP", size: 21))
                        .fontWeight(.regular)
                        .foregroundColor(colorScheme == .dark ? Color(hex: "9A1AF2") : Color(hex: "4D0B6F"))
                }
            }
            
            // 折线图
            GlucoseChartView(glucoseData: glucoseData)
        }
    }
}

// MARK: - 血糖折线图
struct GlucoseChartView: View {
    let glucoseData: [GlucoseDataPoint]
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(spacing: 0) {
            // 单位标签
            HStack {
                Text("mmol/L")
                    .font(.custom("Noto Sans JP", size: 10))
                    .fontWeight(.regular)
                    .foregroundColor(colorScheme == .dark ? Color(hex: "9A1AF2") : Color(hex: "572D5F"))
                
                Spacer()
            }
            .padding(.bottom, 8)
            
            // 主图表区域
            HStack(spacing: 0) {
                // 左侧Y轴标签
                VStack(alignment: .trailing, spacing: 10) {
                    ForEach([21, 18, 15, 12, 9, 6, 3, 0], id: \.self) { value in
                        Text("\(value)")
                            .font(.custom("Noto Sans JP", size: 12))
                            .fontWeight(.regular)
                            .foregroundColor(colorScheme == .dark ? Color(hex: "9A1AF2") : Color(hex: "572D5F"))
                        
                        if value != 0 {
                            Spacer()
                        }
                    }
                }
                .frame(width: 28)
                
                // 图表主体
                GeometryReader { geometry in
                    let chartWidth = geometry.size.width
                    let chartHeight = geometry.size.height
                    
                    ZStack {
                        // 背景紫色区域
                        Rectangle()
                            .fill(colorScheme == .dark ? Color(hex: "F7E6FF").opacity(0.57) : Color(hex: "E5CDEF").opacity(0.57))
                        
                        // 横向网格线 - 对应Y轴刻度
                        VStack(spacing: 0) {
                            ForEach([21, 18, 15, 12, 9, 6, 3], id: \.self) { _ in
                                Divider()
                                    .background(colorScheme == .dark ? Color(hex: "9A1AF2") : Color(hex: "B393CA"))
                                
                                Spacer()
                            }
                        }
                        
                        // 数据点和折线
                        if !glucoseData.isEmpty {
                            // 折线
                            Path { path in
                                let maxValue: Double = 21.0
                                let minValue: Double = 0.0
                                let valueRange = maxValue - minValue
                                
                                // 根据实际数据点时间计算X坐标
                                let timePositions = calculateTimePositions(data: glucoseData, chartWidth: chartWidth)
                                
                                if let firstTimePos = timePositions.first {
                                    let firstPoint = glucoseData[0]
                                    let firstY = chartHeight * (1 - (firstPoint.value - minValue) / valueRange)
                                    path.move(to: CGPoint(x: firstTimePos, y: firstY))
                                    
                                    for index in 1..<glucoseData.count {
                                        let point = glucoseData[index]
                                        let y = chartHeight * (1 - (point.value - minValue) / valueRange)
                                        path.addLine(to: CGPoint(x: timePositions[index], y: y))
                                    }
                                }
                            }
                            .stroke(Color(red: 0.30, green: 0.04, blue: 0.44), lineWidth: 2)
                            
                            // 数据点圆圈
                            ForEach(Array(glucoseData.enumerated()), id: \.element.id) { index, point in
                                let maxValue: Double = 21.0
                                let minValue: Double = 0.0
                                let valueRange = maxValue - minValue
                                let timePositions = calculateTimePositions(data: glucoseData, chartWidth: chartWidth)
                                
                                if index < timePositions.count {
                                    let y = chartHeight * (1 - (point.value - minValue) / valueRange)
                                    
                                    Circle()
                                        .fill(Color(red: 0.30, green: 0.04, blue: 0.44))
                                        .frame(width: 6, height: 6)
                                        .position(x: timePositions[index], y: y)
                                }
                            }
                        }
                    }
                }
                .frame(height: 300) // 固定图表高度
            }
            
            // 时间轴区域
            HStack(spacing: 0) {
                // 左侧占位（对应Y轴标签宽度）
                Color.clear
                    .frame(width: 28)
                
                // 时间轴主体
                GeometryReader { geometry in
                    
                    VStack(spacing: 0) {
                        // 刻度线 - 24小时
                        HStack(spacing: 0) {
                            ForEach(0..<25) { hour in
                                VStack(spacing: 0) {
                                    if hour % 3 == 0 {
                                        // 每3小时长竖线
                                        Rectangle()
                                            .fill(Color(red: 0.70, green: 0.58, blue: 0.79))
                                            .frame(width: 1, height: 8)
                                    } else {
                                        // 每1小时短竖线
                                        Rectangle()
                                            .fill(Color(red: 0.70, green: 0.58, blue: 0.79))
                                            .frame(width: 0.5, height: 4)
                                        
                                        Spacer()
                                            .frame(height: 4)
                                    }
                                }
                                
                                if hour < 24 {
                                    Spacer()
                                }
                            }
                        }
                        .frame(height: 8)
                        
                        // 时间标签 - 每3小时显示
                        HStack(spacing: 0) {
                            ForEach(0..<9) { index in
                                let hour = index * 3
                                Text(String(format: "%02d:00", hour))
                                    .font(.custom("Noto Sans JP", size: 11))
                                    .fontWeight(.regular)
                                    .foregroundColor(colorScheme == .dark ? Color(hex: "9A1AF2") : Color(hex: "572D5F"))
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        .padding(.top, 4)
                        
                    }
                }
                .frame(height: 40)
            }
            .padding(.top, 12)
        }
    }
    
    // 计算时间在图表中的X坐标位置
    private func calculateTimePositions(data: [GlucoseDataPoint], chartWidth: CGFloat) -> [CGFloat] {
        guard !data.isEmpty else { return [] }
        
        var positions: [CGFloat] = []
        
        for point in data {
            // 解析时间字符串 (HH:mm格式)
            let timeComponents = point.time.split(separator: ":")
            if timeComponents.count == 2,
               let hours = Int(timeComponents[0]),
               let minutes = Int(timeComponents[1]) {
                
                // 转换为分钟总数
                let totalMinutes = hours * 60 + minutes
                
                // 一天总共1440分钟，计算在图表中的位置比例
                let position = CGFloat(totalMinutes) / 1440.0 * chartWidth
                positions.append(position)
            }
        }
        
        return positions
    }
}

// MARK: - 扫描按钮部分
struct ScanButtonSection: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Spacer()
                
                // 左侧图标
                Image(systemName: "qrcode.viewfinder")
                    .font(.system(size: 21, weight: .medium))
                    .foregroundColor(.white)
                    .frame(width: 21, height: 21)
                
                // 右侧文字
                Text("Scan")
                    .font(.custom("Montserrat", size: 14))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Spacer()
            }
            .padding(.vertical, 8)
            .frame(width: 120, height: 32)
            .background(Color(red: 0.60, green: 0.10, blue: 0.95))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.08), radius: 0, x: 0, y: 0)
        }
        .buttonStyle(PlainButtonStyle())
    }
}



// MARK: - 完成度部分
struct CompletionSection: View {
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(spacing: 16) {
            // 进度条
            HStack(spacing: 8) {
                ForEach(0..<7) { index in
                    if index < 4 {
                        // 已完成的部分
                        RoundedRectangle(cornerRadius: 5)
                            .fill(Color(red: 0.18, green: 0.82, blue: 0.24))
                            .frame(width: 46, height: 10)
                    } else {
                        // 未完成的部分
                        RoundedRectangle(cornerRadius: 5)
                            .fill(Color(red: 0.76, green: 0.76, blue: 0.76))
                            .frame(width: 46, height: 10)
                    }
                }
            }
            .padding(.top, 3)
            
            // 文字提示
            HStack(spacing: 8) {
                Spacer()
                Text("There are still")
                    .font(.custom("Noto Sans JP", size: 14))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("5")
                    .font(.custom("Roboto Mono", size: 32))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("days until the sensor fails")
                    .font(.custom("Noto Sans JP", size: 14))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Spacer()
            }
            .padding(.horizontal, 3)
            .padding(.bottom, 20)
        }
        .padding(.vertical, 4)
        .frame(width: .infinity)
        .background(colorScheme == .dark ? Color(hex: "4D4D4D") : Color(hex: "4D4D4D"))
    }
}

// MARK: - 血糖数据点模型
struct GlucoseDataPoint: Identifiable {
    let id = UUID()
    let time: String
    let value: Double
}

// MARK: - 扫描弹框视图
struct ScanSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var nfcScanner = NFCScanner()
    @State private var scannedDeviceData: GlucoseDeviceData?
    
    var body: some View {
        VStack(spacing: 0) {
            // 弹框内容
            VStack(spacing: 20) {
                // 标题
                Text("Ready to scan")
                    .font(.system(size: 24, weight: .regular))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.top, 20)
                
                // 描述文字
                Text("Hold the top of the iPhone near the device")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                
                // 扫描图片区域
                ZStack {
                    // 背景圆形
                    Circle()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: 185, height: 185)
                    
                    if nfcScanner.isScanning {
                        // 扫描动画
                        VStack(spacing: 16) {
                            ProgressView()
                                .scaleEffect(1.5)
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            
                            Text("Scanning...")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white)
                        }
                    } else if scannedDeviceData != nil {
                        // 扫描成功图标
                        VStack(spacing: 12) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 60, weight: .light))
                                .foregroundColor(.green)
                            
                            Text("Scan Successful")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.green)
                        }
                    } else {
                        // 扫描图标
                        Image(systemName: "iphone.radiowaves.left.and.right")
                            .font(.system(size: 80, weight: .light))
                            .foregroundColor(.white)
                    }
                }
                .padding(.top, 10)
                
                // 扫描状态和结果显示
                if !nfcScanner.scanError.isEmpty {
                    Text(nfcScanner.scanError)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
                
                if let deviceData = scannedDeviceData {
                    VStack(spacing: 8) {
                        Text("Device ID: \(deviceData.deviceId)")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                        
                        if let glucoseValue = deviceData.glucoseValue {
                            Text("Glucose: \(String(format: "%.1f", glucoseValue)) mmol/L")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.green)
                        }
                        
                        if let batteryLevel = deviceData.batteryLevel {
                            Text("Battery: \(batteryLevel)%")
                                .font(.system(size: 12, weight: .regular))
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                    .padding(.horizontal, 20)
                }
                
                Spacer(minLength: 20)
                
                // 取消按钮
                Button(action: {
                    nfcScanner.stopScanning()
                    dismiss()
                }) {
                    Text(scannedDeviceData != nil ? "Done" : "Cancel")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 45)
                        .background(Color(red: 0.32, green: 0.32, blue: 0.32))
                        .cornerRadius(8)
                        .shadow(color: Color.black.opacity(0.16), radius: 8, x: 0, y: 2)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.35, green: 0.35, blue: 0.35),
                    Color(red: 0.14, green: 0.14, blue: 0.14)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .clipShape(
            RoundedRectangle(
                cornerRadius: 20,
                style: .continuous
            )
        )
        .overlay(
            RoundedRectangle(
                cornerRadius: 20,
                style: .continuous
            )
            .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
        .onAppear {
            // 弹框一打开就开始扫描
            nfcScanner.startScanning()
        }
        .onReceive(nfcScanner.$scannedData) { data in
            if !data.isEmpty {
                scannedDeviceData = nfcScanner.parseGlucoseData(data)
            }
        }
        .onReceive(nfcScanner.$scanError) { error in
            if !error.isEmpty && error != "Scan successful" {
                // 显示错误信息
            }
        }
    }
}

#Preview {
    BloodGlucoseView()
}

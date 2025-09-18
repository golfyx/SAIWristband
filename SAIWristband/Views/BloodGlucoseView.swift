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
    
    // NFC扫描器
    @StateObject private var nfcScanner = NFCScanner()
    
    // 趋势数据（持久化）
    @State private var glucoseData: [GlucoseDataPoint] = []
    
    // 弹框逻辑移除：不再显示测量结果弹框，直接更新趋势
    @State private var nfcScanCompleted = false
    
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
                        // 最近24小时记录（无数据时展示空态：--，图表无折线）
                        Last24HoursSection(glucoseData: glucoseData)
                            .padding(.horizontal, 20)
                        
                        // Measurement Button Section
                        VStack(spacing: 16) {
                            // Information text for real sensor mode
                            VStack(spacing: 8) {
                                Text("🏥 Abbott Sensor Reader")
                                    .font(.custom("Montserrat", size: 16))
                                    .fontWeight(.medium)
                                    .foregroundColor(AppTheme.primaryText(colorScheme))
                                
                                Text("Hold your iPhone near the Abbott FreeStyle Libre sensor to read glucose data")
                                    .font(.custom("Noto Sans JP", size: 12))
                                    .foregroundColor(AppTheme.secondaryText(colorScheme))
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 20)
                            }
                            
                            // Reading Mode Toggle
                            ReadingModeToggle(nfcScanner: nfcScanner)
                                .padding(.horizontal, 20)
                            
                            // Buttons Section
                            HStack(spacing: 16) {
                                // History Button
                                NavigationLink(destination: BloodGlucoseHistoryView()) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "list.bullet.clipboard")
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(.white)
                                        
                                        Text("History")
                                            .font(.custom("Montserrat", size: 13))
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)
                                    }
                                    .padding(.vertical, 8)
                                    .frame(width: 110, height: 32)
                                    .background(Color(red: 0.40, green: 0.10, blue: 0.85))
                                    .cornerRadius(16)
                                    .shadow(color: Color.black.opacity(0.08), radius: 0, x: 0, y: 0)
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                                // Measurement Button
                                ScanButtonSection {
                                    // Start NFC scanning
                                    nfcScanner.startScanning()
                                }
                            }
                        }
                        
                        // 完成度
                        CompletionSection()
                    }
                    .padding(.top, 24)
                    .frame(maxWidth: .infinity)
                }
            }
            .navigationBarHidden(true)
            .onReceive(nfcScanner.$glucoseReading) { reading in
                guard let reading = reading else { return }
                // 1) 将读取的当前值与历史值合并进趋势
                let merged = mergeGlucose(reading: reading)
                glucoseData = merged
                // 2) 本地持久化
                persistGlucoseData(merged)
                // 3) 重置一次性状态
                nfcScanCompleted = true
                nfcScanner.resetScanState()
            }
            .onAppear {
                // 启动仅加载本地缓存（无默认示例数据）
                glucoseData = loadPersistedGlucoseData()
                
                // 将现有数据迁移到历史存储中（如果还没有迁移的话）
                migrateExistingDataToHistory()
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
            // 标题（始终显示）
            Text("The last 24 hours")
                .font(.custom("Noto Sans JP", size: 15))
                .fontWeight(.regular)
                .foregroundColor(colorScheme == .dark ? Color(hex: "9A1AF2") : Color(hex: "9A1AF2"))
                .frame(maxWidth: .infinity)
            
            // 结果部分（无数据时显示 --）
            HStack(spacing: 0) {
                // 左侧：时间范围百分比
                VStack(alignment: .center, spacing: 8) {
                    Text("Time within the range")
                        .font(.custom("Noto Sans JP", size: 12))
                        .fontWeight(.regular)
                        .foregroundColor(colorScheme == .dark ? Color(hex: "FFFFFF") : Color(hex: "785B97"))
                    
                    Text(glucoseData.isEmpty ? "--" : "100%")
                        .font(.custom("Noto Sans JP", size: 18))
                        .fontWeight(.bold)
                        .foregroundColor(colorScheme == .dark ? Color(hex: "9A1AF2") : Color(hex: "4D0B6F"))
                }
                
                Spacer()
                
                // 中间：最后读数时间
                VStack(alignment: .center, spacing: 8) {
                    Text("The last reading")
                        .font(.custom("Noto Sans JP", size: 12))
                        .fontWeight(.regular)
                        .foregroundColor(colorScheme == .dark ? Color(hex: "FFFFFF") : Color(hex: "785B97"))
                    
                    Text(glucoseData.last?.time ?? "--")
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
                    
                    Text(glucoseData.isEmpty ? "--" : String(format: "%.1f mmol/L", computeAverage(glucoseData)))
                        .font(.custom("Noto Sans JP", size: 21))
                        .fontWeight(.regular)
                        .foregroundColor(colorScheme == .dark ? Color(hex: "9A1AF2") : Color(hex: "4D0B6F"))
                }
            }
            
            // 折线图（无数据时仅显示背景与网格，不绘制折线）
            GlucoseChartView(glucoseData: glucoseData)
        }
    }
}

// MARK: - 汇总计算
private func computeAverage(_ data: [GlucoseDataPoint]) -> Double {
    guard !data.isEmpty else { return 0 }
    let sum = data.reduce(0.0) { $0 + $1.value }
    return sum / Double(data.count)
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

// MARK: - Measurement Button Section
struct ScanButtonSection: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Spacer()
                
                // Left icon
                Image(systemName: "qrcode.viewfinder")
                    .font(.system(size: 21, weight: .medium))
                    .foregroundColor(.white)
                    .frame(width: 21, height: 21)
                
                // Right text
                Text("Measure")
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
struct GlucoseDataPoint: Identifiable, Codable {
    let id: UUID
    let time: String
    let value: Double
    let timestamp: Date
}

// MARK: - 本地持久化与合并逻辑
extension BloodGlucoseView {
    private func defaultSeedData() -> [GlucoseDataPoint] {
        let calendar = Calendar.current
        let now = Date()
        func make(_ hhmm: String, _ v: Double) -> GlucoseDataPoint {
            let comps = hhmm.split(separator: ":")
            var date = now
            if comps.count == 2, let h = Int(comps[0]), let m = Int(comps[1]) {
                date = calendar.date(bySettingHour: h, minute: m, second: 0, of: now) ?? now
                // 如果设置后的时间在未来，往回推一天，保证都是过去24小时内
                if date > now { date = calendar.date(byAdding: .day, value: -1, to: date) ?? now }
            }
            return GlucoseDataPoint(id: UUID(), time: hhmm, value: v, timestamp: date)
        }
        return [
            make("00:00", 6.5),
            make("03:00", 5.8),
            make("06:00", 7.1),
            make("09:00", 8.5),
            make("12:00", 6.9),
            make("15:00", 5.4),
            make("16:31", 7.8),
            make("21:00", 6.1)
        ]
    }
    
    private func mergeGlucose(reading: LibreGlucoseReading) -> [GlucoseDataPoint] {
        let now = Date()
        let cutoff = now.addingTimeInterval(-24 * 60 * 60) // 24小时前，用于显示
        var result: [GlucoseDataPoint] = glucoseData
        
        // 现有数据：先过滤到最近24小时（仅用于当前界面显示）
        result = result.filter { $0.timestamp >= cutoff }
        
        // 构造新数据点（历史 + 当前）
        var candidates: [GlucoseDataPoint] = []
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        
        // 历史记录
        for h in reading.glucoseHistory {
            let t = timeFormatter.string(from: h.timestamp)
            let dp = GlucoseDataPoint(id: UUID(), time: t, value: h.glucose, timestamp: h.timestamp)
            candidates.append(dp)
        }
        // 当前值
        if let cg = reading.currentGlucose {
            let t = timeFormatter.string(from: reading.timestamp)
            let dp = GlucoseDataPoint(id: UUID(), time: t, value: cg, timestamp: reading.timestamp)
            candidates.append(dp)
        }
        
        // 合并去重：以精确到分钟的时间戳作为键，保留较新的
        var keyed: [String: GlucoseDataPoint] = [:]
        let minuteFormatter = DateFormatter()
        minuteFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        for p in result { keyed[minuteFormatter.string(from: p.timestamp)] = p }
        for c in candidates {
            let key = minuteFormatter.string(from: c.timestamp)
            if let exist = keyed[key] {
                // 取较新者（通常相等），这里偏向新读数
                if c.timestamp >= exist.timestamp { keyed[key] = c }
            } else {
                keyed[key] = c
            }
        }
        
        // 排序并仅保留24小时内
        let merged = keyed.values.filter { $0.timestamp >= cutoff }.sorted { $0.timestamp < $1.timestamp }
        return merged
    }
    
    private func persistGlucoseData(_ points: [GlucoseDataPoint]) {
        do {
            let data = try JSONEncoder().encode(points)
            UserDefaults.standard.set(data, forKey: "glucoseTrendData")
            
            // 同时保存到14天历史数据中
            persistHistoricalGlucoseData(points)
            
            // 通知首页等界面更新概要展示
            NotificationCenter.default.post(name: .glucoseTrendDataUpdated, object: nil)
        } catch {
            print("Persist glucoseTrendData failed: \(error)")
        }
    }
    
    // 保存14天历史数据
    private func persistHistoricalGlucoseData(_ newPoints: [GlucoseDataPoint]) {
        do {
            // 加载现有的历史数据
            var historicalData = loadHistoricalGlucoseData()
            
            // 合并新数据
            let now = Date()
            let fourteenDaysAgo = now.addingTimeInterval(-14 * 24 * 60 * 60)
            
            // 移除超过14天的数据
            historicalData = historicalData.filter { $0.timestamp >= fourteenDaysAgo }
            
            // 合并新数据点（去重）
            var keyed: [String: GlucoseDataPoint] = [:]
            let minuteFormatter = DateFormatter()
            minuteFormatter.dateFormat = "yyyy-MM-dd HH:mm"
            
            // 现有历史数据
            for point in historicalData {
                keyed[minuteFormatter.string(from: point.timestamp)] = point
            }
            
            // 新数据点
            for point in newPoints {
                let key = minuteFormatter.string(from: point.timestamp)
                if let existing = keyed[key] {
                    // 保留较新的数据
                    if point.timestamp >= existing.timestamp {
                        keyed[key] = point
                    }
                } else {
                    keyed[key] = point
                }
            }
            
            // 排序并保存
            let mergedData = keyed.values.sorted { $0.timestamp < $1.timestamp }
            let data = try JSONEncoder().encode(mergedData)
            UserDefaults.standard.set(data, forKey: "glucoseHistoricalData")
            
        } catch {
            print("Persist historical glucose data failed: \(error)")
        }
    }
    
    private func loadPersistedGlucoseData() -> [GlucoseDataPoint] {
        guard let data = UserDefaults.standard.data(forKey: "glucoseTrendData") else { return [] }
        do {
            let points = try JSONDecoder().decode([GlucoseDataPoint].self, from: data)
            return points
        } catch {
            print("Load glucoseTrendData failed: \(error)")
            return []
        }
    }
    
    // 加载14天历史数据
    private func loadHistoricalGlucoseData() -> [GlucoseDataPoint] {
        guard let data = UserDefaults.standard.data(forKey: "glucoseHistoricalData") else { return [] }
        do {
            let points = try JSONDecoder().decode([GlucoseDataPoint].self, from: data)
            return points
        } catch {
            print("Load historical glucose data failed: \(error)")
            return []
        }
    }
    
    // 将现有的24小时数据迁移到14天历史存储中
    private func migrateExistingDataToHistory() {
        // 检查是否已经迁移过
        let migrationKey = "glucoseDataMigrated"
        if UserDefaults.standard.bool(forKey: migrationKey) {
            return
        }
        
        // 获取现有的24小时数据
        let existingData = loadPersistedGlucoseData()
        if !existingData.isEmpty {
            // 将现有数据保存到历史存储中
            persistHistoricalGlucoseData(existingData)
            print("Migrated \(existingData.count) existing glucose data points to historical storage")
        }
        
        // 标记已迁移
        UserDefaults.standard.set(true, forKey: migrationKey)
    }
}

// MARK: - 通知名称定义
extension Notification.Name {
    static let glucoseTrendDataUpdated = Notification.Name("glucoseTrendDataUpdated")
}

// MARK: - Measurement Result Sheet View
struct MeasurementResultView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    let glucoseReading: LibreGlucoseReading?
    
    var body: some View {
        VStack(spacing: 0) {
            // Sheet content
            VStack(spacing: 20) {
                // Title
                Text("Measurement Complete")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.top, 20)
                
                // Glucose result display
                if let reading = glucoseReading {
                    VStack(spacing: 16) {
                        // Main glucose value
                        VStack(spacing: 8) {
                            Text("Current Glucose")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white.opacity(0.8))
                            
                            HStack(spacing: 8) {
                                Text("\(String(format: "%.1f", reading.currentGlucose ?? 0))")
                                    .font(.system(size: 36, weight: .bold))
                                    .foregroundColor(AppTheme.primaryText(colorScheme))
                                
                                Text("mmol/L")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(AppTheme.primaryText(colorScheme))
                                
                                Text(reading.trendDirection.rawValue)
                                    .font(.system(size: 24))
                                    .foregroundColor(.white)
                            }
                        }
                        
                        // Detailed information
                        HStack(spacing: 30) {
                            VStack(spacing: 4) {
                                Text("Sensor Status")
                                    .font(.system(size: 12, weight: .regular))
                                    .foregroundColor(.white.opacity(0.8))
                                Text("Normal")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.white)
                            }
                            
                            if let batteryLevel = reading.batteryLevel {
                                VStack(spacing: 4) {
                                    Text("Battery Level")
                                        .font(.system(size: 12, weight: .regular))
                                        .foregroundColor(.white.opacity(0.8))
                                    Text("\(batteryLevel)%")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.white)
                                }
                            }
                        }
                        
                        // History record information
                        VStack(spacing: 8) {
                            Text("History Records")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white.opacity(0.8))
                            Text("\(reading.glucoseHistory.count) data points")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .padding(.top, 10)
                    }
                    .padding(.horizontal, 20)
                } else {
                    // If no data, show default information
                    VStack(spacing: 16) {
                        Text("Measurement Data")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                        
                        Text("6.5 mmol/L")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(AppTheme.primaryText(colorScheme))
                        
                        Text("Stable")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 20)
                }
                
                Spacer(minLength: 20)
                
                // Done button
                Button(action: {
                    dismiss()
                }) {
                    Text("Done")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
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
    }
}

// MARK: - 读取模式切换组件
struct ReadingModeToggle: View {
    @ObservedObject var nfcScanner: NFCScanner
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Reading Mode")
                    .font(.custom("Montserrat", size: 14))
                    .fontWeight(.medium)
                    .foregroundColor(AppTheme.primaryText(colorScheme))
                
                Spacer()
                
                HStack(spacing: 8) {
                    Text(nfcScanner.isMinimalReadMode ? "Real-time" : "Full")
                        .font(.custom("Noto Sans JP", size: 12))
                        .foregroundColor(AppTheme.secondaryText(colorScheme))
                    
                    Toggle("", isOn: Binding(
                        get: { !nfcScanner.isMinimalReadMode },
                        set: { _ in nfcScanner.toggleReadMode() }
                    ))
                    .labelsHidden()
                    .scaleEffect(0.8)
                }
            }
            
            // 模式说明
            VStack(alignment: .leading, spacing: 4) {
                if nfcScanner.isMinimalReadMode {
                    HStack(alignment: .top, spacing: 8) {
                        Text("🎯")
                            .font(.caption)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Real-time Mode (Recommended)")
                                .font(.custom("Noto Sans JP", size: 11))
                                .fontWeight(.medium)
                                .foregroundColor(AppTheme.accent)
                            Text("Reads current glucose only to reduce connection drops")
                                .font(.custom("Noto Sans JP", size: 10))
                                .foregroundColor(AppTheme.secondaryText(colorScheme))
                        }
                        Spacer()
                    }
                } else {
                    HStack(alignment: .top, spacing: 8) {
                        Text("📚")
                            .font(.caption)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Full Mode")
                                .font(.custom("Noto Sans JP", size: 11))
                                .fontWeight(.medium)
                                .foregroundColor(AppTheme.primaryText(colorScheme))
                            Text("Reads full history, may cause connection drops")
                                .font(.custom("Noto Sans JP", size: 10))
                                .foregroundColor(Color.orange)
                        }
                        Spacer()
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(nfcScanner.isMinimalReadMode ? 
                          AppTheme.accent.opacity(0.1) : 
                          Color.orange.opacity(0.1)
                    )
            )
        }
        .padding(.vertical, 8)
    }
}

// MARK: - 血糖历史记录视图
struct BloodGlucoseHistoryView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @State private var historicalData: [GlucoseDataPoint] = []
    
    var body: some View {
        VStack(spacing: 0) {
            // 自定义导航栏
            CustomHistoryNavigationBar(onBack: {
                dismiss()
            })
            
            // 分割线
            Divider()
                .background(Color.gray.opacity(0.3))
            
            // 内容区域
            ScrollView {
                LazyVStack(spacing: 16) {
                    if historicalData.isEmpty {
                        // 空状态
                        VStack(spacing: 16) {
                            Image(systemName: "chart.line.uptrend.xyaxis")
                                .font(.system(size: 60))
                                .foregroundColor(AppTheme.secondaryText(colorScheme))
                                .padding(.top, 60)
                            
                            Text("No history yet")
                                .font(.custom("Noto Sans JP", size: 18))
                                .fontWeight(.medium)
                                .foregroundColor(AppTheme.primaryText(colorScheme))
                            
                            Text("Your measurements will appear here once available")
                                .font(.custom("Noto Sans JP", size: 14))
                                .foregroundColor(AppTheme.secondaryText(colorScheme))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 100)
                    } else {
                        // 按日期分组显示数据
                        ForEach(groupedDataByDate, id: \.key) { dateGroup in
                            VStack(spacing: 12) {
                                // Date header
                                HStack {
                                    Text(dateGroup.key)
                                        .font(.custom("Montserrat", size: 16))
                                        .fontWeight(.semibold)
                                        .foregroundColor(AppTheme.primaryText(colorScheme))
                                    
                                    Spacer()
                                    
                                    Text("\(dateGroup.value.count) records")
                                        .font(.custom("Noto Sans JP", size: 12))
                                        .foregroundColor(AppTheme.secondaryText(colorScheme))
                                }
                                .padding(.horizontal, 20)
                                
                                // 该日期的测量记录
                                VStack(spacing: 8) {
                                    ForEach(dateGroup.value, id: \.id) { dataPoint in
                                        HistoryDataRow(dataPoint: dataPoint)
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                        }
                    }
                }
                .padding(.top, 24)
                .padding(.bottom, 40)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            // 先执行一次数据迁移（确保现有数据被包含）
            migrateExistingDataIfNeeded()
            // 然后加载历史数据
            loadHistoricalData()
        }
    }
    
    // 按日期分组数据
    private var groupedDataByDate: [(key: String, value: [GlucoseDataPoint])] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy"
        dateFormatter.locale = Locale(identifier: "zh_CN")
        
        let grouped = Dictionary(grouping: historicalData) { dataPoint in
            dateFormatter.string(from: dataPoint.timestamp)
        }
        
        return grouped.sorted { first, second in
            // 按日期降序排列（最新的在前）
            guard let firstDate = dateFormatter.date(from: first.key),
                  let secondDate = dateFormatter.date(from: second.key) else {
                return false
            }
            return firstDate > secondDate
        }
    }
    
    private func loadHistoricalData() {
        var allData: [GlucoseDataPoint] = []
        
        // 首先尝试加载14天历史数据
        if let historicalData = UserDefaults.standard.data(forKey: "glucoseHistoricalData") {
            do {
                let points = try JSONDecoder().decode([GlucoseDataPoint].self, from: historicalData)
                allData.append(contentsOf: points)
            } catch {
                print("Load historical glucose data failed: \(error)")
            }
        }
        
        // 如果历史数据为空，尝试加载24小时数据作为备用
        if allData.isEmpty {
            if let trendData = UserDefaults.standard.data(forKey: "glucoseTrendData") {
                do {
                    let points = try JSONDecoder().decode([GlucoseDataPoint].self, from: trendData)
                    allData.append(contentsOf: points)
                    print("Loaded \(points.count) data points from trend data as fallback")
                } catch {
                    print("Load trend glucose data failed: \(error)")
                }
            }
        }
        
        // 去重并按时间倒序排列（最新的在前）
        let uniqueData = Dictionary(grouping: allData) { point in
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm"
            return formatter.string(from: point.timestamp)
        }.compactMapValues { $0.first }
        
        historicalData = uniqueData.values.sorted { $0.timestamp > $1.timestamp }
        
        print("Loaded \(historicalData.count) total historical data points")
    }
    
    // 在历史记录视图中执行数据迁移
    private func migrateExistingDataIfNeeded() {
        // 检查是否有历史数据
        let hasHistoricalData = UserDefaults.standard.data(forKey: "glucoseHistoricalData") != nil
        
        // 如果没有历史数据，但有趋势数据，则进行迁移
        if !hasHistoricalData {
            if let trendData = UserDefaults.standard.data(forKey: "glucoseTrendData") {
                do {
                    let points = try JSONDecoder().decode([GlucoseDataPoint].self, from: trendData)
                    if !points.isEmpty {
                        // 保存到历史数据中
                        let historicalData = try JSONEncoder().encode(points)
                        UserDefaults.standard.set(historicalData, forKey: "glucoseHistoricalData")
                        print("Migrated \(points.count) existing data points to historical storage")
                    }
                } catch {
                    print("Migration failed: \(error)")
                }
            }
        }
    }
}

// MARK: - 历史记录导航栏
struct CustomHistoryNavigationBar: View {
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
            
            // Title
            Text("Blood Glucose History")
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

// MARK: - 历史数据行
struct HistoryDataRow: View {
    let dataPoint: GlucoseDataPoint
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        HStack(spacing: 16) {
            // 时间
            VStack(alignment: .leading, spacing: 2) {
                Text(dataPoint.time)
                    .font(.custom("Roboto Mono", size: 16))
                    .fontWeight(.semibold)
                    .foregroundColor(AppTheme.primaryText(colorScheme))
                
                Text(formatTimestamp(dataPoint.timestamp))
                    .font(.custom("Noto Sans JP", size: 11))
                    .foregroundColor(AppTheme.secondaryText(colorScheme))
            }
            
            Spacer()
            
            // 血糖值
            HStack(spacing: 8) {
                Text(String(format: "%.1f", dataPoint.value))
                    .font(.custom("Roboto Mono", size: 20))
                    .fontWeight(.bold)
                    .foregroundColor(glucoseValueColor(dataPoint.value))
                
                Text("mmol/L")
                    .font(.custom("Noto Sans JP", size: 12))
                    .fontWeight(.medium)
                    .foregroundColor(AppTheme.secondaryText(colorScheme))
            }
            
            // 状态指示器
            Circle()
                .fill(glucoseValueColor(dataPoint.value))
                .frame(width: 8, height: 8)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(AppTheme.cardBackground(colorScheme))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    private func formatTimestamp(_ timestamp: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        formatter.locale = Locale(identifier: "en_US")
        return formatter.string(from: timestamp)
    }
    
    private func glucoseValueColor(_ value: Double) -> Color {
        switch value {
        case 0..<3.9:
            return Color.red // 低血糖
        case 3.9...10.0:
            return Color.green // 正常范围
        default:
            return Color.orange // 高血糖
        }
    }
}

#Preview {
    BloodGlucoseView()
}

//
//  HealthData.swift
//  SAIWristband
//
//  Created by golfy xiong on 2025/8/22.
//

import SwiftUI
import Foundation

// MARK: - 健康数据模型
struct HealthSummary {
    let type: HealthType
    let value: String
    let unit: String
    let status: HealthStatus
    let time: String
    let icon: String
    let chartImage: String?
}

enum HealthType: String, CaseIterable {
    case heartRate = "Heart rhythm"
    case ecg = "Electrocardiogram"
    case bloodPressure = "Blood pressure"
    case bloodSugar = "Blood glucose"
    case bloodOxygen = "Blood oxygen"
    
    var iconName: String {
        switch self {
        case .heartRate:
            return "heart.fill"
        case .ecg:
            return "heart.fill"
        case .bloodPressure:
            return "drop.fill"
        case .bloodSugar:
            return "drop.triangle.fill"
        case .bloodOxygen:
            return "lungs.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .heartRate:
            return Color.red
        case .ecg:
            return Color.red
        case .bloodPressure:
            return Color.blue
        case .bloodSugar:
            return Color.orange
        case .bloodOxygen:
            return Color.green
        }
    }
}

enum HealthStatus: String {
    case normal = "Normal"
    case warning = "Warning"
    case critical = "Critical"
    
    var color: Color {
        switch self {
        case .normal:
            return Color.green
        case .warning:
            return Color.orange
        case .critical:
            return Color.red
        }
    }
}

// MARK: - 时间线数据模型
struct TimelineEvent {
    let time: String
    let title: String
    let icon: String
    let iconColor: Color
    let isActive: Bool
    let image: String? // 添加图片支持
    let content: String // 添加内容文字
    let cardType: TimelineCardType // 卡片类型
}

enum TimelineCardType {
    case dashed // 虚线边框
    case solid  // 实线边框（带阴影）
    case simple // 简单虚线边框
}

// MARK: - 设备信息模型
struct DeviceInfo {
    let batteryLevel: Int
    let isConnected: Bool
    let deviceType: String
}

// MARK: - 样本数据
extension HealthSummary {
    static let sampleData: [HealthSummary] = [
        HealthSummary(
            type: .heartRate,
            value: "59",
            unit: "bpm",
            status: .normal,
            time: "10:28",
            icon: "Icon heart",
            chartImage: "chart_1"
        ),
        HealthSummary(
            type: .bloodPressure,
            value: "130/75",
            unit: "",
            status: .normal,
            time: "10:28",
            icon: "Icon water drop",
            chartImage: "chart_2"
        ),
        HealthSummary(
            type: .bloodSugar,
            value: "4.3",
            unit: "mmol/L",
            status: .normal,
            time: "10:28",
            icon: "Icon bloodtype",
            chartImage: nil
        ),
        HealthSummary(
            type: .bloodOxygen,
            value: "98",
            unit: "%",
            status: .normal,
            time: "10:28",
            icon: "Icon lungs",
            chartImage: nil
        ),
        HealthSummary(
            type: .ecg,
            value: "90",
            unit: "BPM",
            status: .normal,
            time: "6:05",
            icon: "Icon heart pulse",
            chartImage: nil
        )
    ]
}

extension TimelineEvent {
    static let sampleData: [TimelineEvent] = [
        TimelineEvent(
            time: "8:00 AM",
            title: "Morning run",
            icon: "figure.run",
            iconColor: Color(red: 0.4, green: 0.26, blue: 0.65),
            isActive: false,
            image: "timeline_image_3",
            content: "Get your heart pumping with outdoor exercise",
            cardType: .dashed
        ),
        TimelineEvent(
            time: "7:30 AM",
            title: "Have a breakfast",
            icon: "fork.knife.circle.fill",
            iconColor: Color(red: 0.4, green: 0.26, blue: 0.65),
            isActive: true,
            image: "Icon egg alt",
            content: "Healthy breakfast to fuel your body for the day ahead",
            cardType: .solid
        ),
        TimelineEvent(
            time: "7:00 AM",
            title: "Wake up",
            icon: "sun.max.fill",
            iconColor: Color(red: 0.4, green: 0.26, blue: 0.65),
            isActive: false,
            image: "timeline_image_1",
            content: "Start your day with a refreshing morning routine",
            cardType: .dashed
        )
    ]
}

extension DeviceInfo {
    static let sampleData = DeviceInfo(
        batteryLevel: 100,
        isConnected: true,
        deviceType: "Smart Watch"
    )
}

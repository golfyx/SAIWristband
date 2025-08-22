//
//  DeviceData.swift
//  SAIWristband
//
//  Created by golfy xiong on 2025/8/22.
//

import SwiftUI
import Foundation

// MARK: - 设备管理数据模型
struct Device {
    let id: String
    let name: String
    let brand: String
    let description: String
    let iconImage: String
    let connectionStatus: DeviceConnectionStatus
    let batteryLevel: Int?
    let usageTime: String?
    let model: String?
    let hasNotification: Bool
    let isConnected: Bool
}

enum DeviceConnectionStatus: String {
    case connected = "Connected"
    case disconnected = "Disconnected"
    case pairing = "Pairing"
    
    var color: Color {
        switch self {
        case .connected:
            return Color(red: 0.56, green: 0.56, blue: 0.57) // 灰色
        case .disconnected:
            return Color.red
        case .pairing:
            return Color.orange
        }
    }
}

// MARK: - 设备健康报告数据模型
struct DeviceHealthReport {
    let title: String
    let description: String
    let imageName: String
    let primaryAction: HealthReportAction
    let secondaryAction: HealthReportAction
}

struct HealthReportAction {
    let title: String
    let action: () -> Void
    let style: ActionStyle
    
    enum ActionStyle {
        case primary
        case secondary
        
        var backgroundColor: Color {
            switch self {
            case .primary:
                return Color(red: 0.60, green: 0.31, blue: 0.95)
            case .secondary:
                return Color.white
            }
        }
        
        var foregroundColor: Color {
            switch self {
            case .primary:
                return .white
            case .secondary:
                return Color(red: 0.60, green: 0.31, blue: 0.95)
            }
        }
        
        var strokeColor: Color {
            switch self {
            case .primary:
                return Color.clear
            case .secondary:
                return Color(red: 0.60, green: 0.31, blue: 0.95)
            }
        }
    }
}

// MARK: - 样本数据
extension Device {
    static let sampleData: [Device] = [
        Device(
            id: "2",
            name: "Abbott",
            brand: "Abbott",
            description: "Blood glucose meter",
            iconImage: "abbott_icon",
            connectionStatus: .disconnected,
            batteryLevel: nil,
            usageTime: nil,
            model: nil,
            hasNotification: false,
            isConnected: false
        ),
        Device(
            id: "3",
            name: "Omron",
            brand: "Omron",
            description: "Blood pressure monitor",
            iconImage: "omron_icon",
            connectionStatus: .disconnected,
            batteryLevel: nil,
            usageTime: nil,
            model: nil,
            hasNotification: false,
            isConnected: false
        ),
        Device(
            id: "4",
            name: "Withings",
            brand: "Withings",
            description: "Body fat scale",
            iconImage: "withings_icon",
            connectionStatus: .disconnected,
            batteryLevel: nil,
            usageTime: nil,
            model: nil,
            hasNotification: false,
            isConnected: false
        )
    ]
    
    static let connectedDevice = Device(
        id: "1",
        name: "Health Watch",
        brand: "Health Watch",
        description: "Smart Health Watch",
        iconImage: "health_watch_logo",
        connectionStatus: .connected,
        batteryLevel: 80,
        usageTime: "5 hours",
        model: "SW-2023",
        hasNotification: true,
        isConnected: true
    )
}

extension DeviceHealthReport {
    static let sampleData = DeviceHealthReport(
        title: "Health Report",
        description: "Generate and share your personalized health report with healthcare providers",
        imageName: "health_report_icon",
        primaryAction: HealthReportAction(
            title: "Generate Report",
            action: { print("Generate Report tapped") },
            style: .primary
        ),
        secondaryAction: HealthReportAction(
            title: "Share Report",
            action: { print("Share Report tapped") },
            style: .secondary
        )
    )
}

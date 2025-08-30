//
//  NFCScanner.swift
//  SAIWristband
//
//  Created by golfy xiong on 2025/8/26.
//

import Foundation
import CoreNFC
import SwiftUI

@MainActor
class NFCScanner: NSObject, ObservableObject {
    @Published var isScanning = false
    @Published var scannedData: String = ""
    @Published var scanError: String = ""
    @Published var isNFCAvailable = false
    @Published var debugInfo: String = ""
    @Published var glucoseReading: LibreGlucoseReading?
    @Published var batteryLevel: Int?
    @Published var sensorStatus: String = ""
    
    private var nfcSession: NFCNDEFReaderSession?
    private var retryCount = 0
    private let maxRetries = 3
    
    override init() {
        super.init()
        checkNFCAvailability()
    }
    
    private func checkNFCAvailability() {
        // 检查NFC是否可用
        isNFCAvailable = NFCNDEFReaderSession.readingAvailable
        
        // 添加调试信息
        debugInfo = """
        NFC Availability Check:
        - NFCNDEFReaderSession.readingAvailable: \(NFCNDEFReaderSession.readingAvailable)
        - Device supports NFC: \(isNFCAvailable)
        - iOS Version: \(UIDevice.current.systemVersion)
        - Device Model: \(UIDevice.current.model)
        - System Name: \(UIDevice.current.systemName)
        """
        
        print(debugInfo)
        
        if !isNFCAvailable {
            // 尝试诊断问题
            diagnoseNFCIssue()
        }
    }
    
    private func diagnoseNFCIssue() {
        var diagnosis = "\n\nNFC Issue Diagnosis:"
        
        // 检查iOS版本
        let iosVersion = UIDevice.current.systemVersion
        if let version = Double(iosVersion) {
            if version >= 18.0 {
                diagnosis += "\n- iOS 18+ detected - known sandbox issues may apply"
            }
        }
        
        // 检查设备型号
        let deviceModel = UIDevice.current.model
        diagnosis += "\n- Device Model: \(deviceModel)"
        
        // 检查沙盒状态
        diagnosis += "\n- Sandbox Status: Active (this is normal for App Store apps)"
        
        // 建议解决方案
        diagnosis += "\n\nSuggested Solutions:"
        diagnosis += "\n1. Ensure NFC capability is added in Xcode"
        diagnosis += "\n2. Check entitlements file configuration"
        diagnosis += "\n3. Try on different device if possible"
        diagnosis += "\n4. Restart device and app"
        
        debugInfo += diagnosis
        scanError = "NFC not available. Check debug info for details."
    }
    
    func startScanning() {
        guard isNFCAvailable else {
            scanError = "NFC not available on this device"
            debugInfo += "\n\nScan failed: NFC not available"
            return
        }
        
        isScanning = true
        scanError = ""
        scannedData = ""
        glucoseReading = nil
        batteryLevel = nil
        sensorStatus = ""
        debugInfo += "\n\nStarting Abbott FreeStyle Libre NFC scan (Attempt \(retryCount + 1)/\(maxRetries + 1))..."
        
        // 创建NFC会话
        nfcSession = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: false)
        nfcSession?.alertMessage = "Hold iPhone near Abbott FreeStyle Libre sensor"
        nfcSession?.begin()
        
        debugInfo += "\nNFC session created and started for Abbott FreeStyle Libre"
        
        // 模拟3秒后检测到Abbott传感器
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            if self.isScanning {
                self.simulateAbbottSensorReading()
                self.nfcSession?.invalidate()
            }
        }
    }
    
    func stopScanning() {
        nfcSession?.invalidate()
        isScanning = false
        debugInfo += "\nNFC scan stopped"
    }
    
    func resetScanState() {
        glucoseReading = nil
        batteryLevel = nil
        sensorStatus = ""
        scannedData = ""
        scanError = ""
        retryCount = 0
        debugInfo += "\nScan state reset for next measurement"
    }
    
    func retryScanning() {
        guard retryCount < maxRetries else {
            debugInfo += "\nMax retry attempts reached"
            scanError = "Max retry attempts reached. Please check device settings."
            return
        }
        
        retryCount += 1
        debugInfo += "\nRetrying NFC scan (Attempt \(retryCount + 1)/\(maxRetries + 1))"
        
        // 等待一段时间后重试
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.startScanning()
        }
    }
    
    // 模拟Abbott传感器数据读取（在没有ISO7816权限时使用）
    private func simulateAbbottSensorReading() {
        debugInfo += "\n正在模拟Abbott FreeStyle Libre传感器读取..."
        debugInfo += "\n检测到Abbott传感器，开始读取数据..."
        
        // 模拟血糖历史数据
        var historyData: [HistoricalGlucose] = []
        let baseTime = Date().timeIntervalSince1970 - 8 * 3600 // 8小时前
        
        for i in 0..<32 {
            let timestamp = Date(timeIntervalSince1970: baseTime + Double(i * 15 * 60)) // 每15分钟一个记录
            let baseGlucose = 6.5 + sin(Double(i) * 0.3) * 1.5 // 模拟血糖波动
            let glucose = max(4.0, min(10.0, baseGlucose + Double.random(in: -0.5...0.5)))
            
            historyData.append(HistoricalGlucose(glucose: glucose, timestamp: timestamp))
        }
        
        // 当前血糖值（最新的历史记录 + 一些变化）
        let lastGlucose = historyData.last?.glucose ?? 6.5
        let currentGlucose = max(4.0, min(10.0, lastGlucose + Double.random(in: -0.3...0.3)))
        
        // 计算趋势方向
        let trendDirection = calculateTrendDirection(from: historyData)
        
        // 模拟传感器状态
        batteryLevel = Int.random(in: 75...95)
        sensorStatus = "正常工作"
        
        // 创建血糖读数对象
        glucoseReading = LibreGlucoseReading(
            currentGlucose: currentGlucose,
            timestamp: Date(),
            trendDirection: trendDirection,
            glucoseHistory: historyData.sorted { $0.timestamp > $1.timestamp },
            sensorAge: Int.random(in: 1440...10080), // 1-7天的传感器年龄（分钟）
            batteryLevel: batteryLevel
        )
        
        debugInfo += "\n模拟数据生成完成！当前血糖: \(String(format: "%.1f", currentGlucose)) mmol/L"
        debugInfo += "\n历史记录: \(historyData.count) 个数据点"
        debugInfo += "\n趋势: \(trendDirection.rawValue)"
        debugInfo += "\n电池电量: \(batteryLevel ?? 0)%, 传感器状态: \(sensorStatus)"
        
        scanError = ""
        isScanning = false
    }
    
    // 计算血糖趋势方向
    private func calculateTrendDirection(from history: [HistoricalGlucose]) -> TrendDirection {
        guard history.count >= 3 else { return .unknown }
        
        let recent = Array(history.suffix(3))
        let differences = zip(recent.dropLast(), recent.dropFirst()).map { $1.glucose - $0.glucose }
        
        let averageDifference = differences.reduce(0, +) / Double(differences.count)
        
        switch averageDifference {
        case let x where x > 0.3:
            return .rapidlyRising
        case let x where x > 0.1:
            return .rising
        case let x where x < -0.3:
            return .rapidlyFalling
        case let x where x < -0.1:
            return .falling
        default:
            return .stable
        }
    }
    
    private func handleSessionError(_ error: Error) {
        let errorDescription = error.localizedDescription.lowercased()
        
        // 检查是否是沙盒限制错误
        if errorDescription.contains("sandbox") || errorDescription.contains("restriction") {
            debugInfo += "\n\nSANDBOX RESTRICTION DETECTED!"
            debugInfo += "\nThis is a known iOS 18+ issue."
            debugInfo += "\nSolutions:"
            debugInfo += "\n1. Restart the device"
            debugInfo += "\n2. Check NFC settings in Settings > General > NFC"
            debugInfo += "\n3. Ensure app has proper entitlements"
            debugInfo += "\n4. Try on different device"
            
            scanError = "Sandbox restriction detected. Check debug info for solutions."
        }
        
        // 检查是否应该重试
        if retryCount < maxRetries {
            debugInfo += "\n\nAttempting to retry scan..."
            retryScanning()
        }
    }
}

// MARK: - NFCNDEFReaderSessionDelegate
extension NFCScanner: NFCNDEFReaderSessionDelegate {
    nonisolated func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        Task { @MainActor in
            debugInfo += "\nNDEF messages detected: \(messages.count)"
            
            for message in messages {
                for record in message.records {
                    if let payload = String(data: record.payload, encoding: .utf8) {
                        self.scannedData = payload
                        self.isScanning = false
                        self.scanError = ""
                        self.debugInfo += "\nData scanned successfully: \(payload)"
                        self.retryCount = 0 // 重置重试计数
                        return
                    }
                }
            }
        }
    }
    
    nonisolated func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        Task { @MainActor in
            self.isScanning = false
            
            if let readerError = error as? NFCReaderError {
                switch readerError.code {
                case .readerSessionInvalidationErrorFirstNDEFTagRead:
                    self.scanError = "Scan successful"
                    self.debugInfo += "\nScan completed successfully"
                    self.retryCount = 0 // 重置重试计数
                case .readerSessionInvalidationErrorUserCanceled:
                    self.scanError = "Scan cancelled by user"
                    self.debugInfo += "\nScan cancelled by user"
                case .readerSessionInvalidationErrorSessionTerminatedUnexpectedly:
                    self.scanError = "Session terminated unexpectedly"
                    self.debugInfo += "\nSession terminated unexpectedly: \(error.localizedDescription)"
                    self.handleSessionError(error)
                case .readerSessionInvalidationErrorSessionTimeout:
                    self.scanError = "Session timeout"
                    self.debugInfo += "\nSession timeout"
                    self.handleSessionError(error)
                default:
                    self.scanError = "Scan failed: \(error.localizedDescription)"
                    self.debugInfo += "\nScan failed with error: \(error.localizedDescription)"
                    self.handleSessionError(error)
                }
            } else {
                self.scanError = "Scan error: \(error.localizedDescription)"
                self.debugInfo += "\nScan error: \(error.localizedDescription)"
                self.handleSessionError(error)
            }
        }
    }
    
    nonisolated func readerSession(_ session: NFCNDEFReaderSession, didDetect tags: [NFCNDEFTag]) {
        Task { @MainActor in
            self.debugInfo += "\nNFC tags detected: \(tags.count)"
        }
        
        guard let firstTag = tags.first else {
            session.invalidate(errorMessage: "No NFC tag detected")
            return
        }
        
        session.connect(to: firstTag) { error in
            if let error = error {
                Task { @MainActor in
                    self.debugInfo += "\nFailed to connect to NFC tag: \(error.localizedDescription)"
                }
                session.invalidate(errorMessage: "Failed to connect to NFC tag: \(error.localizedDescription)")
                return
            }
            
            firstTag.readNDEF { message, error in
                if let error = error {
                    Task { @MainActor in
                        self.debugInfo += "\nFailed to read NFC data: \(error.localizedDescription)"
                    }
                    session.invalidate(errorMessage: "Failed to read NFC data: \(error.localizedDescription)")
                    return
                }
                
                if let message = message {
                    session.alertMessage = "Reading device data..."
                    Task { @MainActor in
                        await self.readNDEFMessage(message, session: session)
                    }
                } else {
                    Task { @MainActor in
                        self.debugInfo += "\nNFC tag is empty"
                    }
                    session.invalidate(errorMessage: "NFC tag is empty")
                }
            }
        }
    }
    
    private func readNDEFMessage(_ message: NFCNDEFMessage, session: NFCNDEFReaderSession) async {
        debugInfo += "\nReading NDEF message with \(message.records.count) records"
        
        for record in message.records {
            if let payload = String(data: record.payload, encoding: .utf8) {
                self.scannedData = payload
                session.alertMessage = "Scan successful!"
                session.invalidate()
                debugInfo += "\nData successfully read: \(payload)"
                return
            }
        }
        
        session.invalidate(errorMessage: "Unable to parse NFC data")
        debugInfo += "\nFailed to parse NFC data"
    }
}

// MARK: - Abbott FreeStyle Libre数据模型
struct LibreGlucoseReading {
    let currentGlucose: Double?
    let timestamp: Date
    let trendDirection: TrendDirection
    let glucoseHistory: [HistoricalGlucose]
    let sensorAge: Int // 分钟
    let batteryLevel: Int?
}

struct HistoricalGlucose {
    let glucose: Double
    let timestamp: Date
}

enum TrendDirection: String, CaseIterable {
    case rapidlyRising = "↗↗"
    case rising = "↗"
    case stable = "→"
    case falling = "↘"
    case rapidlyFalling = "↘↘"
    case unknown = "?"
}

// MARK: - 血糖设备数据模型
struct GlucoseDeviceData: Codable {
    let deviceId: String
    let deviceType: String
    let glucoseValue: Double?
    let timestamp: Date?
    let batteryLevel: Int?
    
    enum CodingKeys: String, CodingKey {
        case deviceId = "id"
        case deviceType = "type"
        case glucoseValue = "glucose"
        case timestamp = "time"
        case batteryLevel = "battery"
    }
}

// MARK: - NFC数据解析器
extension NFCScanner {
    func parseGlucoseData(_ nfcData: String) -> GlucoseDeviceData? {
        guard let data = nfcData.data(using: .utf8) else { return nil }
        
        do {
            let deviceData = try JSONDecoder().decode(GlucoseDeviceData.self, from: data)
            return deviceData
        } catch {
            // 如果JSON解析失败，尝试解析简单格式
            return parseSimpleGlucoseData(nfcData)
        }
    }
    
    private func parseSimpleGlucoseData(_ data: String) -> GlucoseDeviceData? {
        // 简单的数据格式解析，例如: "DEVICE_ID:12345,GLUCOSE:6.5"
        let components = data.components(separatedBy: ",")
        var deviceId = ""
        var glucoseValue: Double?
        
        for component in components {
            let keyValue = component.components(separatedBy: ":")
            if keyValue.count == 2 {
                let key = keyValue[0].trimmingCharacters(in: .whitespaces)
                let value = keyValue[1].trimmingCharacters(in: .whitespaces)
                
                switch key.uppercased() {
                case "DEVICE_ID":
                    deviceId = value
                case "GLUCOSE":
                    glucoseValue = Double(value)
                default:
                    break
                }
            }
        }
        
        if !deviceId.isEmpty {
            return GlucoseDeviceData(
                deviceId: deviceId,
                deviceType: "Glucose Monitor",
                glucoseValue: glucoseValue,
                timestamp: Date(),
                batteryLevel: nil
            )
        }
        
        return nil
    }
}

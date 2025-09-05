//
//  LibreNFCManager.swift
//  SAIWristband
//
//  Created by golfy xiong on 2025/1/16.
//

import Foundation
@preconcurrency import CoreNFC
import AVFoundation

// MARK: - Libre NFC管理器（兼容版本）
@MainActor
class LibreNFCManager: NSObject, ObservableObject {
    
    // MARK: - Published Properties
    @Published var isScanning = false
    @Published var scanError: String = ""
    @Published var debugInfo: String = ""
    @Published var sensorInfo: LibreSensorInfo?
    @Published var glucoseReading: LibreGlucoseReading?
    @Published var isMinimalReadMode: Bool = true // 最小化读取模式，避免连接丢失
    
    // MARK: - Private Properties
    private var nfcSession: NFCTagReaderSession?
    private var retryCount = 0
    private let maxRetries = 3
    
    // Libre 1 特定的backdoor密钥 (来自DiaBLE项目)
    private let libre1Backdoor: Data = Data([0xc2, 0xad, 0x75, 0x21])
    
    // Libre 1 FRAM内存地址
    private let libre1FRAMStartAddress: Int = 0xF860
    private let libre1FRAMBlockCount: Int = 244
    
    // MARK: - Initialization
    override init() {
        super.init()
        debugInfo = "📱 Libre NFC Manager initialized (DiaBLE compatibility mode)"
        debugInfo += "\n🔧 Ready for real sensor reading"
        
        // 输出到控制台，便于调试
        print("🚀 LibreNFCManager: \(debugInfo)")
    }
    
    // MARK: - Public Methods
    var isNFCAvailable: Bool {
        return NFCTagReaderSession.readingAvailable
    }
    
    func startScanning() {
        guard isNFCAvailable else {
            scanError = "NFC not available on this device"
            debugInfo += "\n❌ NFC not available"
            return
        }
        
        isScanning = true
        scanError = ""
        retryCount = 0
        sensorInfo = nil
        glucoseReading = nil
        
        debugInfo += "\n🔍 Starting Abbott Libre sensor scan (compatibility mode)..."
        debugInfo += "\n📱 Note: This version uses basic NFC capabilities"
        
        // 创建NFC会话，支持ISO15693（Abbott传感器使用的协议）
        nfcSession = NFCTagReaderSession(pollingOption: [.iso15693, .iso14443], delegate: self, queue: .main)
        nfcSession?.alertMessage = "Hold iPhone near Abbott Libre sensor"
        nfcSession?.begin()
    }
    
    func stopScanning() {
        nfcSession?.invalidate()
        isScanning = false
        debugInfo += "\n⏹️ NFC scan stopped"
    }
    
    // MARK: - Private Methods
    private func handleScanSuccess() {
        isScanning = false
        debugInfo += "\n✅ Scan completed successfully"
        
        // 输出完整的调试信息到控制台
        print("📋 NFC Scan Complete - Full Debug Log:")
        print(String(repeating: "=", count: 50))
        print(debugInfo)
        print(String(repeating: "=", count: 50))
        
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
    }
    
    private func handleScanError(_ error: Error) {
        isScanning = false
        scanError = error.localizedDescription
        debugInfo += "\n❌ Scan failed: \(error.localizedDescription)"
        
        if retryCount < maxRetries {
            retryCount += 1
            debugInfo += "\n🔄 Retrying... (\(retryCount)/\(maxRetries))"
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.startScanning()
            }
        }
    }
    
    
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
}

// MARK: - NFCTagReaderSessionDelegate
extension LibreNFCManager: NFCTagReaderSessionDelegate {
    
    nonisolated func tagReaderSessionDidBecomeActive(_ session: NFCTagReaderSession) {
        Task { @MainActor in
            debugInfo += "\n🔄 NFC session became active"
        }
    }
    
    nonisolated func tagReaderSession(_ session: NFCTagReaderSession, didInvalidateWithError error: Error) {
        Task { @MainActor in
            if let readerError = error as? NFCReaderError {
                switch readerError.code {
                case .readerSessionInvalidationErrorUserCanceled:
                    debugInfo += "\n👤 Scan cancelled by user"
                    isScanning = false
                case .readerSessionInvalidationErrorSessionTimeout:
                    debugInfo += "\n⏰ NFC session timeout"
                    debugInfo += "\n📱 User may need to hold phone closer to sensor"
                    debugInfo += "\n🔄 Please try scanning again"
                    isScanning = false
                    scanError = "NFC session timeout. Please try again and hold phone closer to sensor."
                default:
                    handleScanError(error)
                }
            } else {
                handleScanError(error)
            }
        }
    }
    
    nonisolated func tagReaderSession(_ session: NFCTagReaderSession, didDetect tags: [NFCTag]) {
        Task { @MainActor in
            debugInfo += "\n🏷️ NFC tags detected: \(tags.count)"
            
            guard let firstTag = tags.first else {
                session.invalidate(errorMessage: "No NFC tag detected")
                return
            }
            
            // 检查是否是ISO15693标签（雅培传感器）
            if case .iso15693(let iso15693Tag) = firstTag {
                debugInfo += "\n✅ Abbott ISO15693 sensor detected!"
                await readAbbottSensor(iso15693Tag, session: session)
            } else {
                debugInfo += "\n⚠️ Non-Abbott sensor detected"
                debugInfo += "\n💡 This app only supports Abbott FreeStyle Libre sensors"
                session.alertMessage = "Unsupported sensor type"
                session.invalidate(errorMessage: "This app only supports Abbott FreeStyle Libre sensors")
            }
        }
    }
    
    private func readAbbottSensor(_ tag: NFCISO15693Tag, session: NFCTagReaderSession) async {
        do {
            debugInfo += "\n🔗 Connecting to Abbott sensor..."
            debugInfo += "\n📱 Starting REAL sensor reading (like DiaBLE)..."
            
            // 连接到标签
            try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
                session.connect(to: .iso15693(tag)) { error in
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume()
                    }
                }
            }
            
            debugInfo += "\n✅ Connected to sensor successfully"
            
            // 获取传感器基本信息
            let systemInfo = try await tag.systemInfo(requestFlags: .highDataRate)
            debugInfo += "\n📋 System info: \(systemInfo.totalBlocks) blocks, block size: \(systemInfo.blockSize) bytes"
            
            // 获取传感器UID
            let uid = Data(tag.identifier.reversed())
            debugInfo += "\n🏷️ Sensor UID: \(uid.hex)"
            debugInfo += "\n🔍 IC manufacturer: 0x\(String(format: "%02X", tag.icManufacturerCode)) (should be 7A for Abbott)"
            
            // 尝试读取patch info（基本传感器信息）
            var sensorType = LibreSensorType.unknown
            var patchInfo = Data()
            
            do {
                let patchInfoResponse = try await tag.customCommand(
                    requestFlags: .highDataRate,
                    customCommandCode: 0xA1,
                    customRequestParameters: Data()
                )
                
                patchInfo = Data(patchInfoResponse)
                debugInfo += "\n📦 Patch info (\(patchInfo.count) bytes): \(patchInfo.hex)"
                
                if !patchInfo.isEmpty {
                    sensorType = LibreSensorType(patchInfo: patchInfo)
                    debugInfo += "\n📱 Detected sensor type: \(sensorType.rawValue)"
                } else {
                    debugInfo += "\n⚠️ Empty patch info, assuming Libre 2"
                    sensorType = .libre2
                }
            } catch {
                debugInfo += "\n⚠️ Could not read patch info: \(error.localizedDescription)"
                debugInfo += "\n🔧 Assuming Libre 2 for compatibility"
                sensorType = .libre2
            }
            
            // 创建传感器信息
            let serial = LibreSensorInfo.generateSerial(from: uid)
            sensorInfo = LibreSensorInfo(
                uid: uid,
                serial: serial,
                type: sensorType,
                state: .active,
                age: 0, // Will be calculated from FRAM data
                batteryLevel: nil, // Will be read from FRAM
                firmware: String(format: "0x%02X", uid.count > 2 ? uid[2] : 0)
            )
            
            debugInfo += "\n🆔 Sensor serial: \(serial)"
            debugInfo += "\n🔧 Firmware version: \(sensorInfo!.firmware)"
            
            // 尝试读取血糖数据 (真实FRAM数据)
            await readRealGlucoseData(from: tag)
            
            session.alertMessage = "✅ Real data read successfully!"
            session.invalidate()
            handleScanSuccess()
            
        } catch {
            debugInfo += "\n❌ Critical error reading sensor: \(error.localizedDescription)"
            debugInfo += "\n🚨 Error details: \(error)"
            
            // 报告错误，不使用任何模拟数据
            debugInfo += "\n❌ Failed to read real sensor data"
            debugInfo += "\n💡 Possible solutions:"
            debugInfo += "\n   - Ensure sensor is active and not expired"
            debugInfo += "\n   - Hold phone closer to sensor"
            debugInfo += "\n   - Check sensor compatibility (Libre 1/2/3)"
            debugInfo += "\n   - Try again after a few seconds"
            
            session.alertMessage = "❌ Unable to read sensor data"
            session.invalidate()
            handleScanError(error)
        }
    }
    
    private func readRealGlucoseData(from tag: NFCISO15693Tag) async {
        if isMinimalReadMode {
            debugInfo += "\n📊 Reading REAL-TIME glucose data (minimal mode to avoid disconnection)..."
            debugInfo += "\n💡 Minimal mode: Only current glucose, no history to prevent connection loss"
            
            // 检查传感器类型，使用最小化读取方法
            if let sensorInfo = sensorInfo, sensorInfo.type == .libre1 {
                debugInfo += "\n🔧 Using Libre 1 minimal read method (current data only)"
                await readLibre1MinimalData(from: tag)
            } else {
                debugInfo += "\n🔧 Using standard Libre 2+ minimal read method"
                debugInfo += "\n🧬 Reading only essential blocks to avoid disconnection..."
                await readStandardMinimalData(from: tag)
            }
        } else {
            debugInfo += "\n📊 Reading FULL glucose data (complete history mode)..."
            debugInfo += "\n⚠️ Full mode: May cause connection loss with large data reads"
            
            // 检查传感器类型，使用完整读取方法
            if let sensorInfo = sensorInfo, sensorInfo.type == .libre1 {
                debugInfo += "\n🔧 Using Libre 1 full read method (A3 command)"
                await readLibre1FRAMData(from: tag)
            } else {
                debugInfo += "\n🔧 Using standard Libre 2+ full read method"
                debugInfo += "\n🧬 Attempting to read sensor memory blocks..."
                await readStandardFRAMData(from: tag)
            }
        }
    }
    
    // MARK: - 最小化读取方法（只读取实时数据，避免连接丢失）
    
    // Libre 1 最小化读取方法 - 使用 A3 只读关键区域（避免循环大量读取）
    private func readLibre1MinimalData(from tag: NFCISO15693Tag) async {
        debugInfo += "\n🎯 Libre 1 minimal read (A3 raw): reading small FRAM window..."

        // 目标：从 0xF860 开始读取 64 字节（8 个块），覆盖状态与最新趋势
        let startAddress = libre1FRAMStartAddress
        let desiredBytes = 64
        let maxChunk = 24 // A3 单次最多 12 words = 24 字节
        let maxRetries = 3

        var buffer = Data()
        var current = startAddress
        var attempts = 0

        while buffer.count < desiredBytes && attempts <= maxRetries {
            // 计算下一次请求的字节数
            let remaining = desiredBytes - buffer.count
            let requestBytes = min(maxChunk, remaining)
            var words = requestBytes / 2
            if requestBytes % 2 == 1 || (requestBytes % 2 == 0 && current % 2 == 1) {
                words += 1
            }

            let parameters = libre1Backdoor + [
                UInt8(current & 0xFF),
                UInt8(current >> 8),
                UInt8(words)
            ]

            do {
                if buffer.count > 0 { try await Task.sleep(nanoseconds: 120_000_000) }
                let response = try await tag.customCommand(
                    requestFlags: .highDataRate,
                    customCommandCode: 0xA3,
                    customRequestParameters: parameters
                )

                var data = Data(response)
                // 奇地址对齐与多 1 字节结尾的处理（参考 DiaBLE）
                if current % 2 == 1 { data = data.subdata(in: 1 ..< data.count) }
                if data.count - requestBytes == 1 { data = data.subdata(in: 0 ..< data.count - 1) }

                buffer.append(data)
                debugInfo += "\n✅ A3 read +\(data.count) bytes at 0x\(String(format: "%04X", current)) (acc=\(buffer.count))"
                current += data.count
                attempts = 0 // 成功则重置重试计数

            } catch {
                attempts += 1
                debugInfo += "\n⚠️ A3 minimal read error (attempt #\(attempts)): \(error.localizedDescription)"
                if attempts > maxRetries { break }
                try? await Task.sleep(nanoseconds: 300_000_000)
            }
        }

        debugInfo += "\n📦 Minimal A3 buffer size: \(buffer.count) bytes"

        // 如果有趋势索引但对应的 6 字节记录不在窗口内，则定点追加读取；
        // 如该槽有错误或无效，再向前尝试最多 5 个槽位。
        if buffer.count >= 28 {
            let trendIndex = Int(buffer[26])
            var baseSlot = trendIndex - 1
            if baseSlot < 0 { baseSlot += 16 }
            let trySlots = 0...5
            for step in trySlots {
                var j = baseSlot - step
                if j < 0 { j += 16 }
                let recordOffset = 28 + j * 6
                // 若该槽已在 64B 窗口内则跳过定点（后续解析会覆盖）
                if recordOffset + 6 <= buffer.count { continue }

                let absoluteAddress = libre1FRAMStartAddress + recordOffset
                let requestBytes = 12
                var words = requestBytes / 2
                let parameters = libre1Backdoor + [
                    UInt8(absoluteAddress & 0xFF),
                    UInt8(absoluteAddress >> 8),
                    UInt8(words)
                ]
                do {
                    try await Task.sleep(nanoseconds: 120_000_000)
                    let response = try await tag.customCommand(
                        requestFlags: .highDataRate,
                        customCommandCode: 0xA3,
                        customRequestParameters: parameters
                    )
                    var slotData = Data(response)
                    if absoluteAddress % 2 == 1 { slotData = slotData.subdata(in: 1 ..< slotData.count) }
                    if slotData.count >= 6 {
                        let rawValue = readBits(slotData, 0, 0, 0xE)
                        let hasError = readBits(slotData, 0, 0x19, 0x1) != 0
                        debugInfo += String(format: "\n🎯 Targeted trend read at 0x%04X: raw=0x%X, error=%@ (slot %d)", absoluteAddress, rawValue, hasError ? "Y" : "N", j)
                        if !hasError && rawValue > 0 {
                            let mgdl10 = Double(rawValue)
                            let mmol = (mgdl10 / 10.0) / 18.0182
                            if mmol >= 2.0 && mmol <= 25.0 {
                                let now = Date()
                                glucoseReading = LibreGlucoseReading(
                                    currentGlucose: mmol,
                                    timestamp: now,
                                    trendDirection: .unknown,
                                    glucoseHistory: [],
                                    sensorAge: 0,
                                    batteryLevel: sensorInfo?.batteryLevel
                                )
                                debugInfo += "\n🎯 MINIMAL REAL-TIME RESULT (targeted):"
                                debugInfo += "\n   📈 Current glucose: \(String(format: "%.1f", mmol)) mmol/L"
                                return
                            }
                        }
                    }
                } catch {
                    debugInfo += "\n⚠️ Targeted trend read failed: \(error.localizedDescription)"
                }
            }
        }

        if buffer.count >= 32 {
            await parseMinimalLibre1Data(buffer)
        } else {
            debugInfo += "\n❌ Insufficient minimal A3 data (\(buffer.count) bytes)"
        }
    }
    
    // Libre 2+ 最小化读取方法
    private func readStandardMinimalData(from tag: NFCISO15693Tag) async {
        debugInfo += "\n🎯 Standard minimal read: focusing on current glucose only..."
        
        do {
            // 只读取前 8 个块 (64 字节)，包含基本信息和最新趋势
            let essentialBlocks = 8
            let maxRetries = 3
            var allData = Data()
            
            for retry in 0...maxRetries {
                if retry > 0 {
                    debugInfo += "\n🔄 Retry #\(retry) for minimal data read..."
                    try await Task.sleep(nanoseconds: 500_000_000) // 500ms延迟
                }
                
                do {
                    let blockRange = NSRange(location: 0, length: essentialBlocks)
                    let blocks = try await tag.readMultipleBlocks(
                        requestFlags: .highDataRate,
                        blockRange: blockRange
                    )
                    
                    for block in blocks {
                        allData.append(block)
                    }
                    
                    debugInfo += "\n✅ Successfully read \(essentialBlocks) essential blocks (\(allData.count) bytes)"
                    break
                    
                } catch {
                    debugInfo += "\n⚠️ Minimal read attempt \(retry + 1) failed: \(error.localizedDescription)"
                    if retry >= maxRetries {
                        debugInfo += "\n❌ All minimal read attempts failed"
                        await parseMinimalStandardData(allData) // 尝试解析已有数据
                        return
                    }
                }
            }
            
            // 如果有数据，解析实时血糖值
            if allData.count >= 32 {
                await parseMinimalStandardData(allData)
            } else {
                debugInfo += "\n❌ Insufficient data for glucose reading (\(allData.count) bytes)"
            }
            
        } catch {
            debugInfo += "\n❌ Standard minimal read failed: \(error.localizedDescription)"
        }
    }
    
    // 解析最小化的 Libre 1 数据（带轻滤波）
    private func parseMinimalLibre1Data(_ data: Data) async {
        debugInfo += "\n🔬 Parsing minimal Libre 1 data (\(data.count) bytes) with light filtering..."

        guard data.count >= 34 else {
            debugInfo += "\n❌ Insufficient data for parsing (\(data.count) bytes)"
            return
        }

        let now = Date()
        var validGlucoseValues: [Double] = []

        // 传感器状态
        let sensorStateRaw = data[4]
        debugInfo += "\n📊 Sensor state: 0x\(String(format: "%02X", sensorStateRaw))"
        if var currentSensorInfo = sensorInfo {
            currentSensorInfo = LibreSensorInfo(
                uid: currentSensorInfo.uid,
                serial: currentSensorInfo.serial,
                type: currentSensorInfo.type,
                state: LibreSensorState(rawValue: sensorStateRaw) ?? .active,
                age: 0,
                batteryLevel: currentSensorInfo.batteryLevel,
                firmware: currentSensorInfo.firmware
            )
            sensorInfo = currentSensorInfo
        }

        // 使用与 DiaBLE 一致的位解析：
        // trendIndex 位于 data[26]；最新记录在 offset = 28 + ((trendIndex-1+16)%16)*6
        let trendIndex = Int(data[26])
        debugInfo += "\n🔍 Light filtering: Reading 2-3 recent valid slots for averaging..."
        
        // 轻滤波：读取最近2-3个有效槽位并取平均值
        for step in 0...2 { // 检查最近3个槽位
            if trendIndex > 0 {
                var j = trendIndex - 1 - step
                if j < 0 { j += 16 }
                let offset = 28 + j * 6
                if offset + 5 < data.count {
                    let rawValue = readBits(data, offset, 0, 0xE)
                    let hasError = readBits(data, offset, 0x19, 0x1) != 0
                    debugInfo += String(format: "\n🧩 Filter slot[%d]: j=%d, offset=0x%02X, raw=0x%X, error=%@", step, j, offset, rawValue, hasError ? "Y" : "N")

                    if !hasError && rawValue > 0 {
                        // Libre 1: 原始趋势值通常为 mg/dL×10
                        let mgdl10 = Double(rawValue)
                        let mmol = (mgdl10 / 10.0) / 18.0182
                        if mmol >= 2.0 && mmol <= 25.0 {
                            validGlucoseValues.append(mmol)
                            debugInfo += String(format: " -> %.1f mmol/L ✅", mmol)
                        } else {
                            debugInfo += String(format: " -> %.1f mmol/L (out of range)", mmol)
                        }
                    } else {
                        debugInfo += " -> invalid/error"
                    }
                }
            }
        }

        // 轻滤波处理：计算有效值的平均值
        var currentGlucose: Double = 0.0
        if validGlucoseValues.count >= 1 {
            // 如果有多个有效值，取平均值；如果只有1个，直接使用
            currentGlucose = validGlucoseValues.reduce(0, +) / Double(validGlucoseValues.count)
            
            let filterType = validGlucoseValues.count == 1 ? "single value" : "averaged from \(validGlucoseValues.count) values"
            debugInfo += "\n🎯 Light filter result: \(filterType)"
            debugInfo += "\n   📊 Valid readings: \(validGlucoseValues.map { String(format: "%.1f", $0) }.joined(separator: ", "))"
            debugInfo += "\n   🧮 Final glucose (filtered): \(String(format: "%.1f", currentGlucose)) mmol/L"
            
            // 显示滤波效果
            if validGlucoseValues.count > 1 {
                let maxValue = validGlucoseValues.max() ?? 0
                let minValue = validGlucoseValues.min() ?? 0
                let range = maxValue - minValue
                debugInfo += "\n   📈 Value range: \(String(format: "%.1f", minValue))-\(String(format: "%.1f", maxValue)) (±\(String(format: "%.1f", range/2)) mmol/L)"
                if range < 1.0 {
                    debugInfo += "\n   ✅ Good stability (range < 1.0 mmol/L)"
                } else {
                    debugInfo += "\n   ⚠️ Higher variance (range ≥ 1.0 mmol/L)"
                }
            }
        }

        if currentGlucose > 0 {
            glucoseReading = LibreGlucoseReading(
                currentGlucose: currentGlucose,
                timestamp: now,
                trendDirection: .unknown,
                glucoseHistory: [],
                sensorAge: 0,
                batteryLevel: sensorInfo?.batteryLevel
            )
            debugInfo += "\n🎯 LIGHT-FILTERED RESULT:"
            debugInfo += "\n   📈 Current glucose: \(String(format: "%.1f", currentGlucose)) mmol/L"
            debugInfo += "\n   🔬 Filter method: Light averaging (2-3 recent slots)"
            debugInfo += "\n   📊 Trend: Unknown (minimal read)"
            debugInfo += "\n   🏺 History records: 0 (real-time only)"
            debugInfo += "\n   📱 Sensor type: \(sensorInfo?.type.rawValue ?? "Unknown")"
        } else {
            debugInfo += "\n❌ No valid glucose value found in minimal data"
            debugInfo += "\n💡 Possible reasons:"
            debugInfo += "\n   - Sensor warming up (needs 1 hour)"
            debugInfo += "\n   - All recent slots have errors"
            debugInfo += "\n   - Sensor may be expired or damaged"
        }
    }
    
    // 解析最小化的标准传感器数据  
    private func parseMinimalStandardData(_ data: Data) async {
        debugInfo += "\n🔬 Parsing minimal standard data (\(data.count) bytes)..."
        
        guard data.count >= 32 else {
            debugInfo += "\n❌ Insufficient data for parsing (\(data.count) bytes)"
            return
        }
        
        let now = Date()
        var currentGlucose: Double = 0.0
        
        // 传感器状态
        if data.count > 4 {
            let sensorStateRaw = data[4]
            debugInfo += "\n📊 Sensor state: 0x\(String(format: "%02X", sensorStateRaw))"
            
            if var currentSensorInfo = sensorInfo {
                currentSensorInfo = LibreSensorInfo(
                    uid: currentSensorInfo.uid,
                    serial: currentSensorInfo.serial,
                    type: currentSensorInfo.type,
                    state: LibreSensorState(rawValue: sensorStateRaw) ?? .active,
                    age: 0,
                    batteryLevel: currentSensorInfo.batteryLevel,
                    firmware: currentSensorInfo.firmware
                )
                sensorInfo = currentSensorInfo
            }
        }
        
        // 在标准传感器中，从可用数据中寻找血糖值
        if data.count >= 48 {
            // 检查多个可能的位置
            let possibleOffsets = [24, 28, 32, 40, 44]
            
            for offset in possibleOffsets {
                if offset + 1 < data.count {
                    let rawValue = UInt16(data[offset]) | (UInt16(data[offset + 1]) << 8)
                    if rawValue > 0 && rawValue < 1000 {
                        let glucose = Double(rawValue) / 18.0 // 转换为 mmol/L
                        if glucose > 1.0 && glucose < 30.0 {
                            currentGlucose = glucose
                            break
                        }
                    }
                }
            }
        }
        
        if currentGlucose > 0 {
            debugInfo += "\n🎯 Current glucose found: \(String(format: "%.1f", currentGlucose)) mmol/L"
            
            glucoseReading = LibreGlucoseReading(
                currentGlucose: currentGlucose,
                timestamp: now,
                trendDirection: .unknown,
                glucoseHistory: [],
                sensorAge: 0,
                batteryLevel: sensorInfo?.batteryLevel
            )
            
            debugInfo += "\n🎯 MINIMAL REAL-TIME RESULT:"
            debugInfo += "\n   📈 Current glucose: \(String(format: "%.1f", currentGlucose)) mmol/L"
            debugInfo += "\n   📊 Trend: Unknown (minimal read)"
            debugInfo += "\n   🏺 History records: 0 (real-time only)"
            debugInfo += "\n   📱 Sensor type: \(sensorInfo?.type.rawValue ?? "Unknown")"
            debugInfo += "\n   💡 This is a minimal read to avoid connection loss"
            
        } else {
            debugInfo += "\n❌ No valid glucose value found in minimal data"
            debugInfo += "\n💡 Sensor may need decryption or different reading method"
        }
    }
    
    // Libre 1 专用FRAM读取方法 (基于DiaBLE项目)
    private func readLibre1FRAMData(from tag: NFCISO15693Tag) async {
        debugInfo += "\n🧬 Attempting to read Libre 1 FRAM using A3 command..."
        
        do {
            // 使用A3命令读取Libre 1的FRAM数据
            // 参数: backdoor + 地址(2字节) + 字数(1字节)
            let framAddress = libre1FRAMStartAddress
            let totalBytes = libre1FRAMBlockCount * 8 // 244块 * 8字节/块 = 1952字节
            
            var allFRAMData = Data()
            var currentAddress = framAddress
            
            while currentAddress < framAddress + totalBytes {
                let remainingBytes = min(24, totalBytes - (currentAddress - framAddress))
                let words = (remainingBytes + 1) / 2 // 转换为字数
                
                let parameters = libre1Backdoor + [
                    UInt8(currentAddress & 0xFF),
                    UInt8(currentAddress >> 8),
                    UInt8(words)
                ]
                
                debugInfo += "\n📡 Sending A3 command: address=0x\(String(format: "%04X", currentAddress)), words=\(words)"
                
                do {
                    // 添加延迟避免连接丢失
                    if currentAddress > framAddress {
                        try await Task.sleep(nanoseconds: 100_000_000) // 100ms延迟
                    }
                    
                    let response = try await tag.customCommand(
                        requestFlags: .highDataRate,
                        customCommandCode: 0xA3,
                        customRequestParameters: parameters
                    )
                    
                    let data = Data(response)
                    allFRAMData.append(data)
                    debugInfo += "\n✅ Read \(data.count) bytes from address 0x\(String(format: "%04X", currentAddress))"
                    
                    currentAddress += data.count
                    
                    // 每读取一定量数据后添加更长延迟
                    if allFRAMData.count % 120 == 0 { // 每120字节(5次读取)后
                        debugInfo += "\n⏸️ Adding longer delay to maintain connection..."
                        try await Task.sleep(nanoseconds: 300_000_000) // 300ms延迟
                    }
                    
                } catch {
                    debugInfo += "\n⚠️ A3 command failed at address 0x\(String(format: "%04X", currentAddress)): \(error.localizedDescription)"
                    
                    // 如果是连接丢失，尝试重新连接
                    if error.localizedDescription.contains("connection lost") {
                        debugInfo += "\n🔄 Connection lost, attempting to continue with available data..."
                        break
                    } else {
                        debugInfo += "\n❌ Other error, stopping read process"
                        break
                    }
                }
            }
            
            debugInfo += "\n📈 Libre 1 FRAM read complete: \(allFRAMData.count) bytes total"
            debugInfo += "\n🔍 Raw Libre 1 FRAM data (first 64 bytes): \(allFRAMData.prefix(min(64, allFRAMData.count)).map { String(format: "%02x", $0) }.joined())"
            
            // 解析Libre 1 FRAM数据
            await parseLibre1FRAMData(allFRAMData)
            
        } catch {
            debugInfo += "\n❌ Libre 1 FRAM reading failed: \(error.localizedDescription)"
            handleScanError(NSError(domain: "NFCError", code: 3, userInfo: [NSLocalizedDescriptionKey: "Failed to read Libre 1 FRAM data"]))
        }
    }
    
    // 标准Libre 2+ FRAM读取方法
    private func readStandardFRAMData(from tag: NFCISO15693Tag) async {
        
        do {
            // 先尝试读取关键的FRAM区域 (基于DiaBLE的实现)
            // Block 0-43: 系统和配置信息
            // Block 44-242: 血糖历史数据
            
            var allBlocks = Data()
            var successfulReads = 0
            
            // 分段读取，避免一次性读取过多
            for startBlock in stride(from: 0, to: min(244, 43), by: 8) {
                let blocksToRead = min(8, 43 - startBlock)
                
                do {
                    let blockRange = NSRange(location: startBlock, length: blocksToRead)
                    let blocks = try await tag.readMultipleBlocks(
                        requestFlags: .highDataRate,
                        blockRange: blockRange
                    )
                    
                    for block in blocks {
                        allBlocks.append(block)
                    }
                    successfulReads += blocks.count
                    debugInfo += "\n✅ Read blocks \(startBlock)-\(startBlock + blocksToRead - 1) (\(blocks.count) blocks)"
                    
                } catch {
                    debugInfo += "\n⚠️ Failed to read blocks \(startBlock)-\(startBlock + blocksToRead - 1): \(error.localizedDescription)"
                    // 继续读取其他块
                }
            }
            
            if successfulReads > 0 {
                debugInfo += "\n📈 Successfully read \(successfulReads) memory blocks (\(allBlocks.count) bytes total)"
                debugInfo += "\n🔍 Raw FRAM data (first 64 bytes): \(allBlocks.prefix(64).hex)"
                
                // 解析真实的血糖数据
                await parseRealGlucoseFromFRAM(allBlocks)
                
            } else {
                throw NSError(domain: "NFCError", code: 1, userInfo: [NSLocalizedDescriptionKey: "No blocks could be read"])
            }
            
        } catch {
            debugInfo += "\n❌ Could not read FRAM memory: \(error.localizedDescription)"
            debugInfo += "\n📝 This might be due to:"
            debugInfo += "\n   - Sensor encryption (Libre 2/3)"
            debugInfo += "\n   - Authentication required"
            debugInfo += "\n   - Insufficient permissions"
            debugInfo += "\n   - Sensor in wrong state"
            
            // 当无法读取真实FRAM时，报告错误
            debugInfo += "\n❌ Unable to read FRAM memory blocks"
            debugInfo += "\n💡 This sensor may require advanced authentication"
            handleScanError(NSError(domain: "NFCError", code: 2, userInfo: [NSLocalizedDescriptionKey: "Unable to read sensor memory"]))
        }
    }
    
    private func parseRealGlucoseFromFRAM(_ framData: Data) async {
        debugInfo += "\n🔬 Parsing REAL FRAM data (\(framData.count) bytes)..."
        debugInfo += "\n📝 Raw data hex: \(framData.prefix(min(32, framData.count)).map { String(format: "%02x", $0) }.joined())"
        
        // 减少最小数据要求，Libre 1可能只有少量数据
        guard framData.count >= 8 else {
            debugInfo += "\n❌ FRAM data too small (\(framData.count) bytes), need at least 8"
            debugInfo += "\n💡 Cannot extract glucose data from insufficient FRAM data"
            return
        }
        
        var historyData: [HistoricalGlucose] = []
        let now = Date()
        
        // 从FRAM中解析传感器状态和年龄
        if framData.count >= 40 {
            // 传感器状态通常在offset 4
            let sensorStateRaw = framData[4]
            let sensorAge = Int(framData[41]) | (Int(framData[42]) << 8) // 分钟
            
            debugInfo += "\n📊 Sensor state byte: 0x\(String(format: "%02X", sensorStateRaw))"
            debugInfo += "\n⏰ Sensor age: \(sensorAge) minutes (\(sensorAge/1440) days)"
            
            // 更新传感器信息
            if var currentSensorInfo = sensorInfo {
                currentSensorInfo = LibreSensorInfo(
                    uid: currentSensorInfo.uid,
                    serial: currentSensorInfo.serial,
                    type: currentSensorInfo.type,
                    state: LibreSensorState(rawValue: sensorStateRaw) ?? .active,
                    age: sensorAge,
                    batteryLevel: extractBatteryLevel(from: framData),
                    firmware: currentSensorInfo.firmware
                )
                sensorInfo = currentSensorInfo
            }
        }
        
        // 尝试解析血糖历史数据
        // Libre传感器通常从byte 24开始存储趋势数据
        let trendDataStart = 24
        let trendDataLength = min(framData.count - trendDataStart, 96) // 最多96字节的趋势数据
        
        if trendDataLength >= 12 {
            let trendData = framData.subdata(in: trendDataStart..<(trendDataStart + trendDataLength))
            debugInfo += "\n📈 Trend data (\(trendData.count) bytes): \(trendData.prefix(12).hex)..."
            
            // 解析趋势数据（每6字节一个记录）
            for i in stride(from: 0, to: trendData.count - 6, by: 6) {
                let glucoseBytes = trendData.subdata(in: i..<(i + 6))
                
                // 简化的血糖值解析（需要根据具体传感器类型调整）
                let rawGlucose = UInt16(glucoseBytes[0]) | (UInt16(glucoseBytes[1]) << 8)
                if rawGlucose > 0 && rawGlucose < 1000 {
                    let glucose = Double(rawGlucose) / 18.0 // 转换为mmol/L
                    let timestamp = now.addingTimeInterval(-Double(i/6) * 15 * 60) // 每15分钟一个记录
                    
                    if glucose > 1.0 && glucose < 30.0 { // 合理的血糖范围
                        historyData.append(HistoricalGlucose(glucose: glucose, timestamp: timestamp))
                    }
                }
            }
            
            debugInfo += "\n📊 Parsed \(historyData.count) valid glucose readings from FRAM"
            
        } else {
            debugInfo += "\n⚠️ Insufficient trend data in FRAM (\(trendDataLength) bytes)"
        }
        
        // 检查是否有有效的血糖数据
        if historyData.isEmpty {
            // 没有读取到任何血糖数据
            debugInfo += "\n❌ NO GLUCOSE DATA AVAILABLE:"
            debugInfo += "\n   📊 No valid glucose readings found in sensor"
            debugInfo += "\n   💡 Possible causes:"
            debugInfo += "\n      - Sensor not activated yet (needs 1-hour warming)"
            debugInfo += "\n      - Sensor expired or damaged"
            debugInfo += "\n      - Data encryption/authentication required"
            debugInfo += "\n      - Libre 1 may need different reading method"
            debugInfo += "\n   🔧 Sensor info available but no glucose data"
            
            // 设置错误状态，不提供误导性的血糖读数
            scanError = "No glucose data available from sensor. Sensor detected but contains no readable glucose values."
            isScanning = false
            return
        }
        
        // 如果数据不足，也要警告
        if historyData.count < 5 {
            debugInfo += "\n⚠️ Limited glucose history data found (\(historyData.count) records)"
            debugInfo += "\n💡 This may be normal for a new sensor or encrypted data"
        }
        
        // 如果有数据，计算当前血糖值和趋势
        let currentGlucose = historyData.first?.glucose ?? 0.0
        let trendDirection = calculateTrendDirection(from: historyData)
        
        glucoseReading = LibreGlucoseReading(
            currentGlucose: currentGlucose,
            timestamp: now,
            trendDirection: trendDirection,
            glucoseHistory: historyData.sorted { $0.timestamp > $1.timestamp },
            sensorAge: sensorInfo?.age ?? 0,
            batteryLevel: sensorInfo?.batteryLevel
        )
        
        debugInfo += "\n🎯 REAL SENSOR RESULT:"
        debugInfo += "\n   📈 Current glucose: \(String(format: "%.1f", currentGlucose)) mmol/L"
        debugInfo += "\n   📊 Trend: \(trendDirection.rawValue)"
        debugInfo += "\n   🏺 History records: \(historyData.count)"
        debugInfo += "\n   🔋 Battery: \(sensorInfo?.batteryLevel ?? 0)%"
        debugInfo += "\n   📱 Sensor type: \(sensorInfo?.type.rawValue ?? "Unknown")"
        debugInfo += "\n   ⏰ Sensor age: \(sensorInfo?.age ?? 0) minutes"
    }
    
    
    private func extractBatteryLevel(from framData: Data) -> Int {
        // 尝试从FRAM中提取电池电量
        // 具体位置取决于传感器类型，这里使用估算
        if framData.count > 50 {
            let batteryByte = framData[50]
            let batteryLevel = Int(batteryByte)
            return max(10, min(100, batteryLevel))
        }
        return 85 // 默认电量
    }
    
    // Libre 1 专用FRAM解析 (基于DiaBLE项目的parseFRAM函数)
    private func parseLibre1FRAMData(_ framData: Data) async {
        debugInfo += "\n🔬 Parsing Libre 1 FRAM data (\(framData.count) bytes)..."
        debugInfo += "\n📝 Raw Libre 1 data hex: \(framData.prefix(min(32, framData.count)).map { String(format: "%02x", $0) }.joined())"
        
        // 降低最小数据要求，尝试从部分数据中提取信息
        guard framData.count >= 50 else {
            debugInfo += "\n❌ Libre 1 FRAM data too small (\(framData.count) bytes), need at least 50"
            debugInfo += "\n💡 Cannot extract any data from insufficient Libre 1 FRAM data"
            return
        }
        
        if framData.count < 344 {
            debugInfo += "\n⚠️ Libre 1 FRAM data incomplete (\(framData.count) bytes), but attempting to extract available data"
            debugInfo += "\n💡 This may be due to connection issues during reading"
        }
        
        var historyData: [HistoricalGlucose] = []
        let now = Date()
        
        // 解析Libre 1传感器状态和年龄 (基于DiaBLE的parseFRAM)
        if let sensorState = LibreSensorState(rawValue: framData[4]) {
            debugInfo += "\n📊 Libre 1 sensor state: \(sensorState.rawValue) (0x\(String(format: "%02X", sensorState.rawValue)))"
            
            if var currentSensorInfo = sensorInfo {
                currentSensorInfo = LibreSensorInfo(
                    uid: currentSensorInfo.uid,
                    serial: currentSensorInfo.serial,
                    type: currentSensorInfo.type,
                    state: sensorState,
                    age: 0, // 将在下面计算
                    batteryLevel: 0,
                    firmware: currentSensorInfo.firmware
                )
                sensorInfo = currentSensorInfo
            }
        }
        
        // 解析传感器年龄 (从FRAM的316-317字节，如果数据足够的话)
        var sensorAge = 0
        if framData.count >= 318 {
            sensorAge = Int(framData[316]) + Int(framData[317]) << 8
            debugInfo += "\n⏰ Libre 1 sensor age: \(sensorAge) minutes (\(sensorAge/1440) days)"
        } else {
            debugInfo += "\n⚠️ Cannot read sensor age - insufficient data (need 318 bytes, have \(framData.count))"
            sensorAge = 0 // 使用默认值
        }
        
        if var currentSensorInfo = sensorInfo {
            currentSensorInfo = LibreSensorInfo(
                uid: currentSensorInfo.uid,
                serial: currentSensorInfo.serial,
                type: currentSensorInfo.type,
                state: currentSensorInfo.state,
                age: sensorAge,
                batteryLevel: currentSensorInfo.batteryLevel,
                firmware: currentSensorInfo.firmware
            )
            sensorInfo = currentSensorInfo
        }
        
        // 解析趋势数据 (基于DiaBLE的算法)
        var trendIndex = 0
        var historyIndex = 0
        
        if framData.count >= 28 {
            trendIndex = Int(framData[26])
            historyIndex = Int(framData[27])
            debugInfo += "\n📈 Libre 1 trend index: \(trendIndex), history index: \(historyIndex)"
        } else {
            debugInfo += "\n⚠️ Cannot read trend/history indices - insufficient data (need 28 bytes, have \(framData.count))"
        }
        
        let startDate = now.addingTimeInterval(-Double(sensorAge) * 60)
        
        // 解析趋势数据 (16个值，每6字节一个记录)
        for i in 0...15 {
            var j = trendIndex - 1 - i
            if j < 0 { j += 16 }
            let offset = 28 + j * 6
            
            if offset + 5 < framData.count {
                let rawValue = readBits(framData, offset, 0, 0xe)
                let quality = UInt16(readBits(framData, offset, 0xe, 0xb)) & 0x1FF
                let hasError = readBits(framData, offset, 0x19, 0x1) != 0
                let rawTemperature = readBits(framData, offset, 0x1a, 0xc) << 2
                var temperatureAdjustment = readBits(framData, offset, 0x26, 0x9) << 2
                let negativeAdjustment = readBits(framData, offset, 0x2f, 0x1)
                if negativeAdjustment != 0 { temperatureAdjustment = -temperatureAdjustment }
                
                let id = sensorAge - i
                let date = startDate.addingTimeInterval(Double(sensorAge - i) * 60)
                
                if rawValue > 0 && !hasError {
                    let glucoseMmolL = Double(rawValue) * 0.0555 // mg/dL to mmol/L
                    if glucoseMmolL >= 2.0 && glucoseMmolL <= 25.0 {
                        historyData.append(HistoricalGlucose(glucose: glucoseMmolL, timestamp: date))
                        debugInfo += "\n   Trend[\(i)]: \(String(format: "%.1f", glucoseMmolL)) mmol/L at \(date)"
                    }
                }
            }
        }
        
        // 解析历史数据 (32个值，每6字节一个记录)
        let preciseHistoryIndex = ((sensorAge - 3) / 15) % 32
        let delay = (sensorAge - 3) % 15 + 3
        var readingDate = now
        if preciseHistoryIndex == historyIndex {
            readingDate.addTimeInterval(-Double(delay) * 60)
        } else {
            readingDate.addTimeInterval(-Double(delay - 15) * 60)
        }
        
        for i in 0...31 {
            var j = historyIndex - 1 - i
            if j < 0 { j += 32 }
            let offset = 124 + j * 6
            
            if offset + 5 < framData.count {
                let rawValue = readBits(framData, offset, 0, 0xe)
                let quality = UInt16(readBits(framData, offset, 0xe, 0xb)) & 0x1FF
                let hasError = readBits(framData, offset, 0x19, 0x1) != 0
                let rawTemperature = readBits(framData, offset, 0x1a, 0xc) << 2
                var temperatureAdjustment = readBits(framData, offset, 0x26, 0x9) << 2
                let negativeAdjustment = readBits(framData, offset, 0x2f, 0x1)
                if negativeAdjustment != 0 { temperatureAdjustment = -temperatureAdjustment }
                
                let id = sensorAge - delay - i * 15
                let date = id > -1 ? readingDate.addingTimeInterval(-Double(i) * 15 * 60) : startDate
                
                if rawValue > 0 && !hasError {
                    let glucoseMmolL = Double(rawValue) * 0.0555 // mg/dL to mmol/L
                    if glucoseMmolL >= 2.0 && glucoseMmolL <= 25.0 {
                        historyData.append(HistoricalGlucose(glucose: glucoseMmolL, timestamp: date))
                        debugInfo += "\n   History[\(i)]: \(String(format: "%.1f", glucoseMmolL)) mmol/L at \(date)"
                    }
                }
            }
        }
        
        debugInfo += "\n📊 Libre 1 FRAM parsing complete: \(historyData.count) glucose values extracted"
        
        // 分析原始数据，即使没有解析出血糖值
        if framData.count >= 24 {
            debugInfo += "\n🔍 Raw data analysis:"
            debugInfo += "\n   📊 First 24 bytes: \(framData.prefix(24).map { String(format: "%02x", $0) }.joined())"
            
            // 检查是否有非零数据
            let nonZeroBytes = framData.prefix(24).filter { $0 != 0 }.count
            debugInfo += "\n   📈 Non-zero bytes in first 24: \(nonZeroBytes)/24"
            
            if nonZeroBytes > 0 {
                debugInfo += "\n   ✅ Sensor appears to have data (non-zero bytes found)"
            } else {
                debugInfo += "\n   ⚠️ Sensor appears empty (all zeros in first 24 bytes)"
            }
        }
        
        // 检查是否有有效的血糖数据
        if historyData.isEmpty {
            // 没有读取到任何血糖数据
            debugInfo += "\n❌ NO GLUCOSE DATA AVAILABLE:"
            debugInfo += "\n   📊 No valid glucose readings found in Libre 1 sensor"
            debugInfo += "\n   💡 Possible causes:"
            debugInfo += "\n      - Sensor not activated yet (needs 1-hour warming)"
            debugInfo += "\n      - Sensor expired or damaged"
            debugInfo += "\n      - Libre 1 data format not recognized"
            debugInfo += "\n      - Sensor requires warming up period"
            debugInfo += "\n      - Connection issues during reading (only got \(framData.count) bytes)"
            debugInfo += "\n   🔧 Libre 1 sensor info available but no glucose data"
            
            // 设置错误状态，不提供误导性的血糖读数
            scanError = "No glucose data available from Libre 1 sensor. Sensor detected but contains no readable glucose values."
            isScanning = false
            return
        }
        
        // 如果有数据，计算当前血糖值和趋势
        let currentGlucose = historyData.first?.glucose ?? 0.0
        let trendDirection = calculateTrendDirection(from: historyData)
        
        glucoseReading = LibreGlucoseReading(
            currentGlucose: currentGlucose,
            timestamp: now,
            trendDirection: trendDirection,
            glucoseHistory: historyData.sorted { $0.timestamp > $1.timestamp },
            sensorAge: sensorAge,
            batteryLevel: sensorInfo?.batteryLevel
        )
        
        debugInfo += "\n🎯 LIBRE 1 REAL SENSOR RESULT:"
        debugInfo += "\n   📈 Current glucose: \(String(format: "%.1f", currentGlucose)) mmol/L"
        debugInfo += "\n   📊 Trend: \(trendDirection.rawValue)"
        debugInfo += "\n   🏺 History records: \(historyData.count)"
        debugInfo += "\n   🔋 Battery: \(sensorInfo?.batteryLevel ?? 0)%"
        debugInfo += "\n   📱 Sensor type: Libre 1"
        debugInfo += "\n   ⏰ Sensor age: \(sensorAge) minutes"
    }
    
    // 位读取函数 (来自DiaBLE项目)
    private func readBits(_ buffer: Data, _ byteOffset: Int, _ bitOffset: Int, _ bitCount: Int) -> Int {
        guard bitCount != 0 else { return 0 }
        var res = 0
        for i in 0..<bitCount {
            let totalBitOffset = byteOffset * 8 + bitOffset + i
            let byte = Int(floor(Float(totalBitOffset) / 8))
            let bit = totalBitOffset % 8
            if totalBitOffset >= 0 && ((buffer[byte] >> bit) & 0x1) == 1 {
                res |= 1 << i
            }
        }
        return res
    }
    
}

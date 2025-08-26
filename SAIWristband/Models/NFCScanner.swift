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
    
    private var nfcSession: NFCNDEFReaderSession?
    
    override init() {
        super.init()
        checkNFCAvailability()
    }
    
    private func checkNFCAvailability() {
        isNFCAvailable = NFCNDEFReaderSession.readingAvailable
    }
    
    func startScanning() {
        guard isNFCAvailable else {
            scanError = "NFC not available on this device"
            return
        }
        
        isScanning = true
        scanError = ""
        scannedData = ""
        
        nfcSession = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: false)
        nfcSession?.alertMessage = "Hold iPhone near the glucose monitoring device"
        nfcSession?.begin()
    }
    
    func stopScanning() {
        nfcSession?.invalidate()
        isScanning = false
    }
}

// MARK: - NFCNDEFReaderSessionDelegate
extension NFCScanner: NFCNDEFReaderSessionDelegate {
    nonisolated func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        for message in messages {
            for record in message.records {
                if let payload = String(data: record.payload, encoding: .utf8) {
                    Task { @MainActor in
                        self.scannedData = payload
                        self.isScanning = false
                        self.scanError = ""
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
                case .readerSessionInvalidationErrorUserCanceled:
                    self.scanError = "Scan cancelled by user"
                default:
                    self.scanError = "Scan failed: \(error.localizedDescription)"
                }
            } else {
                self.scanError = "Scan error: \(error.localizedDescription)"
            }
        }
    }
    
    nonisolated func readerSession(_ session: NFCNDEFReaderSession, didDetect tags: [NFCNDEFTag]) {
        guard let firstTag = tags.first else {
            session.invalidate(errorMessage: "No NFC tag detected")
            return
        }
        
        session.connect(to: firstTag) { error in
            if let error = error {
                session.invalidate(errorMessage: "Failed to connect to NFC tag: \(error.localizedDescription)")
                return
            }
            
            firstTag.readNDEF { message, error in
                if let error = error {
                    session.invalidate(errorMessage: "Failed to read NFC data: \(error.localizedDescription)")
                    return
                }
                
                if let message = message {
                    session.alertMessage = "Reading device data..."
                    Task { @MainActor in
                        await self.readNDEFMessage(message, session: session)
                    }
                } else {
                    session.invalidate(errorMessage: "NFC tag is empty")
                }
            }
        }
    }
    
    private func readNDEFMessage(_ message: NFCNDEFMessage, session: NFCNDEFReaderSession) async {
        for record in message.records {
            if let payload = String(data: record.payload, encoding: .utf8) {
                self.scannedData = payload
                session.alertMessage = "Scan successful!"
                session.invalidate()
                return
            }
        }
        
        session.invalidate(errorMessage: "Unable to parse NFC data")
    }
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

//
//  LibreModels.swift
//  SAIWristband
//
//  Created by golfy xiong on 2025/1/16.
//

import Foundation

// MARK: - 雅培传感器类型
enum LibreSensorType: String, CaseIterable {
    case libre1 = "Libre 1"
    case libre2 = "Libre 2" 
    case libre3 = "Libre 3"
    case unknown = "Unknown"
    
    init(patchInfo: Data) {
        guard !patchInfo.isEmpty else {
            self = .unknown
            return
        }
        
        switch patchInfo[0] {
        case 0xDF, 0xA2:
            self = .libre1
        case 0x9D, 0xC5:
            self = .libre2
        default:
            if patchInfo.count == 24 {
                self = .libre3
            } else {
                self = .unknown
            }
        }
    }
}

// MARK: - 传感器状态
enum LibreSensorState: UInt8, CaseIterable {
    case unknown = 0
    case notActivated = 1
    case warmingUp = 2
    case active = 3
    case expired = 4
    case shutdown = 5
    case failure = 6
    
    var description: String {
        switch self {
        case .unknown: return "Unknown"
        case .notActivated: return "Not Activated"
        case .warmingUp: return "Warming Up"
        case .active: return "Active"
        case .expired: return "Expired"
        case .shutdown: return "Shutdown"
        case .failure: return "Failure"
        }
    }
}

// MARK: - 血糖测量数据
struct LibreGlucoseValue: Identifiable, Codable {
    let id: Int
    let date: Date
    let rawValue: Int
    var value: Int // mg/dL * 10
    var source: String
    
    init(rawValue: Int, id: Int = 0, date: Date = Date()) {
        self.id = id
        self.date = date
        self.rawValue = rawValue
        self.value = rawValue / 10
        self.source = "DiaBLE"
    }
    
    // 血糖值（mmol/L）
    var glucoseInMmolL: Double {
        return Double(value) / 18.0182
    }
    
    // 血糖值（mg/dL）
    var glucoseInMgdL: Double {
        return Double(value)
    }
}

// MARK: - 传感器信息
struct LibreSensorInfo {
    let uid: Data
    let serial: String
    let type: LibreSensorType
    let state: LibreSensorState
    let age: Int // 分钟
    let batteryLevel: Int?
    let firmware: String
    
    // 生成序列号
    static func generateSerial(from uid: Data) -> String {
        guard uid.count >= 6 else { return "Unknown" }
        let serialData = uid.prefix(6)
        return serialData.map { String(format: "%02X", $0) }.joined()
    }
}

// MARK: - 扩展方便访问
extension Data {
    var hex: String {
        return map { String(format: "%02x", $0) }.joined()
    }
    
    func hexDump(header: String = "") -> String {
        var result = header.isEmpty ? "" : "\(header)\n"
        
        for i in stride(from: 0, to: count, by: 8) {
            let end = Swift.min(i + 8, count)
            let blockData = self[i..<end]
            
            result += String(format: "%04X: ", i)
            result += blockData.map { String(format: "%02X", $0) }.joined(separator: " ")
            result += "\n"
        }
        
        return result
    }
}

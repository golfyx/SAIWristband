//
//  ProfileData.swift
//  SAIWristband
//
//  Created by golfy xiong on 2025/8/22.
//

import SwiftUI
import Foundation

// MARK: - 用户详细信息
struct UserProfile {
    let name: String
    let age: Int
    let height: Int // cm
    let weight: Double // kg
    let avatarImage: String?
}

// MARK: - 健康报告
struct HealthReport {
    let title: String
    let description: [String]
    let image: String
}

// MARK: - 健康奖牌
struct HealthMedals {
    let title: String
    let description: String
}

// MARK: - 成就项目
struct Achievement {
    let id: String
    let title: String
    let value: String
    let icon: String
    let medalName: String
}

// MARK: - 记录值项目
struct RecordItem {
    let title: String
    let value: String
    let hasBottomLine: Bool
}

// MARK: - 提醒
struct Reminder {
    let title: String
    let content: String
    let time: String
    let icon: String
    let isEnabled: Bool
}

// MARK: - 样本数据
extension UserProfile {
    static let sampleData = UserProfile(
        name: "Jessica",
        age: 29,
        height: 166,
        weight: 52.0,
        avatarImage: "user_avatar"
    )
}

extension HealthReport {
    static let sampleData = HealthReport(
        title: "Health Report",
        description: [
            "Share a PDF file of your data",
            "with your doctor, coach, or",
            "family and friends"
        ],
        image: "health_report_image"
    )
}

extension HealthMedals {
    static let sampleData = HealthMedals(
        title: "My health goals",
        description: "I want to lose weight\nWhether you want to gain weight, lose weight, or maintain weight, striving to achieve your goals has always been a good idea"
    )
}

extension Achievement {
    static let sampleData: [Achievement] = [
        Achievement(
            id: "1",
            title: "Distance: 3 km",
            value: "Distance: 3 km",
            icon: "medal_icon_1",
            medalName: "Medal 1"
        ),
        Achievement(
            id: "2",
            title: "Steps: 10,000",
            value: "Steps: 10,000",
            icon: "medal_icon_2",
            medalName: "Medal 2"
        ),
        Achievement(
            id: "3",
            title: "Calorie: 800",
            value: "Calorie: 800",
            icon: "medal_icon_3",
            medalName: "Medal 3"
        )
    ]
}

extension RecordItem {
    static let sampleData: [RecordItem] = [
        RecordItem(title: "Step", value: "387 235", hasBottomLine: true),
        RecordItem(title: "Distance", value: "412.3 KM", hasBottomLine: true),
        RecordItem(title: "Best Record", value: "15,231 steps", hasBottomLine: true),
        RecordItem(title: "Days with more than\n10,000 steps", value: "7", hasBottomLine: false)
    ]
}

extension Reminder {
    static let sampleData = Reminder(
        title: "Reminder",
        content: "Measuring ECG",
        time: "Tue, Wed, Sun, 19:00.",
        icon: "heart.fill",
        isEnabled: true
    )
}

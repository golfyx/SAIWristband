//
//  AppState.swift
//  SAIWristband
//
//  Created by golfy xiong on 2025/8/22.
//

import SwiftUI
import Combine

// MARK: - 标签项枚举
enum TabItem: String, CaseIterable {
    case home = "首页"
    case health = "健康"
    case share = "分享"
    
    var iconName: String {
        switch self {
        case .home:
            return "house.fill"
        case .health:
            return "heart.fill"
        case .share:
            return "square.and.arrow.up.fill"
        }
    }
    
    var iconNameUnselected: String {
        switch self {
        case .home:
            return "house"
        case .health:
            return "heart"
        case .share:
            return "square.and.arrow.up"
        }
    }
}

// MARK: - 应用状态管理
class AppState: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var currentUser: User?
    @Published var hasCompletedOnboarding: Bool = false
    @Published var selectedTab: TabItem = .home
    
    // 初始化时检查用户登录状态
    init() {
        checkLoginStatus()
    }
    
    private func checkLoginStatus() {
        // 检查UserDefaults中保存的登录状态
        let savedLoginStatus = UserDefaults.standard.bool(forKey: "isLoggedIn")
        let savedUserData = UserDefaults.standard.data(forKey: "currentUser")
        
        if savedLoginStatus && savedUserData != nil {
            // 尝试解码保存的用户数据
            if let user = try? JSONDecoder().decode(User.self, from: savedUserData!) {
                self.currentUser = user
                self.isLoggedIn = true
            } else {
                // 如果用户数据解码失败，清除登录状态
                self.isLoggedIn = false
                self.currentUser = nil
                UserDefaults.standard.removeObject(forKey: "isLoggedIn")
                UserDefaults.standard.removeObject(forKey: "currentUser")
            }
        } else {
            self.isLoggedIn = false
            self.currentUser = nil
        }
        self.hasCompletedOnboarding = false
    }
    
    func login(user: User) {
        self.currentUser = user
        self.isLoggedIn = true
        
        // 保存登录状态和用户数据到UserDefaults
        UserDefaults.standard.set(true, forKey: "isLoggedIn")
        if let userData = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(userData, forKey: "currentUser")
        }
    }
    
    func logout() {
        self.currentUser = nil
        self.isLoggedIn = false
        
        // 清除登录状态和用户数据
        UserDefaults.standard.removeObject(forKey: "isLoggedIn")
        UserDefaults.standard.removeObject(forKey: "currentUser")
    }
}

// MARK: - 用户模型
struct User: Codable {
    let id: String
    let name: String
    let email: String
    let avatarURL: String?
    
    static let sampleUser = User(
        id: "1",
        name: "Jessica",
        email: "jessica@example.com",
        avatarURL: nil
    )
}

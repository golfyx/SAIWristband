//
//  Theme.swift
//  SAIWristband
//
//  全局主题与玻璃背景适配（暗黑模式 + iOS 18 Glass 回退到 Material）
//

import SwiftUI

// MARK: - 主题颜色
enum AppTheme {
    // MARK: - 基础颜色
    static var primary: Color { Color(red: 123/255, green: 43/255, blue: 177/255) }
    static var accent: Color { Color(red: 0.60, green: 0.39, blue: 0.95) }
    static var separator: Color { Color(.separator) }
    
    // MARK: - 主题色系
    static var primary1: Color { Color(hex: "#A081D9") }
    static var primary2: Color { Color(hex: "#E3CEF2") }
    static var primary3: Color { Color(hex: "#EDE6F2") }
    static var primary4: Color { Color(hex: "#701E98") }
    static var primary5: Color { Color(hex: "#440076") }
    static var primary6: Color { Color(hex: "#9E4598") }
    static var primary7: Color { Color(hex: "#5B009D") }
    static var primary8: Color { Color(hex: "#9A1AF2") }
    static var primary9: Color { Color(hex: "#701EA6") }
    static var primary10: Color { Color(hex: "#FCF5FF") }
    static var primary11: Color { Color(hex: "#BD98D1") }
    static var primary12: Color { Color(hex: "#9B4F96") }
    static var primary13: Color { Color(hex: "#D5B5D3") }
    static var primary14: Color { Color(hex: "#FFFEF5") }
    
    // MARK: - 白天/夜晚模式背景色
    static func background(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color.black : Color.white
    }
    
    static func secondaryBackground(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color(red: 0.1, green: 0.1, blue: 0.1) : Color(red: 0.98, green: 0.98, blue: 0.98)
    }
    
    // MARK: - 白天/夜晚模式卡片背景色
    static func cardBackground(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color(red: 0.15, green: 0.15, blue: 0.15) : Color.white
    }
    
    static func elevatedCardBackground(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color(red: 0.2, green: 0.2, blue: 0.2) : Color(red: 0.97, green: 0.96, blue: 1.0)
    }
    
    static func elevatedCard111Background(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color(red: 0.2, green: 0.2, blue: 0.2) : Color(hex: "#C091E0")
    }
    
    // MARK: - 白天/夜晚模式特殊卡片背景色
    static func card1Background(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color(red: 0.15, green: 0.15, blue: 0.15) : primary1
    }
    static func card2Background(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color(red: 0.15, green: 0.15, blue: 0.15) : primary2
    }
    static func card3Background(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color(red: 0.15, green: 0.15, blue: 0.15) : primary3
    }
    static func card4Background(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color(red: 0.15, green: 0.15, blue: 0.15) : primary4
    }
    static func card5Background(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color(red: 0.15, green: 0.15, blue: 0.15) : primary5
    }
    static func card6Background(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color(red: 0.15, green: 0.15, blue: 0.15) : primary6
    }
    static func card7Background(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color(red: 0.15, green: 0.15, blue: 0.15) : primary7
    }
    static func card8Background(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color(red: 0.15, green: 0.15, blue: 0.15) : primary8
    }
    static func card9Background(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color(red: 0.15, green: 0.15, blue: 0.15) : primary9
    }
    static func card10Background(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color(red: 0.15, green: 0.15, blue: 0.15) : primary10
    }
    static func card11Background(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color(red: 0.15, green: 0.15, blue: 0.15) : primary11
    }
    static func card12Background(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color(red: 0.15, green: 0.15, blue: 0.15) : primary12
    }
    static func card13Background(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color(red: 0.15, green: 0.15, blue: 0.15) : primary13
    }
    static func card14Background(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color(red: 0.15, green: 0.15, blue: 0.15) : primary14
    }
    
    // MARK: - 白天/夜晚模式提升卡片背景色
    static func elevatedCard1Background(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color(red: 0.2, green: 0.2, blue: 0.2) : primary1
    }
    static func elevatedCard2Background(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color(red: 0.2, green: 0.2, blue: 0.2) : primary2
    }
    static func elevatedCard3Background(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color(red: 0.2, green: 0.2, blue: 0.2) : primary3
    }
    static func elevatedCard4Background(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color(red: 0.2, green: 0.2, blue: 0.2) : primary4
    }
    static func elevatedCard5Background(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color(red: 0.2, green: 0.2, blue: 0.2) : primary5
    }
    static func elevatedCard6Background(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color(red: 0.2, green: 0.2, blue: 0.2) : primary6
    }
    static func elevatedCard27Background(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color(red: 0.2, green: 0.2, blue: 0.2) : primary7
    }
    static func elevatedCard8Background(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color(red: 0.2, green: 0.2, blue: 0.2) : primary8
    }
    static func elevatedCard9Background(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color(red: 0.2, green: 0.2, blue: 0.2) : primary9
    }
    static func elevatedCard10Background(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color(red: 0.2, green: 0.2, blue: 0.2) : primary10
    }
    static func elevatedCard11Background(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color(red: 0.2, green: 0.2, blue: 0.2) : primary11
    }
    static func elevatedCard12Background(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color(red: 0.2, green: 0.2, blue: 0.2) : primary12
    }
    static func elevatedCard13Background(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color(red: 0.2, green: 0.2, blue: 0.2) : primary13
    }
    static func elevatedCard14Background(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color(red: 0.2, green: 0.2, blue: 0.2) : primary14
    }
    
    // MARK: - 白天/夜晚模式文字颜色
    static func primaryText(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color.white : Color.black
    }
    
    static func secondaryText(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color.white.opacity(0.8) : Color(red: 0.24, green: 0.24, blue: 0.24)
    }
    
    static func tertiaryText(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color.white.opacity(0.6) : Color(red: 0.52, green: 0.52, blue: 0.52)
    }
    
    // MARK: - 白天/夜晚模式分割线颜色
    static func dividerColor(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color.white.opacity(0.2) : Color(red: 0.9, green: 0.9, blue: 0.9)
    }
    
    static func separatorColor(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color.white.opacity(0.15) : Color(red: 0.85, green: 0.85, blue: 0.85)
    }
    
    // MARK: - 白天/夜晚模式阴影
    static func shadowColor(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color.black.opacity(0.5) : Color.black.opacity(0.1)
    }
    
    static func shadowOpacity(_ colorScheme: ColorScheme) -> CGFloat { 
        colorScheme == .dark ? 0.4 : 0.12 
    }
    
    static func elevatedShadowOpacity(_ colorScheme: ColorScheme) -> CGFloat { 
        colorScheme == .dark ? 0.5 : 0.16 
    }
    
    // MARK: - 白天/夜晚模式特殊颜色
    static func primary1Text(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color.white : primary1
    }
    static func primary2Text(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color.white : primary2
    }
    static func primary3Text(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color.white : primary3
    }
    static func primary4Text(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color.white : primary4
    }
    static func primary5Text(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color.white : primary5
    }
    static func primary6Text(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color.white : primary6
    }
    static func primary7Text(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color.white : primary7
    }
    static func primary8Text(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color.white : primary8
    }
    static func primary9Text(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color.white : primary9
    }
    static func primary10Text(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color.white : primary10
    }
    static func primary11Text(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color.white : primary11
    }
    static func primary12Text(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color.white : primary12
    }
    static func primary13Text(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color.white : primary13
    }
    static func primary14Text(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color.white : primary14
    }
}

// MARK: - 主题管理器
class ThemeManager: ObservableObject {
    @Published var isDarkMode: Bool = false
    
    init() {
        // 从UserDefaults读取保存的主题设置
        self.isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
    }
    
    func toggleTheme() {
        isDarkMode.toggle()
        // 保存到UserDefaults
        UserDefaults.standard.set(isDarkMode, forKey: "isDarkMode")
    }
    
    func setTheme(_ isDark: Bool) {
        isDarkMode = isDark
        UserDefaults.standard.set(isDark, forKey: "isDarkMode")
    }
}

// MARK: - 主题环境值
struct ThemeKey: EnvironmentKey {
    static let defaultValue = ThemeManager()
}

extension EnvironmentValues {
    var themeManager: ThemeManager {
        get { self[ThemeKey.self] }
        set { self[ThemeKey.self] = newValue }
    }
}

// MARK: - 主题预览支持
extension View {
    func withTheme(_ themeManager: ThemeManager) -> some View {
        self.environmentObject(themeManager)
    }
}

// MARK: - 玻璃背景封装
struct GlassBackground: ViewModifier {
    let cornerRadius: CGFloat
    let shape: AnyShape
    let opacity: CGFloat
    let blurRadius: CGFloat

    init(cornerRadius: CGFloat = 12, shape: some Shape = RoundedRectangle(cornerRadius: 12), opacity: CGFloat = 1.0, blurRadius: CGFloat = 0) {
        self.cornerRadius = cornerRadius
        self.shape = AnyShape(shape)
        self.opacity = opacity
        self.blurRadius = blurRadius
    }

    func body(content: Content) -> some View {
        content
            .background(backgroundMaterial(), in: shape)
            .opacity(opacity)
            .overlay(BlurLayer(radius: blurRadius).clipShape(shape))
    }

    private func backgroundMaterial() -> Material {
        if #available(iOS 18.0, *) {
            return Material.regularMaterial
        } else {
            return Material.ultraThinMaterial
        }
    }
}

extension View {
    func glassBackground(cornerRadius: CGFloat = 12, opacity: CGFloat = 1.0, blurRadius: CGFloat = 0) -> some View {
        modifier(GlassBackground(cornerRadius: cornerRadius, opacity: opacity, blurRadius: blurRadius))
    }

    func glassBackground<S: Shape>(_ shape: S, opacity: CGFloat = 1.0, blurRadius: CGFloat = 0) -> some View {
        modifier(GlassBackground(cornerRadius: 0, shape: shape, opacity: opacity, blurRadius: blurRadius))
    }
}

// MARK: - AnyShape 简化器
struct AnyShape: Shape, Sendable {
    private let pathBuilder: @Sendable (CGRect) -> Path

    init<S: Shape>(_ wrapped: S) {
        self.pathBuilder = { rect in
            wrapped.path(in: rect)
        }
    }

    func path(in rect: CGRect) -> Path {
        pathBuilder(rect)
    }
}

// MARK: - 可控模糊层（用于滚动动态增强）
struct BlurLayer: View {
    let radius: CGFloat
    var body: some View {
        Group {
            if radius > 0 {
                Rectangle().fill(.ultraThinMaterial).blur(radius: radius)
            } else {
                Color.clear
            }
        }
    }
}



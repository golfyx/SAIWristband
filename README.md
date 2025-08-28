# SAIWristband

一个智能手环健康管理应用，支持白天/夜晚模式切换。

## 功能特性

- 健康数据管理
- 设备连接
- 个人档案
- 健康报告
- 成就系统
- 白天/夜晚模式支持

## 白天/夜晚模式主题系统

### 概述

应用内置了完整的白天/夜晚模式主题系统，能够根据系统设置自动切换，也支持手动切换。

### 主题特点

#### 白天模式
- 白色背景
- 深色文字
- 浅色卡片
- 柔和阴影

#### 夜晚模式
- 黑色背景
- 白色文字
- 深色卡片
- 增强阴影

### 使用方法

#### 1. 自动主题切换

应用会自动跟随系统的外观设置：

```swift
@Environment(\.colorScheme) private var colorScheme

// 使用主题颜色
.background(AppTheme.background(colorScheme))
.foregroundColor(AppTheme.primaryText(colorScheme))
```

#### 2. 手动主题切换

使用主题管理器进行手动切换：

```swift
@StateObject private var themeManager = ThemeManager()

// 切换主题
Button("切换主题") {
    themeManager.toggleTheme()
}

// 设置特定主题
themeManager.setTheme(true)  // 夜晚模式
themeManager.setTheme(false) // 白天模式
```

#### 3. 主题颜色使用

```swift
// 背景色
AppTheme.background(colorScheme)
AppTheme.cardBackground(colorScheme)
AppTheme.elevatedCardBackground(colorScheme)

// 文字颜色
AppTheme.primaryText(colorScheme)
AppTheme.secondaryText(colorScheme)
AppTheme.tertiaryText(colorScheme)

// 分割线和阴影
AppTheme.dividerColor(colorScheme)
AppTheme.separatorColor(colorScheme)
AppTheme.shadowColor(colorScheme)
```

### 主题组件

#### 卡片组件
- `cardBackground`: 基础卡片背景
- `elevatedCardBackground`: 提升卡片背景
- `card1Background` 到 `card14Background`: 特殊卡片背景

#### 文字组件
- `primaryText`: 主要文字
- `secondaryText`: 次要文字
- `tertiaryText`: 第三级文字

#### 分割线组件
- `dividerColor`: 主要分割线
- `separatorColor`: 次要分割线

### 在ProfileView中的应用

ProfileView展示了完整的主题系统应用：

1. **导航栏**: 使用主题背景和文字颜色
2. **个人信息卡片**: 应用提升卡片背景和阴影
3. **健康报告区域**: 使用卡片背景和分割线
4. **成就展示**: 应用特殊卡片背景
5. **记录值区域**: 使用提升卡片背景
6. **提醒设置**: 应用卡片背景和阴影

### 扩展其他界面

要在其他界面应用主题系统：

1. 导入主题系统
2. 使用 `@Environment(\.colorScheme)` 获取当前主题
3. 替换硬编码的颜色为 `AppTheme` 函数
4. 测试白天/夜晚模式效果

### 最佳实践

1. **一致性**: 在整个应用中保持颜色使用的一致性
2. **对比度**: 确保文字在两种主题下都有足够的对比度
3. **测试**: 在两种主题模式下测试所有界面
4. **性能**: 避免在渲染过程中动态计算颜色

## 技术架构

- SwiftUI
- iOS 18+ Glass Material 支持
- 响应式设计
- 主题管理系统

## 安装和运行

1. 克隆项目
2. 使用 Xcode 打开 `SAIWristband.xcworkspace`
3. 选择目标设备或模拟器
4. 运行项目

## 贡献

欢迎提交 Issue 和 Pull Request 来改进项目。

## 许可证

MIT License
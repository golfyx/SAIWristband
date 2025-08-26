# SAIWristband - 健康手表应用

## 项目概述

SAIWristband 是一个基于 SwiftUI 开发的健康手表应用，提供健康数据监测、设备管理等功能。

## 功能特性

### 主要页面

1. **首页 (HomeView)**
   - 健康概要展示
   - 测试数值卡片
   - 时间线事件
   - 浮动操作菜单

2. **Vital Signs 页面 (VitalSignsView)** ✨ **新功能**
   - 自定义导航栏（带返回按钮和标题）
   - Add Health Data 部分
     - 体重 (Weight)
     - 血压 (Blood Pressure) 
     - 血糖 (Blood Sugar)
   - Select Tests to Start 部分
     - 心率 (Heart Rate)
     - 血氧 (Blood Oxygen)
     - 心电 (Electrocardiogram)
     - 呼吸 (Respiration)

3. **设备管理页面 (DeviceManagementView)**
4. **个人资料页面 (ProfileView)**

### 技术架构

- **框架**: SwiftUI + Swift
- **iOS 版本**: iOS 16.0+
- **依赖管理**: CocoaPods
- **设计规范**: 严格遵循 iOS HIG 设计规范

## 安装和运行

### 环境要求

- Xcode 15.0+
- iOS 16.0+
- CocoaPods

### 安装步骤

1. 克隆项目
```bash
git clone [项目地址]
cd SAIWristband
```

2. 安装依赖
```bash
pod install
```

3. 打开工作空间
```bash
open SAIWristband.xcworkspace
```

4. 选择目标设备（模拟器或真机）并运行

## 使用说明

### 访问 Vital Signs 页面

1. 在首页点击右下角的加号按钮
2. 在弹出的浮动菜单中选择 "Vital signs"
3. 页面将以模态形式展示

### 页面功能

- **返回导航**: 点击左上角返回箭头可返回首页
- **健康数据添加**: 点击体重、血压、血糖按钮可添加相应健康数据
- **测试选择**: 点击心率、血氧、心电、呼吸按钮可选择开始相应测试

## 设计特点

- **响应式设计**: 支持不同尺寸的 iPhone 设备
- **iOS HIG 规范**: 严格遵循 Apple 人机界面指南
- **现代化 UI**: 使用圆角、阴影等现代设计元素
- **无障碍支持**: 支持动态字体和 VoiceOver

## 项目结构

```
SAIWristband/
├── SAIWristband/
│   ├── Views/
│   │   ├── HomeView.swift          # 首页
│   │   ├── VitalSignsView.swift    # Vital Signs 页面 ✨
│   │   ├── DeviceManagementView.swift
│   │   ├── ProfileView.swift
│   │   └── Components/
│   ├── Models/
│   │   ├── HealthData.swift
│   │   ├── DeviceData.swift
│   │   └── AppState.swift
│   └── SAIWristbandApp.swift
├── Assets.xcassets/                 # 图片资源
├── Podfile                          # CocoaPods 配置
└── README.md
```

## 开发说明

### 添加新功能

1. 在 `Views/` 目录下创建新的 SwiftUI 视图文件
2. 在相应的模型文件中添加数据模型
3. 更新导航逻辑以包含新页面

### 样式规范

- 使用项目预定义的颜色常量
- 遵循 iOS 设计规范中的间距和尺寸标准
- 支持深色模式（如果实现）

## 贡献指南

1. Fork 项目
2. 创建功能分支
3. 提交更改
4. 推送到分支
5. 创建 Pull Request

## 许可证

[许可证信息]

## 联系方式

[联系信息]
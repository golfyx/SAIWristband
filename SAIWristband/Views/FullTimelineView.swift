//
//  FullTimelineView.swift
//  SAIWristband
//
//  Created by Assistant on 2025/8/25.
//

import SwiftUI

struct FullTimelineView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) private var colorScheme
    @State private var selectedDateIndex: Int = 0
    private let weekDates: [DateItem] = DateItem.makeWeek(startingFromMonday: true, days: 7)
    @State private var calories: CaloriesOverview = .mock
    @State private var activity: ActivityOverview = .mock
    @State private var sleep: SleepOverview = .mock
    @State private var eventsByTime: [TimelineGroup] = TimelineGroup.mock
    @State private var firstEventHeights: [Int: CGFloat] = [:]

    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            let scaleX = screenWidth / 375.0
            let scaleY = screenHeight / 667.0
            let scale = min(scaleX, scaleY)

            VStack(spacing: 0) {
                // 自定义导航栏（带下分割线）
                VStack(spacing: 0) {
                    HStack {
                        Button(action: { presentationMode.wrappedValue.dismiss() }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16 * scale, weight: .medium))
                                .foregroundColor(AppTheme.primaryText(colorScheme))
                        }

                        Spacer()

                        Text("Timeline")
                            .font(.system(size: 18 * scale, weight: .regular))
                            .foregroundColor(AppTheme.accent)

                        Spacer()

                        // 占位，保证居中
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16 * scale, weight: .medium))
                            .opacity(0)
                    }
                    .padding(.horizontal, 28 * scale)
                    .padding(.top, 12 * scale)
                    .padding(.bottom, 12 * scale)

                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 0.5)
                }
                .background(AppTheme.cardBackground(colorScheme))

                ScrollView {
                    VStack(alignment: .leading, spacing: 24 * scale) {
                        // 日期选择
                        dateSelector(scale: scale)

                        // 概览
                        overviewSection(scale: scale)

                        // 时间线事件
                        timelineSection(scale: scale)
                    }
                    .padding(.horizontal, 16 * scale)
                    .padding(.vertical, 16 * scale)
                }
                .background(AppTheme.background(colorScheme))
            }
            .navigationBarHidden(true)
            .onAppear {
                if let todayIndex = weekDates.firstIndex(where: { Calendar.current.isDateInToday($0.date) }) {
                    selectedDateIndex = todayIndex
                }
            }
        }
    }

    // MARK: - 日期选择
    private func dateSelector(scale: CGFloat) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                ForEach(weekDates.indices, id: \.self) { index in
                    let item = weekDates[index]

                    // 左侧分隔线（除第一个外，且不在选中项相邻位置）
                    if index > 0 && index != selectedDateIndex && (index - 1) != selectedDateIndex {
                        separatorView(height: 32 * scale)
                    }

                    Button(action: { selectedDateIndex = index }) {
                        VStack(spacing: 6 * scale) {
                            Text(item.dayString)
                                .font(.system(size: 16 * scale, weight: .semibold))
                                .foregroundColor(selectedDateIndex == index ? Color.white : AppTheme.accent)
                            Text(item.weekdayString)
                                .font(.system(size: 12 * scale))
                                .foregroundColor(selectedDateIndex == index ? Color.white.opacity(0.9) : AppTheme.accent.opacity(0.7))
                        }
                        .padding(.horizontal, 12 * scale)
                        .padding(.vertical, 10 * scale)
                        .background(
                            Group {
                                if selectedDateIndex == index { RoundedRectangle(cornerRadius: 12 * scale).fill(AppTheme.accent) } else { Color.clear }
                            }
                        )
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("\(item.accessibilityLabel)")
                    }

                    // 右侧分隔线（除最后一个外，且不在选中项相邻位置）
                    if index < weekDates.count - 1 && index != selectedDateIndex && (index + 1) != selectedDateIndex {
                        separatorView(height: 32 * scale)
                    }
                }
            }
        }
    }

    private func separatorView(height: CGFloat) -> some View {
        Rectangle()
            .fill(AppTheme.separator)
            .frame(width: 1, height: height)
    }

    // MARK: - 概览
    private func overviewSection(scale: CGFloat) -> some View {
        HStack(alignment: .top, spacing: 12 * scale) {
            // 左：Calories - 固定高度为右侧两个卡片总高度
            VStack(alignment: .leading, spacing: 8 * scale) {
                Text("Calories")
                    .font(.system(size: 18 * scale, weight: .semibold))
                    .foregroundColor(AppTheme.accent)
                
                VStack(spacing: 0) {
                    VStack(spacing: 18 * scale) {
                        // Intake 行
                        VStack(alignment: .leading, spacing: 6 * scale) {
                            Text("Intake:")
                                .font(.system(size: 12 * scale))
                                .foregroundColor(Color.white.opacity(0.9))
                            Text("\(calories.intake)")
                                .font(.system(size: 28 * scale, weight: .bold))
                                .foregroundColor(Color.white)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // Burn 行
                        VStack(alignment: .leading, spacing: 6 * scale) {
                            Text("Burn:")
                                .font(.system(size: 12 * scale))
                                .foregroundColor(Color.white.opacity(0.9))
                            Text("\(calories.burn)")
                                .font(.system(size: 28 * scale, weight: .bold))
                                .foregroundColor(Color.white)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(25 * scale)
                    
                    Spacer(minLength: 0)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 190 * scale) // 写死高度：右侧两个卡片总高度
                .background(AppTheme.elevatedCard111Background(colorScheme))
                .cornerRadius(16 * scale)
                .shadow(color: Color.black.opacity(0.16), radius: 8 * scale, x: 0, y: 2 * scale)
            }

            // 右：Activity + Sleep
            VStack(alignment: .leading, spacing: 12 * scale) {
                // Activity - 单个卡片高度约74
                VStack(alignment: .leading, spacing: 8 * scale) {
                    Text("Activity")
                        .font(.system(size: 18 * scale, weight: .semibold))
                        .foregroundColor(AppTheme.accent)
                    VStack(alignment: .leading, spacing: 6 * scale) {
                        Text("\(activity.steps.formatted(.number.grouping(.automatic)))")
                            .font(.system(size: 24 * scale, weight: .bold))
                            .foregroundColor(AppTheme.accent)
                        Text("step")
                            .font(.system(size: 12 * scale))
                            .foregroundColor(AppTheme.accent.opacity(0.8))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(14 * scale)
                    .background(AppTheme.cardBackground(colorScheme))
                    .cornerRadius(16 * scale)
                    .shadow(color: Color.black.opacity(0.12), radius: 6 * scale, x: 0, y: 2 * scale)
                }

                // Sleep - 单个卡片高度约74
                VStack(alignment: .leading, spacing: 8 * scale) {
                    Text("Sleep quality")
                        .font(.system(size: 18 * scale, weight: .semibold))
                        .foregroundColor(AppTheme.accent)
                    VStack(alignment: .leading, spacing: 6 * scale) {
                        Text("Score: \(sleep.score)")
                            .font(.system(size: 20 * scale, weight: .bold))
                            .foregroundColor(AppTheme.accent)
                        Text(sleep.durationText)
                            .font(.system(size: 12 * scale))
                            .foregroundColor(AppTheme.accent.opacity(0.8))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(14 * scale)
                    .background(AppTheme.elevatedCardBackground(colorScheme))
                    .cornerRadius(16 * scale)
                    .shadow(color: Color.black.opacity(0.12), radius: 6 * scale, x: 0, y: 2 * scale)
                }
            }
        }
    }

    private func metricBlock(title: String, value: String, scale: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 4 * scale) {
            Text(title)
                .font(.system(size: 12 * scale))
                .foregroundColor(AppTheme.accent.opacity(0.9))
            Text(value)
                .font(.system(size: 18 * scale, weight: .semibold))
                .foregroundColor(AppTheme.accent)
        }
    }

    // MARK: - 时间线
    private func timelineSection(scale: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 16 * scale) {
            ForEach(eventsByTime.indices, id: \.self) { index in
                let group = eventsByTime[index]
                HStack(alignment: .top, spacing: 12 * scale) {
                    // 左列：时间 + 竖线（无圆点），时间垂直居中对齐第一个事件
                    VStack(spacing: 6 * scale) {
                        Text(formattedMeridiemTime(group.time))
                            .font(.system(size: 12 * scale, weight: .bold))
                            .foregroundColor(AppTheme.accent.opacity(0.9))
                            .frame(height: firstEventHeights[index] ?? 0, alignment: .center)
                        Rectangle()
                            .fill(AppTheme.separator.opacity(0.3))
                            .frame(width: 2 * scale)
                            .frame(maxHeight: .infinity)
                    }
                    .frame(width: 54 * scale)

                    // 右列：事件卡片列表
                    VStack(alignment: .center, spacing: 10 * scale) {
                        ForEach(group.events.indices, id: \.self) { eIndex in
                            let event = group.events[eIndex]
                            Text(event.content)
                                .font(.system(size: 14 * scale))
                                .foregroundColor(AppTheme.primaryText(colorScheme))
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.horizontal, 12 * scale)
                                .padding(.vertical, 10 * scale)
                                .background(AppTheme.cardBackground(colorScheme))
                                .cornerRadius(12 * scale)
                                .shadow(color: Color.black.opacity(0.08), radius: 4 * scale, x: 0, y: 2 * scale)
                                .background(
                                    GeometryReader { proxy in
                                        Color.clear
                                            .preference(key: FirstEventHeightsKey.self, value: eIndex == 0 ? [index: proxy.size.height] : [:])
                                    }
                                )
                        }
                    }
                }
            }
        }
        .onPreferenceChange(FirstEventHeightsKey.self) { values in
            firstEventHeights.merge(values) { _, new in new }
        }
    }
}

// MARK: - Models for Overview
private struct CaloriesOverview { let intake: Int; let burn: Int; static let mock = CaloriesOverview(intake: 1250, burn: 830) }
private struct ActivityOverview { let steps: Int; static let mock = ActivityOverview(steps: 4839) }
private struct SleepOverview { let score: Int; let durationText: String; static let mock = SleepOverview(score: 89, durationText: "7h 43m") }

// MARK: - Timeline grouping by time
private struct TimelineGroup { let time: String; let events: [TimelineEventItem] }
private struct TimelineEventItem { let content: String }

// 用于同步左侧时间文本与右侧第一个事件卡片高度
private struct FirstEventHeightsKey: PreferenceKey {
    static var defaultValue: [Int: CGFloat] = [:]
    static func reduce(value: inout [Int: CGFloat], nextValue: () -> [Int: CGFloat]) {
        value.merge(nextValue()) { _, new in new }
    }
}

// 将 "7:00" 或 "7:00 AM" 统一格式化为 "7:00 AM"
private func formattedMeridiemTime(_ raw: String) -> String {
    let trimmed = raw.trimmingCharacters(in: .whitespaces)
    if trimmed.uppercased().hasSuffix("AM") || trimmed.uppercased().hasSuffix("PM") {
        return trimmed
    }
    return "\(trimmed) AM"
}

private extension TimelineGroup {
    static let mock: [TimelineGroup] = [
        TimelineGroup(time: "7:00 AM", events: [TimelineEventItem(content: "Start your day with a refreshing morning routine")]),
        TimelineGroup(time: "7:30 AM", events: [TimelineEventItem(content: "Healthy breakfast to fuel your body for the day ahead"), TimelineEventItem(content: "Drink a glass of water with vitamins")]),
        TimelineGroup(time: "8:00 AM", events: [TimelineEventItem(content: "Get your heart pumping with outdoor exercise")])
    ]
}

// MARK: - Date selector model
private struct DateItem: Identifiable { let id = UUID(); let date: Date; let calendar = Calendar.current
    var dayString: String { let d = calendar.component(.day, from: date); return "\(d)" }
    var weekdayString: String {
        let idx = calendar.component(.weekday, from: date)
        let symbols = ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"]
        return symbols[(idx - 1 + symbols.count) % symbols.count]
    }
    var accessibilityLabel: String { "\(weekdayString) \(dayString)" }

    static func makeWeek(startingFromMonday: Bool, days: Int) -> [DateItem] {
        let cal = Calendar.current
        let today = Date()
        let weekday = cal.component(.weekday, from: today) // 1..7, 1=Sun
        let mondayOffset = startingFromMonday ? ((weekday + 5) % 7) : 0
        guard let monday = cal.date(byAdding: .day, value: -mondayOffset, to: today) else { return [] }
        return (0..<max(1, days)).compactMap { i in cal.date(byAdding: .day, value: i, to: monday) }.map { DateItem(date: $0) }
    }
}

// MARK: - Preview
struct FullTimelineView_Previews: PreviewProvider {
    static var previews: some View {
        FullTimelineView()
    }
}


import SwiftUI

struct MomentsView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedTab: BadgeTab = .distance
    
    enum BadgeTab: String, CaseIterable {
        case distance = "Distance"
        case steps = "Steps"
        case height = "Height"
        case weight = "Weight"
    }
    
    @Environment(\.colorScheme) private var colorScheme
    var body: some View {
        VStack(spacing: 0) {
            // 自定义导航栏
            MomentsNavigationBar(title: "Moments") {
                presentationMode.wrappedValue.dismiss()
            }
            
            // 内容区域
            ScrollView {
                VStack(spacing: 24) {
                    // Ranking List 部分
                    rankingListSection
                        .padding(.horizontal, 16)
                    
                    // Badge 部分
                    badgeSection
                }
                .padding(.bottom, 24)
                .padding(.top, 12)
            }
        }
        .background(AppTheme.background(colorScheme))
        .navigationBarHidden(true)
        .onAppear {
            // 隐藏底部TabBar
            UITabBar.appearance().isHidden = true
        }
        .onDisappear {
            // 恢复底部TabBar
            UITabBar.appearance().isHidden = false
        }
    }
    
    // MARK: - Ranking List Section
    private var rankingListSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Ranking list")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(AppTheme.primary7Text(colorScheme))
            
            HStack(spacing: 8) {
                // Steps 排名卡片
                rankingCard(
                    title: "Steps",
                    rankings: [
                        RankingItem(name: "Alice", value: "3,839 steps", rank: 1),
                        RankingItem(name: "Lisa", value: "2,389 steps", rank: 2),
                        RankingItem(name: "Peter", value: "2,139 steps", rank: 3)
                    ]
                )
                
                // Mileages 排名卡片
                rankingCard(
                    title: "Mileages",
                    rankings: [
                        RankingItem(name: "Alice", value: "9.34 km", rank: 1),
                        RankingItem(name: "Lisa", value: "8.29 km", rank: 2),
                        RankingItem(name: "Peter", value: "7.35 km", rank: 3)
                    ],
                    mid: true
                )
                
                // Badges 排名卡片
                rankingCard(
                    title: "Badges",
                    rankings: [
                        RankingItem(name: "Alice", value: "10 badges", rank: 1),
                        RankingItem(name: "Lisa", value: "6 badges", rank: 2),
                        RankingItem(name: "Peter", value: "5 badges", rank: 3)
                    ]
                )
            }
        }
    }
    
    private func rankingCard(title: String, rankings: [RankingItem], mid: Bool = false) -> some View {
        VStack(spacing: 8) {
            // 给title添加背景
            Text(title)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(AppTheme.accent)
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(AppTheme.cardBackground(colorScheme).opacity(0.8))
                .cornerRadius(8)
            
            VStack(spacing: 12) {
                ForEach(rankings.indices, id: \.self) { index in
                    let item = rankings[index]
                    HStack(spacing: 5) {
                        // 头像
                        ZStack {
                            // 根据排名显示不同的头像图片
                            Image(rankImage(for: item.rank))
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 24, height: 24)
                                .clipShape(Circle())
                            
                            // 皇冠
                            Image(systemName: crownIcon(for: item.rank))
                                .font(.system(size: crownSize(for: item.rank)))
                                .foregroundColor(crownColor(for: item.rank))
                                .offset(y: -18)
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.name)
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(colorScheme == .dark ? Color.white : (mid ? Color.white : AppTheme.primary4))
                                .lineLimit(1)
                            
                            Text(item.value)
                                .font(.system(size: 9, weight: .regular))
                                .foregroundColor(colorScheme == .dark ? Color.white : (mid ? Color.white : AppTheme.primary5))
                                .lineLimit(1)
                        }
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 12)
        }
        .background(mid ? AppTheme.elevatedCard1Background(colorScheme) : AppTheme.elevatedCard2Background(colorScheme))
        .cornerRadius(12)
        .shadow(color: .black.opacity(AppTheme.shadowOpacity(colorScheme)), radius: 8, x: 0, y: 2)
    }
    
    // MARK: - Badge Section
    private var badgeSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Badge")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(AppTheme.primary7)
                .padding(.horizontal, 16)
            
            // Tab 选择器
            tabSelector
            
            // 两行文字显示
            VStack(alignment: .leading, spacing: 4) {
                Text(selectedTab.rawValue)
                    .font(.system(size: 20, weight: .regular))
                    .foregroundColor(AppTheme.primary7)
                
                Text("Unlocked \(unlockedCount(for: selectedTab))/15")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(AppTheme.primary7)
            }
            .padding(.horizontal, 16)
            
            // Badge 网格
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 3), spacing: 16) {
                ForEach(badges(for: selectedTab), id: \.id) { badge in
                    badgeCard(badge)
                }
            }
            .padding(.horizontal, 8)
        }
    }
    
    private var tabSelector: some View {
        HStack(spacing: 0) {
            ForEach(BadgeTab.allCases, id: \.self) { tab in
                Button(action: {
                    selectedTab = tab
                }) {
                    Text(tab.rawValue)
                        .font(.system(size: selectedTab == tab ? 12 : 14, weight: selectedTab == tab ? .bold : .bold))
                        .foregroundColor(selectedTab == tab ? Color.white : AppTheme.primary4)
                        .padding(.horizontal, selectedTab == tab ? 20 : 16)
                        .padding(.vertical, 8)
                        .background(
                            Group {
                                if selectedTab == tab {
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(AppTheme.primary9)
                                } else {
                                    Color.clear
                                }
                            }
                        )
                }
            }
        }
        .frame(maxWidth: .infinity)
        .background(AppTheme.card3Background(colorScheme))
    }
    
    private func badgeCard(_ badge: BadgeItem) -> some View {
        VStack(spacing: 8) {
            // 城市图片区域
            ZStack {
                VStack {
                    // 城市图片
                    Image(badge.cityImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 80, height: 80)
                        .clipShape(Circle())
                        .opacity(badge.isUnlocked ? 1.0 : 0.5) // 未解锁时降低透明度
                    // 城市名称
                    Text(badge.cityName)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(colorScheme == .dark ? .white : AppTheme.primary4)
                        .multilineTextAlignment(.center)
                    
                    // 距离数值
                    Text(badge.distance)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(colorScheme == .dark ? .white : AppTheme.primary4)
                }
                
                // 未解锁时的遮挡层和锁图标
                if !badge.isUnlocked {
                    ZStack {
                        // 半透明遮挡层
                        Rectangle()
                            .fill(Color.black.opacity(0.3))
                        
                        // 右上角的锁图标
                        VStack {
                            HStack {
                                Spacer()
                                Image(systemName: "lock.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(Color.white)
                                    .padding(8)
                            }
                            Spacer()
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 167)
            .background(AppTheme.card3Background(colorScheme))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        }
    }
    
    // MARK: - Helper Functions
    private func rankImage(for rank: Int) -> String {
        switch rank {
        case 1: return "Image36" // 冠军图片
        case 2: return "Image37" // 亚军图片
        case 3: return "Image38" // 季军图片
        default: return "Image38" // 默认使用季军图片
        }
    }
    
    private func crownIcon(for rank: Int) -> String {
        switch rank {
        case 1: return "crown.fill"
        case 2: return "crown"
        case 3: return "crown"
        default: return "crown"
        }
    }
    
    private func crownSize(for rank: Int) -> CGFloat {
        switch rank {
        case 1: return 18
        case 2: return 14
        case 3: return 12
        default: return 12
        }
    }
    
    private func crownColor(for rank: Int) -> Color {
        switch rank {
        case 1: return Color.yellow // 金色
        case 2: return Color.gray // 银色
        case 3: return Color.orange // 铜色
        default: return Color.gray
        }
    }
    
    private func unlockedCount(for tab: BadgeTab) -> Int {
        switch tab {
        case .distance: return 4
        case .steps: return 6
        case .height: return 3
        case .weight: return 5
        }
    }
    
    private func cityIcon(for cityName: String) -> String {
        switch cityName {
        case "Sydney": return "building.2"
        case "New York": return "building.2"
        case "London": return "building.2"
        case "Paris": return "building.2"
        case "St. Petersburg": return "building.2"
        case "Beijing": return "building.2"
        case "Los Angeles": return "building.2"
        case "Mauritius": return "building.2"
        case "Gold Coast": return "building.2"
        case "Tokyo": return "building.2"
        case "Brasilia": return "building.2"
        case "Hawaii": return "building.2"
        case "Hong Kong": return "building.2"
        case "Shanghai": return "building.2"
        case "Xi'an": return "building.2"
        default: return "building.2"
        }
    }
    
    private func badges(for tab: BadgeTab) -> [BadgeItem] {
        let allBadges = [
            BadgeItem(cityName: "Sydney", distance: "40 km", isUnlocked: true, cityImage: "sydney"),
            BadgeItem(cityName: "New York", distance: "50 km", isUnlocked: true, cityImage: "new_york"),
            BadgeItem(cityName: "London", distance: "60 km", isUnlocked: true, cityImage: "london"),
            BadgeItem(cityName: "Paris", distance: "70 km", isUnlocked: true, cityImage: "paris"),
            BadgeItem(cityName: "St. Petersburg", distance: "80 km", isUnlocked: false, cityImage: "st_petersburg"),
            BadgeItem(cityName: "Beijing", distance: "90 km", isUnlocked: false, cityImage: "beijing"),
            BadgeItem(cityName: "Los Angeles", distance: "100 km", isUnlocked: false, cityImage: "los_angeles"),
            BadgeItem(cityName: "Mauritius", distance: "110 km", isUnlocked: false, cityImage: "mauritius"),
            BadgeItem(cityName: "Gold Coast", distance: "120 km", isUnlocked: false, cityImage: "gold_coast"),
            BadgeItem(cityName: "Tokyo", distance: "130 km", isUnlocked: false, cityImage: "tokyo"),
            BadgeItem(cityName: "Brasilia", distance: "140 km", isUnlocked: false, cityImage: "brasilia"),
            BadgeItem(cityName: "Hawaii", distance: "150 km", isUnlocked: false, cityImage: "hawaii"),
            BadgeItem(cityName: "Hong Kong", distance: "160 km", isUnlocked: false, cityImage: "hong_kong"),
            BadgeItem(cityName: "Shanghai", distance: "170 km", isUnlocked: false, cityImage: "shanghai"),
            BadgeItem(cityName: "Xi'an", distance: "180 km", isUnlocked: false, cityImage: "xi_an")
        ]
        
        // 根据tab返回不同的badge数据
        return allBadges
    }
}

// MARK: - Data Models
struct RankingItem {
    let name: String
    let value: String
    let rank: Int
}

struct BadgeItem {
    let cityName: String
    let distance: String
    let isUnlocked: Bool
    let cityImage: String // 添加城市图片字段
    let id = UUID()
}

// MARK: - 自定义导航栏
struct MomentsNavigationBar: View {
    let title: String
    let onBack: () -> Void
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: onBack) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .medium))
                    }
                    .foregroundColor(AppTheme.primaryText(colorScheme))
                }
                
                Spacer()
                
                Text(title)
                    .font(.system(size: 18, weight: .regular))
                    .foregroundColor(AppTheme.primaryText(colorScheme))
                
                Spacer()
                
                // 占位符，保持标题居中
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .medium))
                }
                .foregroundColor(.clear)
            }
            .padding(.horizontal, 28)
            .padding(.top, 12)
            .padding(.bottom, 16)
            
            // 下分割线
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(height: 0.5)
        }
        .background(AppTheme.cardBackground(colorScheme))
        .glassBackground(RoundedRectangle(cornerRadius: 0))
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 2)
    }
}

// MARK: - Preview
struct MomentsView_Previews: PreviewProvider {
    static var previews: some View {
        MomentsView()
    }
}

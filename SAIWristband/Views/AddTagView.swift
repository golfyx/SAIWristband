import SwiftUI

struct AddTagView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var tagType: String = ""
    @State private var selectedTime: Date = Date()
    @State private var selectedSticker: String = ""
    @State private var selectedCategory: StickerCategory = .mood
    
    // 时间选择器显示状态
    @State private var showingTimePicker = false
    
    // 贴纸资源（使用 Assets 中以 Icon 开头的图片名）
    private let moodStickers = [
        "Icon sentiment very satisfied",
        "Icon sentiment neutral",
        "Icon mood bad",
        "Icon sentiment very dissatisfied",
        "Icon face sad cry",
        "Icon face sad tear",
        "Icon face smile wink"
    ]
    private let foodStickers = [
        "Icon ramen dining",
        "Icon bowl food",
        "Icon fastfood",
        "Icon pizza slice",
        "Icon local cafe",
        "Icon egg alt (1)",
        "Icon apple whole",
    ]
    private let sportsStickers = [
        "Icon hiking",
        "Icon pool",
        "Icon sports volleyball",
        "Icon sports basketball",
        "Icon sports soccer",
        "Icon sports baseball",
        "Icon table tennis paddle ball",
    ]
    private let weatherStickers = [
        "Icon brightness 5",
        "Icon dark mode",
        "Icon cloud",
        "Icon cloud showers heavy",
        "Icon cloud bolt",
        "Icon ac unit",
        "Icon storm"
    ]
    private let otherStickers = [
        "Icon cat",
        "Icon dog",
        "Icon crow",
        "Icon cruelty free",
        "Icon local florist",
        "Icon tree",
        "Icon diamond"
    ]
    
    // 表情对应的标签内容
    private let stickerContent: [String: String] = [
        // Mood
        "😊": "Happy Day!\nFeeling Great!",
        "😢": "Sad Moment\nNeed Comfort",
        "😡": "Angry Time\nLet it out",
        "😴": "Sleepy Mode\nTime to rest",
        "🤔": "Deep Thinking\nPondering life",
        "😍": "Love is in the air\nHeart full",
        "😎": "Cool as ice\nFeeling awesome",
        "🤗": "Warm hugs\nFeeling loved",
        "😌": "Peaceful mind\nInner calm",
        "😤": "Determined spirit\nReady to fight",
        "🥺": "Puppy eyes\nNeed attention",
        "😇": "Angel mode\nPure heart",
        
        // Foods
        "🍎": "Healthy choice\nApple a day",
        "🍕": "Pizza time!\nCheese heaven",
        "🍜": "Noodle comfort\nWarm bowl",
        "🍣": "Sushi delight\nFresh taste",
        "🍰": "Sweet treat\nCake time",
        "☕": "Coffee break\nEnergy boost",
        "🍺": "Cheers mate!\nGood times",
        "🥗": "Green goodness\nHealthy vibes",
        "🍔": "Burger craving\nJuicy bite",
        "🌮": "Taco Tuesday\nSpicy fun",
        "🍦": "Ice cream joy\nSweet dreams",
        "🍷": "Wine o'clock\nElegant evening",
        
        // Sports
        "🏃": "Running free\nFeeling alive",
        "🏊": "Swimming laps\nWater flow",
        "🚴": "Cycling adventure\nWind in hair",
        "🏋️": "Lifting heavy\nStrength gains",
        "⚽": "Football passion\nTeam spirit",
        "🏀": "Basketball dreams\nSlam dunk",
        "🎾": "Tennis match\nPrecision game",
        "🏸": "Badminton fun\nQuick reflexes",
        "🏓": "Table tennis\nFast action",
        "🏈": "American football\nTouchdown!",
        "🎯": "Target practice\nSharp focus",
        "🧘": "Yoga session\nInner peace",
        
        // Weather
        "☀️": "Sunny day\nPerfect weather!",
        "🌧️": "Rainy mood\nCozy inside",
        "❄️": "Winter wonderland\nSnow magic",
        "🌪️": "Stormy weather\nNature's power",
        "🌈": "Rainbow beauty\nColorful day",
        "🌙": "Moonlit night\nStarry dreams",
        "☁️": "Cloudy thoughts\nSoft light",
        "⚡": "Lightning strike\nElectric energy",
        "🌤️": "Partly sunny\nMixed feelings",
        "🌦️": "Sun and rain\nLife's balance",
        "🌨️": "Snow falling\nWinter peace",
        "🌩️": "Thunder storm\nNature's voice",
        
        // Other
        "🎵": "Music vibes\nRhythm in soul",
        "📚": "Reading time\nKnowledge quest",
        "🎮": "Gaming mode\nVirtual world",
        "💻": "Tech time\nDigital life",
        "📱": "Phone check\nConnected world",
        "🎨": "Creative flow\nArtistic soul",
        "✈️": "Travel dreams\nWanderlust",
        "🏠": "Home sweet home\nComfort zone",
        "💡": "Bright idea\nInnovation time",
        "🔮": "Mystical vibes\nMagic moment",
        "🎪": "Circus fun\nEntertainment",
        "🎭": "Drama queen\nTheatrical life"
    ]
    
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 自定义导航栏
                customNavigationBar
                
                // 内容区域
                ScrollView {
                    VStack(spacing: 24) {
                        // New Tag 部分
                        newTagSection
                        
                        // Stickers 部分
                        stickersSection
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 20)
                }
            }
            .background(AppTheme.background(colorScheme))
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingTimePicker) {
            timePickerSheet
        }
    }
    
    // MARK: - 自定义导航栏
    private var customNavigationBar: some View {
        VStack(spacing: 0) {
            HStack {
                // 返回按钮
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.primary)
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
                
                Spacer()
                
                // 标题
                Text("Add a tag")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.primary)
                
                Spacer()
                
                // 占位，保持标题居中
                Color.clear
                    .frame(width: 44, height: 44)
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            
            // 分割线
            Divider()
                .background(AppTheme.separator)
        }
        .background(AppTheme.cardBackground(colorScheme))
        .glassBackground(RoundedRectangle(cornerRadius: 0))
    }
    
    // MARK: - New Tag 部分
    private var newTagSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 标题
            Text("New Tag")
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(AppTheme.primaryText(colorScheme))
            
            // 输入区域
            HStack(spacing: 12) {
                // Type 输入框
                TextField("Type...", text: $tagType)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(AppTheme.secondaryText(colorScheme))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(AppTheme.accent.opacity(0.25), lineWidth: 0.83)
                            .shadow(color: Color.black.opacity(0.08), radius: 1, x: 0, y: 1)
                    )
                
                // add to 文本
                Text("add to")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(AppTheme.primaryText(colorScheme))
                
                // 时间选择器
                Button(action: {
                    showingTimePicker = true
                }) {
                    HStack(spacing: 8) {
                        Text(timeString)
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(AppTheme.accent)
                        
                        Image(systemName: "chevron.down")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(AppTheme.accent)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(AppTheme.accent, lineWidth: 1)
                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 0)
                    )
                }
            }
            
            // 标签预览
            tagPreview
        }
    }
    
    // MARK: - 标签预览
    private var tagPreview: some View {
        VStack(alignment: .leading, spacing: 8) {
            
            // 标签卡片
            ZStack {
                // 背景
                RoundedRectangle(cornerRadius: 12)
                    .fill(AppTheme.elevatedCardBackground(colorScheme))
                    .shadow(color: Color.black.opacity(0.25), radius: 2, x: -2, y: 2)
                
                // 内容
                VStack(spacing: 8) {
                    Text(tagType.isEmpty ? "Type..." : tagType)
                        .font(.system(size: 24, weight: .regular))
                        .foregroundColor(tagType.isEmpty ? Color.secondary : AppTheme.accent)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                
                // 贴纸显示在右下角
                if !selectedSticker.isEmpty {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Image(selectedSticker)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 42, height: 42)
                                .padding(.trailing, 10)
                                .padding(.bottom, 1)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Stickers 部分
    private var stickersSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 标题
            Text("Stickers")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(AppTheme.accent)
            
            // 分类表情选择器
            categoryStickerRows
        }
    }
    
    // MARK: - 分类表情行
    private var categoryStickerRows: some View {
        VStack(spacing: 20) {
            ForEach(StickerCategory.allCases, id: \.self) { category in
                categoryRow(category: category)
            }
        }
    }
    
    // MARK: - 单个分类行
    private func categoryRow(category: StickerCategory) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            // 分类标题
            Text(category.displayName)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(AppTheme.primaryText(colorScheme))
            
            // 单行横向滚动贴纸列表（不换行）
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(stickersForCategory(category), id: \.self) { sticker in
                        Button(action: {
                            selectedSticker = sticker
                        }) {
                            Image(sticker)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                        }
                    }
                }
                .padding(.vertical, 4)
            }
        }
    }
    
    // MARK: - 时间选择器
    private var timePickerSheet: some View {
        NavigationView {
            VStack {
                DatePicker("选择时间", selection: $selectedTime, displayedComponents: .hourAndMinute)
                    .datePickerStyle(WheelDatePickerStyle())
                    .labelsHidden()
                    .padding()
                
                Spacer()
            }
            .navigationTitle("选择时间")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        showingTimePicker = false
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("确定") {
                        showingTimePicker = false
                    }
                }
            }
        }
        .presentationDetents([.height(300)])
    }
    
    // MARK: - 计算属性
    private var timeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: selectedTime)
    }
    
    // MARK: - 辅助函数
    private func stickersForCategory(_ category: StickerCategory) -> [String] {
        switch category {
        case .mood:
            return moodStickers
        case .foods:
            return foodStickers
        case .sports:
            return sportsStickers
        case .weather:
            return weatherStickers
        case .other:
            return otherStickers
        }
    }
}

// MARK: - 表情分类枚举
enum StickerCategory: CaseIterable {
    case mood, foods, sports, weather, other
    
    var displayName: String {
        switch self {
        case .mood:
            return "Mood"
        case .foods:
            return "Foods"
        case .sports:
            return "Sports"
        case .weather:
            return "Weather"
        case .other:
            return "Other"
        }
    }
}

// MARK: - 预览
struct AddTagView_Previews: PreviewProvider {
    static var previews: some View {
        AddTagView()
    }
}

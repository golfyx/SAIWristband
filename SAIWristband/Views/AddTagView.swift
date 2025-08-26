import SwiftUI

struct AddTagView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var tagType: String = ""
    @State private var selectedTime: Date = Date()
    @State private var selectedSticker: String = ""
    @State private var selectedCategory: StickerCategory = .mood
    
    // 时间选择器显示状态
    @State private var showingTimePicker = false
    
    // 表情数据
    private let moodStickers = ["😊", "😢", "😡", "😴", "🤔", "😍", "😎", "🤗", "😌", "😤", "🥺", "😇"]
    private let foodStickers = ["🍎", "🍕", "🍜", "🍣", "🍰", "☕", "🍺", "🥗", "🍔", "🌮", "🍦", "🍷"]
    private let sportsStickers = ["🏃", "🏊", "🚴", "🏋️", "⚽", "🏀", "🎾", "🏸", "🏓", "🏈", "🎯", "🧘"]
    private let weatherStickers = ["☀️", "🌧️", "❄️", "🌪️", "🌈", "🌙", "☁️", "⚡", "🌤️", "🌦️", "🌨️", "🌩️"]
    private let otherStickers = ["🎵", "📚", "🎮", "💻", "📱", "🎨", "✈️", "🏠", "💡", "🔮", "🎪", "🎭"]
    
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
            .background(Color(.systemBackground))
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
                .background(Color(.separator))
        }
        .background(Color(.systemBackground))
    }
    
    // MARK: - New Tag 部分
    private var newTagSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 标题
            Text("New Tag")
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(Color(red: 0.34, green: 0.18, blue: 0.37))
            
            // 输入区域
            HStack(spacing: 12) {
                // Type 输入框
                TextField("Type...", text: $tagType)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(Color(red: 0.66, green: 0.58, blue: 0.72))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(red: 0.66, green: 0.58, blue: 0.72), lineWidth: 0.83)
                            .shadow(color: Color.black.opacity(0.08), radius: 1, x: 0, y: 1)
                    )
                
                // add to 文本
                Text("add to")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(Color(red: 0.34, green: 0.18, blue: 0.37))
                
                // 时间选择器
                Button(action: {
                    showingTimePicker = true
                }) {
                    HStack(spacing: 8) {
                        Text(timeString)
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(Color(red: 0.34, green: 0.14, blue: 0.52))
                        
                        Image(systemName: "chevron.down")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Color(red: 0.34, green: 0.14, blue: 0.52))
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(red: 0.34, green: 0.14, blue: 0.52), lineWidth: 1)
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
            Text("add to")
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(Color(red: 0.34, green: 0.18, blue: 0.37))
            
            // 标签卡片
            ZStack {
                // 背景
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(red: 0.99, green: 0.96, blue: 1.0))
                    .shadow(color: Color.black.opacity(0.25), radius: 2, x: -2, y: 2)
                
                // 内容
                VStack(spacing: 8) {
                    Text(tagType.isEmpty ? "Please enter tag content" : tagType)
                        .font(.system(size: 24, weight: .regular))
                        .foregroundColor(tagType.isEmpty ? Color.secondary : Color(red: 0.48, green: 0.08, blue: 0.49))
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                
                // 表情显示在右下角
                if !selectedSticker.isEmpty {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Text(selectedSticker)
                                .font(.system(size: 42))
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
                .foregroundColor(Color(red: 0.52, green: 0.17, blue: 0.61))
            
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
                .foregroundColor(Color(red: 0.34, green: 0.18, blue: 0.37))
            
            // 表情水平滚动
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(stickersForCategory(category), id: \.self) { sticker in
                        Button(action: {
                            selectedSticker = sticker
                        }) {
                            Text(sticker)
                                .font(.system(size: 30))
                                .frame(width: 40, height: 40)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(selectedSticker == sticker ? 
                                              Color(red: 0.52, green: 0.17, blue: 0.61).opacity(0.2) : 
                                              Color.clear)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(selectedSticker == sticker ? 
                                                       Color(red: 0.52, green: 0.17, blue: 0.61) : 
                                                       Color.clear, lineWidth: 2)
                                        )
                                )
                        }
                    }
                }
                .padding(.horizontal, 4)
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

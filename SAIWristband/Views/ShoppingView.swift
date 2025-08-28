//
//  ShoppingView.swift
//  SAIWristband
//
//  Created by golfy xiong on 2025/8/22.
//

import SwiftUI

struct ShoppingView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var currentBannerIndex = 0
    @State private var searchText = ""
    @Environment(\.colorScheme) private var colorScheme
    
    // 轮播图数据
    private let bannerImages = ["banner_image"]
    
    // 商品分类数据
    private let categories = ["Health watch", "Health wristband", "Detector"]
    
    // 商品数据
    private let products = [
        Product(id: 1, name: "Watch 1", price: "$120", imageName: "watch1_image", backgroundColor: Color(red: 1.0, green: 0.99, blue: 0.96, opacity: 0.54)),
        Product(id: 2, name: "Watch 2", price: "$80", imageName: "watch2_image", backgroundColor: Color.white),
        Product(id: 3, name: "Watch 3", price: "$95", imageName: "watch3_image", backgroundColor: Color.white),
        Product(id: 4, name: "Watch 4", price: "$133", imageName: "watch4_image", backgroundColor: Color.white)
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // 自定义导航栏
            ShoppingNavigationBar(title: "Shopping") {
                presentationMode.wrappedValue.dismiss()
            }
            
            // 内容区域
            ScrollView {
                VStack(spacing: 24) {
                    // 轮播图
                    BannerCarousel(images: bannerImages, currentIndex: $currentBannerIndex)
                        .padding(.horizontal, 16)
                    
                    // 主要内容容器（搜索框、商品分类、商品展示）
                    VStack(spacing: 16) {
                        // 搜索框
                        ShoppingSearchBar(text: $searchText)
                        
                        // 商品分类
                        CategoryScrollView(categories: categories)
                        
                        // 商品展示
                        ProductGridView(products: products)
                    }
                    .padding(16)
                    .background(AppTheme.card10Background(colorScheme))
                    .cornerRadius(20)
                    .shadow(color: .black.opacity(AppTheme.shadowOpacity(colorScheme)), radius: 2, x: 0, y: 2)
                    .padding(.horizontal, 16)
                }
                .padding(.top, 16)
            }
        }
        .background(AppTheme.background(colorScheme))
        .navigationBarHidden(true)
    }
}

// MARK: - 自定义导航栏
struct ShoppingNavigationBar: View {
    let title: String
    let onBack: () -> Void
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(AppTheme.primaryText(colorScheme))
                }
                
                Spacer()
                
                Text(title)
                    .font(.system(size: 18, weight: .regular))
                    .foregroundColor(AppTheme.primaryText(colorScheme))
                
                Spacer()
                
                // 占位符，保持标题居中
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .medium))
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

// MARK: - 轮播图
struct BannerCarousel: View {
    let images: [String]
    @Binding var currentIndex: Int
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        ZStack {
            // 轮播图背景
            RoundedRectangle(cornerRadius: 12)
                .fill(AppTheme.elevatedCardBackground(colorScheme))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
                .shadow(color: .black.opacity(AppTheme.shadowOpacity(colorScheme)), radius: 4, x: 0, y: 2)
            
            // 轮播图内容
            if !images.isEmpty {
                TabView(selection: $currentIndex) {
                    ForEach(0..<images.count, id: \.self) { index in
                        Image(images[index])
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 198)
                            .clipped()
                            .cornerRadius(12)
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .frame(height: 198)
            }
        }
        .frame(height: 198)
    }
}

// MARK: - 搜索框
struct ShoppingSearchBar: View {
    @Binding var text: String
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        HStack(spacing: 12) {
            // 搜索输入框
            HStack {
                TextField("Search courses", text: $text)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(AppTheme.primary11Text(colorScheme))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
            }
            .background(AppTheme.cardBackground(colorScheme))
            .cornerRadius(8)
            .shadow(color: .black.opacity(AppTheme.shadowOpacity(colorScheme)), radius: 2, x: 0, y: 2)
            
            // 搜索按钮
            Button(action: {
                // 处理搜索
            }) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 25, weight: .medium))
                    .foregroundColor(AppTheme.accent)
            }
        }
    }
}

// MARK: - 商品分类滚动视图
struct CategoryScrollView: View {
    let categories: [String]
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                ForEach(Array(categories.enumerated()), id: \.offset) { index, category in
                    HStack(spacing: 0) {
                        Text(category)
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(AppTheme.primary12Text(colorScheme))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                        
                        // 分隔线（除了最后一个）
                        if index < categories.count - 1 {
                            Rectangle()
                                .fill(AppTheme.primary13Text(colorScheme))
                                .frame(width: 3, height: 20)
                                .padding(.horizontal, 8)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - 商品网格视图
struct ProductGridView: View {
    let products: [Product]
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: 16),
            GridItem(.flexible(), spacing: 16)
        ], spacing: 16) {
            ForEach(products) { product in
                ProductCard(product: product)
            }
        }
    }
}

// MARK: - 商品卡片
struct ProductCard: View {
    let product: Product
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(spacing: 12) {
            // 商品图片
            Image(product.imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 60, height: 60)
                .cornerRadius(12)
            
            // 商品名称
            Text(product.name)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(AppTheme.primaryText(colorScheme))
                .lineLimit(1)
                .multilineTextAlignment(.center)
            
            // 价格
            Text(product.price)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(AppTheme.accent)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background( (product.id == 1 || product.id == 4) ? AppTheme.card14Background(colorScheme) : AppTheme.cardBackground(colorScheme))
        .cornerRadius(20)
        .shadow(color: .black.opacity(AppTheme.shadowOpacity(colorScheme)), radius: 2, x: 0, y: 2)
    }
}

// MARK: - 商品模型
struct Product: Identifiable {
    let id: Int
    let name: String
    let price: String
    let imageName: String
    let backgroundColor: Color
}

#Preview {
    ShoppingView()
}

//
//  SharingView.swift
//  SAIWristband
//
//  Created by golfy xiong on 2025/8/22.
//

import SwiftUI

struct SharingView: View {
    @Environment(\.colorScheme) private var colorScheme
    @State private var showingMoments = false
    @State private var showingHealthApps = false
    @State private var showingShopping = false
    
    var body: some View {
        VStack(spacing: 0) {
            // 自定义导航栏
            SharingNavigationBar(title: "Sharing")
            
            // 内容区域
            ScrollView {
                VStack(spacing: 24) {
                    // Social 部分
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Social")
                            .font(.system(size: 20, weight: .regular))
                            .foregroundColor(AppTheme.accent)
                        
                        Button(action: {
                            showingMoments = true
                        }) {
                            SocialPrivacyCard(
                                title: "Ranking list & Badges",
                                backgroundColor: AppTheme.cardBackground(colorScheme)
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(.horizontal, 16)
                    
                    // Privacy 部分
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Privacy")
                            .font(.system(size: 20, weight: .regular))
                            .foregroundColor(AppTheme.accent)
                        
                        Button(action: {
                            showingHealthApps = true
                        }) {
                            SocialPrivacyCard(
                                title: "Apps",
                                backgroundColor: AppTheme.cardBackground(colorScheme)
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(.horizontal, 16)
                    
                    // Shopping 部分
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Shopping")
                                .font(.system(size: 20, weight: .regular))
                                .foregroundColor(AppTheme.accent)
                            
                            Spacer()
                            
                            Button(action: {
                                showingShopping = true
                            }) {
                                Text("More Items →")
                                    .font(.system(size: 14, weight: .regular))
                                    .foregroundColor(AppTheme.accent)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        
                        ShoppingCard()
                    }
                    .padding(.horizontal, 16)
                }
                .padding(.top, 16)
            }
        }
        .background(AppTheme.background(colorScheme))
        .sheet(isPresented: $showingMoments) {
            MomentsView()
        }
        .sheet(isPresented: $showingHealthApps) {
            HealthAppsView()
        }
        .sheet(isPresented: $showingShopping) {
            ShoppingView()
        }
    }
}

// MARK: - 自定义导航栏
struct SharingNavigationBar: View {
    let title: String
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: {
                    // 处理返回按钮点击
                }) {
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
        .background(colorScheme == .dark ? Color(red: 0.15, green: 0.15, blue: 0.15) : Color.white)
        .glassBackground(RoundedRectangle(cornerRadius: 0))
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 2)
    }
}

// MARK: - Social/Privacy 卡片
struct SocialPrivacyCard: View {
    let title: String
    let backgroundColor: Color
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(colorScheme == .dark ? Color.white : AppTheme.primary1)
                .lineLimit(2)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(AppTheme.accent)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .background(backgroundColor)
        .cornerRadius(8)
        .shadow(color: .black.opacity(0.25), radius: 2, x: -2, y: 2)
    }
}

// MARK: - Shopping 卡片
struct ShoppingCard: View {
    @Environment(\.colorScheme) private var colorScheme
    var body: some View {
        HStack(spacing: 16) {
            // 第一个商品
            ProductItem(
                imageName: "Image16",
                productName: "Watch 1",
                price: "$120"
            )
            
            // 第二个商品
            ProductItem(
                imageName: "Image17",
                productName: "Watch 2",
                price: "$80"
            )
        }
        .padding(16)
        .background(colorScheme == .dark ? Color(red: 0.15, green: 0.15, blue: 0.15) : Color.white)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 2)
    }
}

// MARK: - 商品项
struct ProductItem: View {
    let imageName: String
    let productName: String
    let price: String
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(spacing: 12) {
            // 商品图片
                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 80, height: 80)
                    .cornerRadius(16)
            
            // 商品名称
            Text(productName)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(colorScheme == .dark ? Color.white : AppTheme.primary1)
                .lineLimit(1)
            
            // 价格
            Text(price)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(AppTheme.accent)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    SharingView()
}

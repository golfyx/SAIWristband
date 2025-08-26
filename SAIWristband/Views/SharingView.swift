//
//  SharingView.swift
//  SAIWristband
//
//  Created by golfy xiong on 2025/8/22.
//

import SwiftUI

struct SharingView: View {
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
                            .foregroundColor(Color(red: 0.36, green: 0.0, blue: 0.62))
                        
                        NavigationLink(destination: MomentsView()) {
                            SocialPrivacyCard(
                                title: "Ranking list & Badges",
                                backgroundColor: Color(red: 0.99, green: 0.96, blue: 1.0)
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(.horizontal, 16)
                    
                    // Privacy 部分
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Privacy")
                            .font(.system(size: 20, weight: .regular))
                            .foregroundColor(Color(red: 0.36, green: 0.0, blue: 0.62))
                        
                        NavigationLink(destination: HealthAppsView()) {
                            SocialPrivacyCard(
                                title: "Apps",
                                backgroundColor: Color(red: 0.99, green: 0.96, blue: 1.0)
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
                                .foregroundColor(Color(red: 0.36, green: 0.0, blue: 0.62))
                            
                            Spacer()
                            
                            NavigationLink(destination: ShoppingView()) {
                                Text("More Items →")
                                    .font(.system(size: 14, weight: .regular))
                                    .foregroundColor(Color(red: 0.36, green: 0.0, blue: 0.62))
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
        .background(Color.white)
    }
}

// MARK: - 自定义导航栏
struct SharingNavigationBar: View {
    let title: String
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: {
                    // 处理返回按钮点击
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color(red: 0.01, green: 0.01, blue: 0.01))
                }
                
                Spacer()
                
                Text(title)
                    .font(.system(size: 18, weight: .regular))
                    .foregroundColor(Color(red: 0.01, green: 0.01, blue: 0.01))
                
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
        .background(Color.white)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 2)
    }
}

// MARK: - Social/Privacy 卡片
struct SocialPrivacyCard: View {
    let title: String
    let backgroundColor: Color
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(Color(red: 0.61, green: 0.31, blue: 0.59))
                .lineLimit(2)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color(red: 0.61, green: 0.31, blue: 0.59))
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
    var body: some View {
        HStack(spacing: 16) {
            // 第一个商品
            ProductItem(
                imageName: "health_watch_logo",
                productName: "Watch 1",
                price: "$120",
                backgroundColor: Color(red: 1.0, green: 0.99, blue: 0.96, opacity: 0.54)
            )
            
            // 第二个商品
            ProductItem(
                imageName: "abbott_device",
                productName: "Watch 2",
                price: "$80",
                backgroundColor: Color.white
            )
        }
        .padding(16)
        .background(Color.white)
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
    let backgroundColor: Color
    
    var body: some View {
        VStack(spacing: 12) {
            // 商品图片
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(backgroundColor)
                    .frame(width: 80, height: 80)
                
                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 60, height: 60)
            }
            
            // 商品名称
            Text(productName)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(Color(red: 0.38, green: 0.18, blue: 0.5))
                .lineLimit(1)
            
            // 价格
            Text(price)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(Color(red: 0.62, green: 0.27, blue: 0.6))
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    SharingView()
}

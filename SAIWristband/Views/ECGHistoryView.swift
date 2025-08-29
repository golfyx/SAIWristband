//
//  ECGHistoryView.swift
//  SAIWristband
//
//  Created by Assistant on 2025/8/29.
//

import SwiftUI

struct ECGRecord: Identifiable {
    let id = UUID()
    let dateText: String
    let rhythmTitle: String
    let bpm: Int
    let image: String
    let source: String
    let timeText: String
    let isFavorited: Bool
}

struct ECGHistoryView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @State private var records: [ECGRecord] = [
        ECGRecord(dateText: "August 28, 2025", rhythmTitle: "Sinus Rhythm", bpm: 90, image: "Image28", source: "Recorded with Apple Watch", timeText: "6:05 pm", isFavorited: false),
        ECGRecord(dateText: "March 28, 2025", rhythmTitle: "Ventricular tachycardia (VT)", bpm: 112, image: "Image29", source: "Recorded with Samsung Watch", timeText: "9:05 pm", isFavorited: false),
        ECGRecord(dateText: "January 28, 2024", rhythmTitle: "Sinus Rhythm", bpm: 88, image: "Image28", source: "Recorded with Vie nova", timeText: "9:05 pm", isFavorited: true)
    ]
    
    var body: some View {
            ScrollView {
                VStack(spacing: 0) {
                    // 自定义导航栏
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(AppTheme.primaryText(colorScheme))
                        }
                        
                        Spacer()
                        
                        Text("ECG History")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(AppTheme.primaryText(colorScheme))
                        
                        Spacer()
                        
                        // 占位，保证标题居中
                        Color.clear.frame(width: 18, height: 18)
                    }
                    .padding(.horizontal, 16)
                    .frame(height: 44)
                    Divider().background(AppTheme.separator)
                    
                    VStack(spacing: 16) {
                        // 历史测量（最新在上）
                        ForEach(records) { record in
                            ECGRecordCard(record: record)
                        }
                        
                        // EKG Review 区块
                        EKGReviewSection()
                            .padding(.top, 8)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 32)
                }
            }
            .background(AppTheme.background(colorScheme))
            .navigationBarHidden(true)
    }
}

private struct ECGRecordCard: View {
    let record: ECGRecord
    @Environment(\.colorScheme) private var colorScheme
    @State private var isFavoritedLocal: Bool = false
    
    var body: some View {
        
        VStack {
            HStack {
                // 日期条（仿Figma的浅紫背景条）
                Text(record.dateText)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(Color(hex: "#572D5F"))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(hex: "#F7F5FF"))
                Spacer()
            }
        }
        
        VStack(alignment: .leading, spacing: 12) {
            // 顶部：节律 & 心率 + 更多
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(record.rhythmTitle)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(colorScheme == .dark ? .white : Color(hex: "#5D3869"))
                    
                    HStack(spacing: 8) {
                        Image("Icon heart pulse")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 20, height: 20)
                        Text("\(record.bpm) BPM")
                            .font(.system(size: 13, weight: .regular))
                            .foregroundColor(colorScheme == .dark ? .white : Color(hex: "#572D5F"))
                    }
                }
                
                Spacer()
                
                Button(action: {}) {
                    Image(systemName: "ellipsis")
                        .rotationEffect(.degrees(90))
                        .foregroundColor(AppTheme.accent)
                        .frame(width: 32, height: 32)
                }
            }
            
            // 心电图波形（示意）
//            ECGWaveform()
//                .frame(height: 80)
//                .frame(maxWidth: .infinity)
//                .background(AppTheme.secondaryBackground(colorScheme))
//                .clipShape(RoundedRectangle(cornerRadius: 8))
            
            
            Image(record.image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            
            // 来源
            HStack(spacing: 8) {
                Text(record.source)
                    .font(.system(size: 10, weight: .regular))
                    .foregroundColor(colorScheme == .dark ? .white : Color(hex: "#572D5F"))
                Spacer()
            }
            
            // 收藏 & 时间
            HStack {
                Button(action: { isFavoritedLocal.toggle() }) {
                    Image(systemName: (isFavoritedLocal || record.isFavorited) ? "heart.fill" : "heart")
                        .foregroundColor(AppTheme.accent)
                }
                HStack(spacing: 6) {
                    Text(record.timeText)
                        .font(.system(size: 12))
                        .foregroundColor(colorScheme == .dark ? .white : Color(hex: "#572D5F"))
                }
                Spacer()
            }
        }
        .padding(16)
        .background(AppTheme.cardBackground(colorScheme))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(hex: "#AA93F3").opacity(1.0), lineWidth: 1)
        )
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
        .padding(.vertical, 4)
    }
}

private struct EKGReviewSection: View {
    @Environment(\.colorScheme) private var colorScheme
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 8) {
                Text("EKG Review Ready")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(colorScheme == .dark ? .white : Color(hex: "#5D3869"))
                Text("Your Automatic EKG Review is complete\nand you can now view your report.")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(colorScheme == .dark ? .white : Color(hex: "#5D3869"))
                    .lineSpacing(2)
                Button(action: {}) {
                    Text("VIEW REPORT")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(AppTheme.accent)
                        .cornerRadius(6)
                }
            }
            Spacer()
            // 右侧图片占位
            RoundedRectangle(cornerRadius: 6)
                .fill(AppTheme.secondaryBackground(colorScheme))
                .frame(width: 36, height: 57)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(AppTheme.cardBackground(colorScheme))
                .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
        )
    }
}

private struct ECGWaveform: View {
    @Environment(\.colorScheme) private var colorScheme
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let midY = rect.midY
        let width = rect.width
        let height = rect.height
        let baseline = midY
        let cycle: CGFloat = 40
        var x: CGFloat = 0
        path.move(to: CGPoint(x: 0, y: baseline))
        while x < width {
            path.addLine(to: CGPoint(x: x + cycle * 0.1, y: baseline))
            path.addLine(to: CGPoint(x: x + cycle * 0.2, y: baseline - height * 0.35))
            path.addLine(to: CGPoint(x: x + cycle * 0.3, y: baseline + height * 0.25))
            path.addLine(to: CGPoint(x: x + cycle * 0.45, y: baseline))
            path.addLine(to: CGPoint(x: x + cycle, y: baseline))
            x += cycle
        }
        return path
    }
    var body: some View {
        GeometryReader { geo in
            let rect = CGRect(origin: .zero, size: geo.size)
            ZStack {
                // 背景网格轻微
                Path { p in
                    let step: CGFloat = 8
                    var x: CGFloat = 0
                    while x <= rect.width {
                        p.move(to: CGPoint(x: x, y: 0))
                        p.addLine(to: CGPoint(x: x, y: rect.height))
                        x += step
                    }
                    var y: CGFloat = 0
                    while y <= rect.height {
                        p.move(to: CGPoint(x: 0, y: y))
                        p.addLine(to: CGPoint(x: rect.width, y: y))
                        y += step
                    }
                }
                .stroke(AppTheme.separatorColor(colorScheme).opacity(0.3), lineWidth: 0.5)
                
                path(in: rect)
                    .stroke(AppTheme.accent, style: StrokeStyle(lineWidth: 2, lineJoin: .round))
            }
        }
    }
}

#Preview {
    ECGHistoryView()
}



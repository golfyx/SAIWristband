import SwiftUI

struct BloodOxygenHistoryView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    
    private enum TimePeriod: String, CaseIterable {
        case day = "Day"
        case week = "Week"
        case month = "Month"
        case sixMonths = "Six Months"
        case year = "Year"
    }
    
    @State private var selectedTimePeriod: TimePeriod = .day
    
    var body: some View {
        VStack(spacing: 0) {
            // Custom Navigation Bar
            customNavigationBar
            
            // Content
            ScrollView {
                VStack(spacing: 0) {
                    // Time Period Tabs
                    timePeriodTabs
                    
                    // Chart Section
                    chartSection
                    
                    // Show More Button
                    showMoreButton
                        .padding(.top, 32)
                        .padding(.bottom, 40)
                }
            }
        }
        .background(AppTheme.background(colorScheme))
        .navigationBarHidden(true)
    }
    
    // MARK: - Custom Navigation Bar
    private var customNavigationBar: some View {
        VStack(spacing: 0) {
            HStack {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(AppTheme.primaryText(colorScheme))
                        .frame(width: 19, height: 19)
                }
                .padding(.leading, 23)
                
                Spacer()
                
                Text("Blood oxygen")
                    .font(.custom("Montserrat", size: 18))
                    .foregroundColor(AppTheme.primaryText(colorScheme))
                
                Spacer()
                
                Color.clear
                    .frame(width: 19, height: 19)
                    .padding(.trailing, 23)
            }
            .frame(height: 85)
            .background(AppTheme.background(colorScheme))
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 2, y: -2)
        }
    }
    
    // MARK: - Time Period Tabs
    private var timePeriodTabs: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 4) {
                ForEach(TimePeriod.allCases, id: \.self) { period in
                    Button {
                        switch period {
                        case .day, .week, .month:
                            selectedTimePeriod = period
                        case .sixMonths, .year:
                            break
                        }
                    } label: {
                        VStack(spacing: 4) {
                            if period == .sixMonths {
                                VStack(spacing: 0) {
                                    Text("Six").font(.custom("Montserrat", size: 12).weight(.bold))
                                    Text("Month").font(.custom("Montserrat", size: 12).weight(.bold))
                                }
                            } else {
                                Text(period.rawValue).font(.custom("Montserrat", size: 12).weight(.bold))
                            }
                        }
                        .foregroundColor(AppTheme.primaryText(colorScheme))
                        .frame(minWidth: period == .sixMonths ? 49 : nil)
                        .frame(height: 32)
                        .padding(.horizontal, period == .sixMonths ? 8 : 14)
                        .background(selectedTimePeriod == period ? AppTheme.secondaryBackground(colorScheme) : Color.clear)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.top, 23)
    }
    
    // MARK: - Chart Section
    private var chartSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Range and Time Info
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Range")
                        .font(.custom("Roboto", size: 14))
                        .foregroundColor(AppTheme.secondaryText(colorScheme))
                    
                    Text(rangeText)
                        .font(.custom("Roboto", size: 40))
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                    
                    Text(timeRangeText)
                        .font(.custom("Roboto", size: 14))
                        .foregroundColor(AppTheme.secondaryText(colorScheme))
                }
                
                Text("%")
                    .font(.custom("Roboto", size: 14))
                    .foregroundColor(AppTheme.secondaryText(colorScheme))
                    .padding(.bottom, -20)
                
                Spacer()
            }
            .padding(.horizontal, 20)
            
            // Chart Container
//            HeartRateChart(timePeriod: selectedTimePeriod, chartHeight: chartHeight)
//                .padding(.horizontal, 26)
            
            
            Image(chartImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            
            // Latest Reading
            HStack {
                Text("Latest: 14:57")
                    .font(.custom("Roboto", size: 14))
                    .foregroundColor(AppTheme.secondaryText(colorScheme))
                
                Spacer()
                
                Text("97 %")
                    .font(.custom("Roboto", size: 14))
                    .foregroundColor(colorScheme == .dark ? .white : .black)
            }
            .frame(height: 40)
            .padding(.horizontal, 20)
            .background(AppTheme.secondaryBackground(colorScheme))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .padding(.horizontal, 20)
            .shadow(color: Color.black.opacity(0.25), radius: 2, x: -2, y: 2)
        }
        .padding(.top, 17)
    }
    
    // MARK: - Show More Button
    private var showMoreButton: some View {
        Button {
            // Handle show more action
        } label: {
            HStack(spacing: 13.5) {
                Text("Show more blood oxygen data")
                    .font(.custom("Montserrat", size: 14))
                    .foregroundColor(colorScheme == .dark ? .white : .black)
            }
            .frame(width: 214, height: 32)
            .background(AppTheme.secondaryBackground(colorScheme))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .shadow(color: Color.black.opacity(0.25), radius: 2, x: -2, y: 2)
        }
    }
    
    // MARK: - Computed
    private var rangeText: String {
        switch selectedTimePeriod {
        case .day:
            return "92-100"
        case .week:
            return "89-100"
        case .month:
            return "83-100"
        case .sixMonths, .year:
            return "92-100"
        }
    }
    
    private var timeRangeText: String {
        switch selectedTimePeriod {
        case .day:
            return "Today"
        case .week:
            return "22-28 August 2025"
        case .month:
            return "This month"
        case .sixMonths:
            return "Past 6 months"
        case .year:
            return "This year"
        }
    }
    
    private var chartHeight: CGFloat {
        switch selectedTimePeriod {
        case .day:
            return 115
        case .week:
            return 148
        case .month:
            return 148
        case .sixMonths, .year:
            return 148
        }
    }
    
    private var chartImage: String  {
        switch selectedTimePeriod {
        case .day:
            return "Image34"
        case .week:
            return "Image35"
        case .month:
            return "Image35"
        case .sixMonths, .year:
            return "Image35"
        }
    }
}

#Preview {
    BloodOxygenHistoryView()
}



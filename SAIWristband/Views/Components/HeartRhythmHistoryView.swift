import SwiftUI

struct HeartRhythmHistoryView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @State private var selectedTimePeriod: TimePeriod = .hour
    
    enum TimePeriod: String, CaseIterable {
        case hour = "Hour"
        case day = "Day"
        case week = "Week"
        case month = "Month"
        case sixMonths = "Six Months"
        case year = "Year"
        
        var displayText: String {
            switch self {
            case .sixMonths:
                return "Six\nMonths"
            default:
                return rawValue
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Custom Navigation Bar
            customNavigationBar
            
            // Content
            ScrollView {
                VStack(spacing: 0) {
                    // Time Period Tabs
                    timePeriodTabs
                    
                    // Heart Rate Chart Section
                    heartRateChartSection
                    
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
                // Back Button
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(AppTheme.primaryText(colorScheme))
                        .frame(width: 19, height: 19)
                }
                .padding(.leading, 23)
                
                Spacer()
                
                // Title
                Text("Heart rhythm")
                    .font(.custom("Montserrat", size: 18))
                    .foregroundColor(AppTheme.primaryText(colorScheme))
                
                Spacer()
                
                // Empty space for symmetry
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
                    timePeriodTab(period: period)
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.top, 23)
    }
    
    private func timePeriodTab(period: TimePeriod) -> some View {
        Button {
            switch period {
            case .hour, .day, .week:
                selectedTimePeriod = period
            case .month, .sixMonths, .year:
                break
            }
        } label: {
            VStack(spacing: 4) {
                if period == .sixMonths {
                    VStack(spacing: 0) {
                        Text("Six")
                            .font(.custom("Montserrat", size: 12).weight(.bold))
                        Text("Month")
                            .font(.custom("Montserrat", size: 12).weight(.bold))
                    }
                } else {
                    Text(period.rawValue)
                        .font(.custom("Montserrat", size: 12).weight(.bold))
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
    
    // MARK: - Heart Rate Chart Section
    private var heartRateChartSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Range and Time Info
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Range")
                        .font(.custom("Roboto", size: 14))
                        .foregroundColor(AppTheme.secondaryText(colorScheme))
                    
                    Text(rangeText)
                        .font(.custom("Roboto", size: 40))
                        .foregroundColor(AppTheme.accent)
                    
                    Text(timeRangeText)
                        .font(.custom("Roboto", size: 14))
                        .foregroundColor(AppTheme.secondaryText(colorScheme))
                }
                
                Text("BPM")
                    .font(.custom("Roboto", size: 14))
                    .foregroundColor(AppTheme.secondaryText(colorScheme))
                    .padding(.bottom, -20)
                
                Spacer()
            }
            .padding(.horizontal, 20)
            
            // Chart Container
//            chartView
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
                
                Text("90 BPM")
                    .font(.custom("Roboto", size: 14))
                    .foregroundColor(AppTheme.accent)
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
    
    // MARK: - Chart View
    private var chartView: some View {
        HeartRateChart(
            timePeriod: selectedTimePeriod,
            chartHeight: chartHeight
        )
    }
    
    // MARK: - Show More Button
    private var showMoreButton: some View {
        Button {
            // Handle show more action
        } label: {
            HStack(spacing: 13.5) {
                Text("Show more heart rate data")
                    .font(.custom("Montserrat", size: 14))
                    .foregroundColor(AppTheme.accent)
            }
            .frame(width: 214, height: 32)
            .background(AppTheme.secondaryBackground(colorScheme))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .shadow(color: Color.black.opacity(0.25), radius: 2, x: -2, y: 2)
        }
    }
    
    // MARK: - Computed Properties
    private var rangeText: String {
        switch selectedTimePeriod {
        case .hour:
            return "90-108"
        case .day:
            return "46-110"
        case .week:
            return "43-142"
        default:
            return "90-108"
        }
    }
    
    private var timeRangeText: String {
        switch selectedTimePeriod {
        case .hour:
            return "14:00-15:00, Today"
        case .day:
            return "Today"
        case .week:
            return "22-28 August 2025"
        default:
            return "Today"
        }
    }
    
    private var chartHeight: CGFloat {
        switch selectedTimePeriod {
        case .hour:
            return 54
        case .day:
            return 115
        case .week:
            return 148
        default:
            return 54
        }
    }
    
    private var chartImage: String  {
        switch selectedTimePeriod {
        case .hour:
            return "Image30"
        case .day:
            return "Image31"
        case .week:
            return "Image32"
        default:
            return "Image30"
        }
    }
    

}

#Preview {
    HeartRhythmHistoryView()
}

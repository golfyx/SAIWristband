import SwiftUI

struct HeartRateChart: View {
    let timePeriod: HeartRhythmHistoryView.TimePeriod
    let chartHeight: CGFloat
    
    var body: some View {
        VStack(spacing: 0) {
            // Y-axis labels and chart content
            HStack(spacing: 0) {
                // Y-axis labels
                yAxisLabels
                    .frame(width: 30)
                
                // Chart content
                ZStack {
                    // Grid lines
                    chartGridLines
                    
                    // Chart data visualization
                    chartDataView
                }
                .frame(height: chartHeight)
            }
            
            // X-axis labels
            xAxisLabels
                .padding(.top, 4)
        }
    }
    
    // MARK: - Chart Grid Lines
    private var chartGridLines: some View {
        VStack(spacing: 0) {
            // Horizontal grid lines
            ForEach(0..<5) { index in
                Rectangle()
                    .fill(Color(hex: "4D0B6F").opacity(0.29))
                    .frame(height: 1)
                if index < 4 {
                    Spacer()
                }
            }
        }
        .overlay(
            // Vertical grid lines
            HStack(spacing: 0) {
                ForEach(0..<verticalGridCount) { index in
                    Rectangle()
                        .fill(Color(hex: "4D0B6F").opacity(0.29))
                        .frame(width: 1)
                    if index < verticalGridCount - 1 {
                        Spacer()
                    }
                }
            }
        )
    }
    
    // MARK: - Chart Data View
    private var chartDataView: some View {
        GeometryReader { geometry in
            switch timePeriod {
            case .hour:
                hourChartView(in: geometry)
            case .day:
                dayChartView(in: geometry)
            case .week:
                weekChartView(in: geometry)
            default:
                monthChartView(in: geometry)
            }
        }
    }
    
    // MARK: - Hour Chart (Line Chart)
    private func hourChartView(in geometry: GeometryProxy) -> some View {
        ZStack {
            // Chart line
            Path { path in
                let width = geometry.size.width
                let height = geometry.size.height
                
                // Sample data points for hour view (heart rate over time)
                let dataPoints: [(Double, Double)] = [
                    (0.1, 0.6), (0.25, 0.4), (0.4, 0.7), (0.6, 0.3), (0.85, 0.5)
                ]
                
                for (index, point) in dataPoints.enumerated() {
                    let x = point.0 * width
                    let y = (1.0 - point.1) * height // Invert Y for correct orientation
                    
                    if index == 0 {
                        path.move(to: CGPoint(x: x, y: y))
                    } else {
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                }
            }
            .stroke(Color(hex: "9A1AF2"), lineWidth: 1)
            .shadow(color: Color.black.opacity(0.08), radius: 0, x: 0, y: 0)
            
            // Data points
            ForEach(Array(zip([0.1, 0.25, 0.4, 0.6, 0.85], [0.6, 0.4, 0.7, 0.3, 0.5]).enumerated()), id: \.offset) { index, point in
                Circle()
                    .fill(Color(hex: "9A1AF2"))
                    .frame(width: 4, height: 4)
                    .position(
                        x: point.0 * geometry.size.width,
                        y: (1.0 - point.1) * geometry.size.height
                    )
            }
        }
    }
    
    // MARK: - Day Chart (Area Chart)
    private func dayChartView(in geometry: GeometryProxy) -> some View {
        ZStack {
            // Area fill
            Path { path in
                let width = geometry.size.width
                let height = geometry.size.height
                
                // Sample data for day view
                let dataPoints: [(Double, Double)] = [
                    (0.0, 0.8), (0.2, 0.6), (0.4, 0.7), (0.6, 0.4), (0.8, 0.5), (1.0, 0.6)
                ]
                
                // Start from bottom left
                path.move(to: CGPoint(x: 0, y: height))
                
                // Draw the curve
                for point in dataPoints {
                    let x = point.0 * width
                    let y = (1.0 - point.1) * height
                    path.addLine(to: CGPoint(x: x, y: y))
                }
                
                // Close the path back to bottom right
                path.addLine(to: CGPoint(x: width, y: height))
                path.closeSubpath()
            }
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(hex: "9A1AF2").opacity(0.3),
                        Color(hex: "9A1AF2").opacity(0.1)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            
            // Top line
            Path { path in
                let width = geometry.size.width
                let height = geometry.size.height
                
                let dataPoints: [(Double, Double)] = [
                    (0.0, 0.8), (0.2, 0.6), (0.4, 0.7), (0.6, 0.4), (0.8, 0.5), (1.0, 0.6)
                ]
                
                for (index, point) in dataPoints.enumerated() {
                    let x = point.0 * width
                    let y = (1.0 - point.1) * height
                    
                    if index == 0 {
                        path.move(to: CGPoint(x: x, y: y))
                    } else {
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                }
            }
            .stroke(Color(hex: "9A1AF2"), lineWidth: 1)
        }
    }
    
    // MARK: - Week Chart (Bar Chart)
    private func weekChartView(in geometry: GeometryProxy) -> some View {
        HStack(spacing: 0) {
            let barData: [Double] = [0.6, 0.8, 0.4, 0.7, 0.5, 0.3, 0.6] // Sample data for each day
            
            ForEach(Array(barData.enumerated()), id: \.offset) { index, value in
                VStack {
                    Spacer()
                    
                    Rectangle()
                        .fill(Color(hex: "9A1AF2"))
                        .frame(height: value * geometry.size.height)
                        .clipShape(RoundedRectangle(cornerRadius: 2))
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 2)
            }
        }
    }
    
    // MARK: - Month Chart (Line Chart)
    private func monthChartView(in geometry: GeometryProxy) -> some View {
        Path { path in
            let width = geometry.size.width
            let height = geometry.size.height
            
            // Sample data for month view
            let dataPoints: [(Double, Double)] = [
                (0.0, 0.5), (0.15, 0.7), (0.3, 0.4), (0.45, 0.8), (0.6, 0.3), (0.75, 0.6), (1.0, 0.5)
            ]
            
            for (index, point) in dataPoints.enumerated() {
                let x = point.0 * width
                let y = (1.0 - point.1) * height
                
                if index == 0 {
                    path.move(to: CGPoint(x: x, y: y))
                } else {
                    path.addLine(to: CGPoint(x: x, y: y))
                }
            }
        }
        .stroke(Color(hex: "9A1AF2"), lineWidth: 1)
    }
    
    // MARK: - Axis Labels
    private var yAxisLabels: some View {
        VStack(spacing: 0) {
            ForEach(yAxisLabelTexts.reversed(), id: \.self) { text in
                Text(text)
                    .font(.custom("Noto Sans JP", size: 12))
                    .foregroundColor(Color(hex: "4D0B6F"))
                    .frame(maxHeight: .infinity)
            }
        }
    }
    
    private var xAxisLabels: some View {
        HStack(spacing: 0) {
            // Add space for Y-axis labels
            Color.clear
                .frame(width: 30)
            
            HStack {
                ForEach(xAxisLabelTexts, id: \.self) { text in
                    if timePeriod == .week && text.count > 3 {
                        VStack(spacing: 0) {
                            ForEach(text.components(separatedBy: " "), id: \.self) { line in
                                Text(line)
                                    .font(.custom("Roboto", size: 12))
                                    .foregroundColor(Color(hex: "4D0B6F"))
                            }
                        }
                        .frame(maxWidth: .infinity)
                    } else {
                        Text(text)
                            .font(.custom("Roboto", size: 12))
                            .foregroundColor(Color(hex: "4D0B6F"))
                            .frame(maxWidth: .infinity)
                    }
                }
            }
        }
    }
    
    // MARK: - Computed Properties
    private var verticalGridCount: Int {
        switch timePeriod {
        case .hour:
            return 5
        case .day:
            return 5
        case .week:
            return 8
        default:
            return 5
        }
    }
    
    private var xAxisLabelTexts: [String] {
        switch timePeriod {
        case .hour:
            return ["14:15", "14:30", "14:45", "15:00"]
        case .day:
            return ["6 hours", "12 hours", "18 hours", "24 hours"]
        case .week:
            return ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
        case .month:
            return ["Week 1", "Week 2", "Week 3", "Week 4"]
        case .sixMonths:
            return ["Jan", "Feb", "Mar", "Apr", "May", "Jun"]
        case .year:
            return ["Q1", "Q2", "Q3", "Q4"]
        }
    }
    
    private var yAxisLabelTexts: [String] {
        return ["0", "50", "100", "150"]
    }
}

#Preview {
    VStack(spacing: 20) {
        HeartRateChart(
            timePeriod: .hour,
            chartHeight: 54
        )
        .padding()
        
        HeartRateChart(
            timePeriod: .day,
            chartHeight: 115
        )
        .padding()
        
        HeartRateChart(
            timePeriod: .week,
            chartHeight: 148
        )
        .padding()
    }
}

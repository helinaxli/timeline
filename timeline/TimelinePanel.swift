//
//  TimelinePanel.swift
//  timeline
//
//  Created by Helina L. on 8/3/26.
//

import SwiftUI

struct TimelinePanel: View {
    let document: TimelineDocument
    
    @State private var pointsPerYear: CGFloat = 80.0
        
    // Axis layout properties
    private let axisX: CGFloat = 200 // X-coordinate of vertical ruler
    private let tickLength: CGFloat = 10
    var startYear: Int {document.config.startYear}
    var endYear: Int {document.config.endYear}
    var totalYears: Int {
        endYear - startYear + 1
    }
    private var totalHeight: CGFloat {
        CGFloat(totalYears) * pointsPerYear
    }
    
    var body: some View {
        
        ScrollView([.vertical, .horizontal]) {
            ZStack(alignment: .topLeading) {
                timelineSpine
                nodeOverlay(document: document)
            }
            .frame(width: 500, height: totalHeight + 100)
            .padding(.top, 40)
        }
    }
    private var timelineSpine: some View {
        Canvas { context, size in
            // Main vertical line
            var path = Path()
            path.move(to: CGPoint(x: axisX, y: 0))
            path.addLine(to: CGPoint(x: axisX, y: totalHeight))
            context.stroke(path, with: .color(.primary), lineWidth: 2)
            
            // Draw Year Tickmarks
            for yearOffset in 0...totalYears {
                let currentYear = startYear + yearOffset
                let yPos = CGFloat(yearOffset) * pointsPerYear
                
                // Tick line
                var tickPath = Path()
                tickPath.move(to: CGPoint(x: axisX - tickLength, y: yPos))
                tickPath.addLine(to: CGPoint(x: axisX + tickLength, y: yPos))
                context.stroke(tickPath, with: .color(.primary), lineWidth: 1.5)
                
                // Year Label
                let text = Text("\(currentYear)")
                    .font(.caption)
                    .bold()
                
                context.draw(text, at: CGPoint(x: axisX - tickLength - 20, y: yPos), anchor: .trailing)
            }
        }
    }
    
    private func nodeOverlay(document: TimelineDocument) -> some View {
        ForEach(document.events) { node in
            let yPos = yPosition(event: node)
            
            Group {
                if node.side == "left" {
                    // Node on the LEFT side of timeline
                    HStack(spacing: 0) {
                        NodeCardView(node: node)
                        
                        // Connector line from Node to Center Axis
                        Rectangle()
                            .fill(Color.secondary)
                            .frame(height: 1)
                    }
                    .frame(width: axisX - 20) // Stops before tick labels
                    .position(x: (axisX - 20) / 2, y: yPos)
                    
                } else {
                    // Node on the RIGHT side of timeline
                    HStack(spacing: 0) {
                        // Connector line
                        Rectangle()
                            .fill(Color.secondary)
                            .frame(width: 40, height: 1)
                        
                        NodeCardView(node: node)
                        Spacer()
                    }
                    .frame(width: 250)
                    .position(x: axisX + 120, y: yPos)
                }
            }
        }
    }
    
    private func yPosition(event: Event) -> CGFloat {
        let yearIndex = event.year - startYear
        
        // 1. Base year offset and safe unwrapping of matchingYear
        guard document.years.indices.contains(yearIndex) else {
            return CGFloat(yearIndex) * pointsPerYear
        }
        
        let matchingYear = document.years[yearIndex]
        guard !matchingYear.months.isEmpty, matchingYear.numMonths > 0 else {
            return CGFloat(yearIndex) * pointsPerYear
        }
        
        var yPos = CGFloat(yearIndex) * pointsPerYear
        let totalMonthsInYear = CGFloat(matchingYear.numMonths)
        
        // 2. Month offset
        if let monthNum = event.month {
            let monthIndex = monthNum - 1
            let elapsedMonths = CGFloat(max(0, monthIndex))
            let monthFraction = elapsedMonths / totalMonthsInYear
            yPos += monthFraction * pointsPerYear
            
            // 3. Day offset within that month
            if let dayNum = event.day {
                var daysInMonth: CGFloat = 30
                
                if matchingYear.months.indices.contains(monthIndex) {
                    let matchingMonth = matchingYear.months[monthIndex]
                    daysInMonth = CGFloat(matchingMonth.numDays)
                }
                
                if daysInMonth > 0 {
                    let dayProgressWithinMonth = CGFloat(max(0, dayNum - 1)) / daysInMonth
                    let dayFractionInYear = dayProgressWithinMonth / totalMonthsInYear
                    yPos += dayFractionInYear * pointsPerYear
                }
            }
        }
        
        return yPos
    }
}

struct NodeCardView: View {
    let node: Event
    
    private var formattedDate: String {
        let yearStr = String(node.year)
        let monthStr = node.month.map(String.init) ?? "MM"
        let dayStr = node.day.map(String.init) ?? "DD"
        
        return "\(yearStr) / \(monthStr) / \(dayStr)"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(node.title)
                .font(.headline)
            Text(formattedDate)
                .font(.body)
        }
        .padding(10)
        .background(.secondary)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.accentColor, lineWidth: 1)
        )
    }
}

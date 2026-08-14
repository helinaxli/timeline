//
//  TimelinePanel.swift
//  timeline
//
//  Created by Helina L. on 8/3/26.
//

import SwiftUI

struct TimelinePanel: View {
    @Bindable var document: TimelineDocument
    let topInset: CGFloat = 20
    
    @State private var pointsPerYear: CGFloat = 80.0
        
    // Axis layout properties
    private let axisX: CGFloat = 250 // X-coordinate of vertical ruler
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
        Text(document.title)
            .font(.title)
            .padding(.top, 24)
        
        ScrollView([.vertical, .horizontal]) {
            ZStack(alignment: .topLeading) {
                timelineSpine
                nodeOverlay()
            }
            .frame(width: 500, height: totalHeight + 100)
            .padding(.top, 40)
        }
    }
    private var timelineSpine: some View {
        Canvas { context, size in
            // Main vertical line
            var path = Path()
            path.move(to: CGPoint(x: axisX, y: topInset))
            path.addLine(to: CGPoint(x: axisX, y: topInset + totalHeight))
            context.stroke(path, with: .color(.primary), lineWidth: 2)
            
            // Draw Year Tickmarks
            for yearOffset in 0...totalYears {
                let currentYear = startYear + yearOffset
                let yPos = topInset + (CGFloat(yearOffset) * pointsPerYear)
                
                // Tick line
                var tickPath = Path()
                tickPath.move(to: CGPoint(x: axisX - tickLength, y: yPos))
                tickPath.addLine(to: CGPoint(x: axisX + tickLength, y: yPos))
                context.stroke(tickPath, with: .color(.primary), lineWidth: 1.5)
                
                // Year Label
                let text = Text("\(currentYear)")
                    .font(.caption)
                    .bold()
                
                context.draw(text, at: CGPoint(x: axisX - tickLength - 10, y: yPos), anchor: .trailing)
            }
        }
    }
    
    private func nodeOverlay() -> some View {
        ForEach($document.events) { $node in
            let yPos = yPosition(event: node)
            
            Group {
                if node.side == "left" {
                    HStack(spacing: 0) {
                        NodeCardView(node: node, cardSize: $node.size)
                        
                        Rectangle()
                            .fill(Color.secondary)
                            .frame(height: 1)
                    }
                    // Let HStack size dynamically or provide an expanded frame
                    .frame(width: axisX, alignment: .trailing)
                    .position(x: axisX / 2, y: yPos)
                    
                } else {
                    HStack(spacing: 0) {
                        Rectangle()
                            .fill(Color.secondary)
                            .frame(width: 40, height: 1)
                        
                        NodeCardView(node: node, cardSize: $node.size)
                    }
                    // Position relative to axis without hard-capping total width
                    .position(x: axisX + 180, y: yPos)
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
        
        return topInset + yPos
    }
}

struct NodeCardView: View {
    let node: Event
    @Binding var cardSize: CGSize

    // @Binding private var cardSize: CGSize = CGSize(width: 180, height: 90)
    // Minimum dimensions
    private let minWidth: CGFloat = 180
    private let minHeight: CGFloat = 90

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(node.title)
                .font(.title2)
                .bold()
            Text(formattedDate)
                .font(.body)
            Text(node.details)
                .font(.body)
        }
        .padding(16)
        .frame(width: cardSize.width, height: cardSize.height, alignment: .topLeading)
        .background(.secondary)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(Color.accentColor, lineWidth: 2)
        )
        // Four corner handles
        .overlay(alignment: .topLeading) { cornerHandle(xMultiplier: -1, yMultiplier: -1) }
        .overlay(alignment: .topTrailing) { cornerHandle(xMultiplier: 1, yMultiplier: -1) }
        .overlay(alignment: .bottomLeading) { cornerHandle(xMultiplier: -1, yMultiplier: 1) }
        .overlay(alignment: .bottomTrailing) { cornerHandle(xMultiplier: 1, yMultiplier: 1) }
    }

    // Helper view for interactive corner hit-boxes
    private func cornerHandle(xMultiplier: CGFloat, yMultiplier: CGFloat) -> some View {
        Color.clear
            .frame(width: 24, height: 24) // Target area for touch/click
            .contentShape(Rectangle())
            .gesture(
                DragGesture()
                    .onChanged { value in
                        let deltaW = value.translation.width * xMultiplier
                        let deltaH = value.translation.height * yMultiplier
                        cardSize = CGSize(
                            width: max(minWidth, cardSize.width + deltaW),
                            height: max(minHeight, cardSize.height + deltaH)
                        )
                    }
            )
    }

    private var formattedDate: String {
        "\(node.year) / \(node.month.map(String.init) ?? "MM") / \(node.day.map(String.init) ?? "DD")"
    }
}

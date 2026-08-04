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
                nodeOverlay
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
    
    private var nodeOverlay: some View {
        ForEach(nodes) { node in
            let yPos = yPosition(for: node.date)
            
            Group {
                if node.isLeftSide {
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
    
    private func yPosition(for date: Date) -> CGFloat {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        let dayOfYear = calendar.ordinality(of: .day, in: .year, for: date) ?? 1
        
        let yearFraction = CGFloat(dayOfYear) / 365.0
        let effectiveYear = CGFloat(year - startYear) + yearFraction
        
        return effectiveYear * pointsPerYear
    }
}

struct NodeCardView: View {
    let node: TimelineNode
    
    private var formattedDate: String {
        let yearStr = node.event.year.map(String.init) ?? "YYYY"
        let monthStr = node.event.month.map(String.init) ?? "MM"
        let dayStr = node.event.day.map(String.init) ?? "DD"
        
        return "\(yearStr) / \(monthStr) / \(dayStr)"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(node.event.title)
                .font(.headline)
            Text(formattedDate)
                .font(.body)
        }
        .padding(10)
        .background(Color(uiColor: .secondarySystemBackground))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.accentColor, lineWidth: 1)
        )
    }
}

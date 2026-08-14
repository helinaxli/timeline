//
//  TimelinePanel.swift
//  timeline
//
//  Created by Helina L. on 8/3/26.
//

import SwiftUI

struct TimelinePanel: View {
    @Bindable var document: TimelineDocument
    @Environment(\.undoManager) private var undoManager
    
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
    
    // Add `@GestureState` inside TimelinePanel to smoothly track active drags without accumulation bugs
    @GestureState private var dragTranslations: [UUID: CGFloat] = [:]

    private func nodeOverlay() -> some View {
        ForEach($document.events) { $node in
            let yPos = yPosition(event: node)
            let isLeft = node.side == "left"
            
            // Active translation during continuous dragging
            let activeTranslation = dragTranslations[node.id] ?? 0
            
            // Calculate raw offset including drag
            let rawOffset = node.xOffset + activeTranslation
            
            // Clamp offsets so left cards stay <= 0 and right cards stay >= 0, plus screen bounds padding
            let clampedOffset: CGFloat = {
                if isLeft {
                    return min(0, max(-axisX + 50, rawOffset))
                } else {
                    return max(0, min(800 - axisX - 50, rawOffset))
                }
            }()
            
            // Base line length + extension as card moves outward
            let baseLineWidth: CGFloat = 40
            let extraDistance = isLeft ? -clampedOffset : clampedOffset
            let connectorWidth = baseLineWidth + extraDistance
            
            ZStack {
                if isLeft {
                    // 1. Connector line anchored directly onto axisX
                    Rectangle()
                        .fill(Color.secondary)
                        .frame(width: connectorWidth, height: 2)
                        .position(x: axisX - (connectorWidth / 2), y: yPos)
                    
                    // 2. Card positioned at the outer end of the connector line
                    NodeCardView(node: $node)
                        .position(x: axisX - connectorWidth - (node.size.width / 2), y: yPos)
                } else {
                    // 1. Connector line anchored directly onto axisX
                    Rectangle()
                        .fill(Color.secondary)
                        .frame(width: connectorWidth, height: 2)
                        .position(x: axisX + (connectorWidth / 2), y: yPos)
                    
                    // 2. Card positioned at the outer end of the connector line
                    NodeCardView(node: $node)
                        .position(x: axisX + connectorWidth + (node.size.width / 2), y: yPos)
                }
            }
            .gesture(
                DragGesture()
                    .updating($dragTranslations) { value, state, _ in
                        state[node.id] = value.translation.width
                    }
                    .onEnded { value in
                        let finalTranslation = value.translation.width
                        let proposedOffset = node.xOffset + finalTranslation
                        
                        let oldOffset = node.xOffset
                        let newOffset: CGFloat = isLeft
                            ? min(0, max(-axisX + 50, proposedOffset))
                            : max(0, min(800 - axisX - 50, proposedOffset))
                        
                        // Apply clean persistent update
                        node.xOffset = newOffset
                        
                        // Register Command + Z undo state
                        undoManager?.registerUndo(withTarget: document) { _ in
                            node.xOffset = oldOffset
                        }
                    }
            )
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
    // 1. Change from 'let node: Event' to '@Binding var node: Event'
    @Binding var node: Event
    @Environment(\.undoManager) private var undoManager

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
        // Access size directly from the node binding
        .frame(width: node.size.width, height: node.size.height, alignment: .topLeading)
        .background(Color(.windowBackgroundColor))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(Color.accentColor, lineWidth: 2)
        )
        // Corner resize handles
        .overlay(alignment: .topLeading) { cornerHandle(xMultiplier: -1, yMultiplier: -1) }
        .overlay(alignment: .topTrailing) { cornerHandle(xMultiplier: 1, yMultiplier: -1) }
        .overlay(alignment: .bottomLeading) { cornerHandle(xMultiplier: -1, yMultiplier: 1) }
        .overlay(alignment: .bottomTrailing) { cornerHandle(xMultiplier: 1, yMultiplier: 1) }
    }

    private func cornerHandle(xMultiplier: CGFloat, yMultiplier: CGFloat) -> some View {
        Color.clear
            .frame(width: 24, height: 24)
            .contentShape(Rectangle())
            .gesture(
                DragGesture()
                    .onChanged { value in
                        let deltaW = value.translation.width * xMultiplier
                        let deltaH = value.translation.height * yMultiplier
                        
                        // Mutate node size directly
                        node.size = CGSize(
                            width: max(minWidth, node.size.width + deltaW),
                            height: max(minHeight, node.size.height + deltaH)
                        )
                    }
                    .onEnded { value in
                        let oldSize = node.size
                        
                        // Register Undo for resizing (⌘Z)
                        undoManager?.registerUndo(withTarget: undoManager!) { _ in
                            node.size = oldSize
                        }
                    }
            )
    }

    private var formattedDate: String {
        "\(node.year) / \(node.month.map(String.init) ?? "MM") / \(node.day.map(String.init) ?? "DD")"
    }
}

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
    // Add `@State` to track the initial offset before drag begins
    @State private var dragStartOffsets: [UUID: CGFloat] = [:]

    private func nodeOverlay() -> some View {
        ForEach($document.events) { $node in
            let yPos = yPosition(event: node)
            let isLeft = node.side == "left"
            
            // Active translation during gesture
            let activeTranslation = dragTranslations[node.id] ?? 0
            
            // 1. Calculate live position (base stored offset + active drag)
            let rawOffset = node.xOffset + activeTranslation
            
            // Clamped offset for active UI rendering
            let clampedOffset: CGFloat = {
                if isLeft {
                    return min(0, max(-axisX + 20, rawOffset))
                } else {
                    return max(0, min(500 - axisX - 20, rawOffset))
                }
            }()
            
            let baseLineWidth: CGFloat = 40
            let extraDistance = isLeft ? -clampedOffset : clampedOffset
            let connectorWidth = baseLineWidth + extraDistance
            
            ZStack {
                if isLeft {
                    Rectangle()
                        .fill(Color.secondary)
                        .frame(width: connectorWidth, height: 2)
                        .position(x: axisX - (connectorWidth / 2), y: yPos)
                    
                    NodeCardView(node: $node, document: document)
                        .position(x: axisX - connectorWidth - (node.size.width / 2), y: yPos)
                } else {
                    Rectangle()
                        .fill(Color.secondary)
                        .frame(width: connectorWidth, height: 2)
                        .position(x: axisX + (connectorWidth / 2), y: yPos)
                    
                    NodeCardView(node: $node, document: document)
                        .position(x: axisX + connectorWidth + (node.size.width / 2), y: yPos)
                }
            }
            .gesture(
                DragGesture()
                    .updating($dragTranslations) { value, state, _ in
                        state[node.id] = value.translation.width
                    }
                    .onChanged { _ in
                        // Capture original offset once when gesture begins
                        if dragStartOffsets[node.id] == nil {
                            dragStartOffsets[node.id] = node.xOffset
                        }
                    }
                    .onEnded { value in
                        guard let initialOffset = dragStartOffsets[node.id] else { return }
                        
                        let finalTranslation = value.translation.width
                        let proposedOffset = initialOffset + finalTranslation
                        
                        let newOffset: CGFloat = isLeft
                            ? min(0, max(-axisX + 20, proposedOffset))
                            : max(0, min(500 - axisX - 20, proposedOffset))
                        
                        // Only register undo if the node actually moved
                        if initialOffset != newOffset {
                            node.xOffset = newOffset
                            
                            undoManager?.registerUndo(withTarget: document) { _ in
                                node.xOffset = initialOffset
                            }
                            undoManager?.setActionName("Move Node")
                        }
                        
                        // Clear initial tracking state
                        dragStartOffsets[node.id] = nil
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
    @Binding var node: Event
    // Pass the document down or use it as target
    var document: TimelineDocument
    @Environment(\.undoManager) private var undoManager

    private let minWidth: CGFloat = 180
    private let minHeight: CGFloat = 90
    
    // Store the size prior to the gesture starting
    @State private var dragStartSize: CGSize?

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
        .frame(width: node.size.width, height: node.size.height, alignment: .topLeading)
        .background(Color(.windowBackgroundColor))
        .contentShape(Rectangle())
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(Color.accentColor, lineWidth: 2)
        )
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
                        // 1. Capture initial size once at start of drag
                        if dragStartSize == nil {
                            dragStartSize = node.size
                        }
                        
                        guard let startSize = dragStartSize else { return }

                        let deltaW = value.translation.width * xMultiplier
                        let deltaH = value.translation.height * yMultiplier
                        
                        node.size = CGSize(
                            width: max(minWidth, startSize.width + deltaW),
                            height: max(minHeight, startSize.height + deltaH)
                        )
                    }
                    .onEnded { _ in
                        guard let originalSize = dragStartSize else { return }
                        let finalSize = node.size
                        
                        // Register undo ONLY if the size actually changed
                        if originalSize != finalSize {
                            undoManager?.registerUndo(withTarget: document) { targetDoc in
                                node.size = originalSize
                            }
                            undoManager?.setActionName("Resize Node")
                        }
                        
                        // Reset tracking state
                        dragStartSize = nil
                    }
            )
    }

    private var formattedDate: String {
        "\(node.year) / \(node.month.map(String.init) ?? "MM") / \(node.day.map(String.init) ?? "DD")"
    }
}

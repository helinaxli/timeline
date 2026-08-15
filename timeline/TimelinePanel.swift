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
         
    // Axis layout properties (Expanded canvas width to prevent negative coordinate clipping)
    private let axisX: CGFloat = 500 // X-coordinate of vertical ruler in a 1000pt wide canvas
    private let tickLength: CGFloat = 10
    var startYear: Int { document.config.startYear }
    var endYear: Int { document.config.endYear }
    var totalYears: Int { endYear - startYear + 1 }
    private var totalHeight: CGFloat { CGFloat(totalYears) * pointsPerYear }
    
    @State private var isShowingEventEditSheet = false
    @State private var editingEvent: Event? = nil
    
    var body: some View {
        VStack {
            Text(document.title)
                .font(.title)
                .padding(.top, 24)
            
            ScrollView([.vertical, .horizontal]) {
                ZStack(alignment: .topLeading) {
                    timelineSpine
                    nodeOverlay()
                }
                .frame(width: 1000, height: totalHeight + 100)
                .contentShape(Rectangle())
                .padding(.top, 40)
            }
            .sheet(item: $editingEvent) { curr_event in
                NewEventSheet(document: document, isPresented: $isShowingEventEditSheet, eventToEdit: curr_event)
            }
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
            let isLeft = node.side == "left"
            
            let clampedOffset: CGFloat = {
                if isLeft {
                    return min(0, max(-axisX + 100, node.xOffset))
                } else {
                    return max(0, min(1000 - axisX - 100, node.xOffset))
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
                     
                    NodeCardView(node: $node, document: document, isLeft: isLeft, axisX: axisX, onEdit: {
                        editingEvent = node
                    },
                    onDelete: {
                        deleteEvent(node)
                    })
                        .position(x: axisX - connectorWidth - (node.size.width / 2), y: yPos)
                } else {
                    Rectangle()
                        .fill(Color.secondary)
                        .frame(width: connectorWidth, height: 2)
                        .position(x: axisX + (connectorWidth / 2), y: yPos)
                     
                    NodeCardView(node: $node, document: document, isLeft: isLeft, axisX: axisX, onEdit: {
                        editingEvent = node
                    },
                    onDelete: {
                        deleteEvent(node)
                    })
                        .position(x: axisX + connectorWidth + (node.size.width / 2), y: yPos)
                }
            }
        }
    }
    
    private func deleteEvent(_ event: Event) {
        withAnimation {
            document.events.removeAll { $0.id == event.id }
            
            let yearIndex = event.year - document.config.startYear
                if document.years.indices.contains(yearIndex) {
                    let matchingYear = document.years[yearIndex]
                    matchingYear.events.removeAll { $0.id == event.id }
                    
                    // 3. Locate matching FantasyMonth inside that year
                    if let month = event.month {
                        if matchingYear.months.indices.contains(month - 1) {
                            let matchingMonth = matchingYear.months[month - 1]
                            matchingMonth.events.removeAll { $0.id == event.id }
                        }
                    }
                }
        }
    }
    
    private func yPosition(event: Event) -> CGFloat {
        let yearIndex = event.year - startYear
         
        guard document.years.indices.contains(yearIndex) else {
            return CGFloat(yearIndex) * pointsPerYear
        }
         
        let matchingYear = document.years[yearIndex]
        guard !matchingYear.months.isEmpty, matchingYear.numMonths > 0 else {
            return CGFloat(yearIndex) * pointsPerYear
        }
         
        var yPos = CGFloat(yearIndex) * pointsPerYear
        let totalMonthsInYear = CGFloat(matchingYear.numMonths)
         
        if let monthNum = event.month {
            let monthIndex = monthNum - 1
            let elapsedMonths = CGFloat(max(0, monthIndex))
            let monthFraction = elapsedMonths / totalMonthsInYear
            yPos += monthFraction * pointsPerYear
             
            if let dayNum = event.day {
                var daysInMonth: CGFloat = 30
                 
                if matchingYear.months.indices.contains(monthIndex) {
                    daysInMonth = CGFloat(matchingYear.months[monthIndex].numDays)
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
    var document: TimelineDocument
    var isLeft: Bool
    var axisX: CGFloat
    
    var onEdit: (() -> Void)? = nil
    var onDelete: (() -> Void)? = nil
    
    @Environment(\.undoManager) private var undoManager

    private let minWidth: CGFloat = 180
    private let minHeight: CGFloat = 90
    
    @State private var dragStartSize: CGSize?
    @State private var dragStartOffset: CGFloat?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(node.title)
                .font(.title2)
                .bold()
            Text(formattedDate)
                .font(.body)
            Text(node.details)
                .font(.body)
            
            Spacer()
            
            HStack {
                Spacer()
                
                HStack(spacing: 12) {
                    Button(action: { onEdit?() }) {
                        Image(systemName: "pencil")
                            .font(.caption)
                    }
                    .accessibilityLabel("Edit")
                    
                    Button(role: .destructive, action: { onDelete?() }) {
                        Image(systemName: "trash")
                            .font(.caption)
                    }
                    .accessibilityLabel("Delete")
                }
                .buttonStyle(.borderless)
            }
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
        // Move gesture isolated to card body background
        .gesture(
            DragGesture(minimumDistance: 2)
                .onChanged { value in
                    if dragStartOffset == nil {
                        dragStartOffset = node.xOffset
                    }
                    guard let initialOffset = dragStartOffset else { return }
                    
                    let proposedOffset = initialOffset + value.translation.width
                    let newOffset: CGFloat = isLeft
                        ? min(0, max(-axisX + 100, proposedOffset))
                        : max(0, min(1000 - axisX - 100, proposedOffset))
                    
                    node.xOffset = newOffset
                }
                .onEnded { value in
                    guard let initialOffset = dragStartOffset else { return }
                    let finalOffset = node.xOffset
                    
                    if initialOffset != finalOffset {
                        undoManager?.registerUndo(withTarget: document) { _ in
                            node.xOffset = initialOffset
                        }
                        undoManager?.setActionName("Move Node")
                    }
                    dragStartOffset = nil
                }
        )
        // Corner handles retain independent resize gestures without interference
        .overlay(alignment: .topLeading) { cornerHandle(xMultiplier: -1, yMultiplier: -1) }
        .overlay(alignment: .topTrailing) { cornerHandle(xMultiplier: 1, yMultiplier: -1) }
        .overlay(alignment: .bottomLeading) { cornerHandle(xMultiplier: -1, yMultiplier: 1) }
        .overlay(alignment: .bottomTrailing) { cornerHandle(xMultiplier: 1, yMultiplier: 1) }
        .onTapGesture(count:2) {
            if node.side == "left" {
                node.side = "right"
            } else {
                node.side = "left"
            }
        }
    }

    private func cornerHandle(xMultiplier: CGFloat, yMultiplier: CGFloat) -> some View {
        Color.clear
            .frame(width: 24, height: 24)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0, coordinateSpace: .global)
                    .onChanged { value in
                        if dragStartSize == nil {
                            dragStartSize = node.size
                        }
                        
                        guard let startSize = dragStartSize else { return }

                        let deltaW = value.translation.width * xMultiplier
                        let deltaH = value.translation.height * yMultiplier
                        
                        let newWidth = max(minWidth, startSize.width + deltaW)
                        let newHeight = max(minHeight, startSize.height + deltaH)
                        
                        Task { @MainActor in
                            node.size = CGSize(width: newWidth, height: newHeight)
                        }
                    }
                    .onEnded { _ in
                        guard let originalSize = dragStartSize else { return }
                        let finalSize = node.size
                        
                        if originalSize != finalSize {
                            undoManager?.registerUndo(withTarget: document) { _ in
                                node.size = originalSize
                            }
                            undoManager?.setActionName("Resize Node")
                        }
                        dragStartSize = nil
                    }
            )
    }

    private var formattedDate: String {
        "\(node.year) / \(node.month.map(String.init) ?? "MM") / \(node.day.map(String.init) ?? "DD")"
    }
}

//
//  TimelinePanel.swift
//  timeline
//
//  Created by Helina L. on 8/3/26.
//

import SwiftUI

struct TimelinePanel: View {
    @Environment(AppState.self) private var appState
    
    @Bindable var document: TimelineDocument
    @Environment(\.undoManager) private var undoManager
    
    let topInset: CGFloat = 20
    // @State private var pointsPerYear: CGFloat = 80.0
         
    // Axis layout properties
    private let axisX: CGFloat = 500
    private let tickLength: CGFloat = 10
    var startYear: Int { document.config.startYear }
    var endYear: Int { document.config.endYear }
    var totalYears: Int { endYear - startYear + 1 }
    private var totalHeight: CGFloat { CGFloat(totalYears) * document.pointsPerYear }
    
    @State private var isShowingEventEditSheet = false
    @State private var editingEvent: Event? = nil
    
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Text(document.title)
                    .font(.title)

                HStack {
                    Spacer()
                    
                    HStack(spacing: 8) {
                        Button {
                            document.pointsPerYear *= 0.5
                        } label: {
                            Image(systemName: "minus.circle")
                        }

                        Button {
                            document.pointsPerYear *= 2
                        } label: {
                            Image(systemName: "plus.circle")
                        }
                        
                        Button("Reset") {
                            document.pointsPerYear = 80.0
                        }
                    }
                }
            }
            .padding(.top, 16)
            .padding(.horizontal, 16)
            
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
                NewEventSheet(
                    document: document,
                    isPresented: Binding(
                        get: { editingEvent != nil },
                        set: { isPresenting in
                            if !isPresenting { editingEvent = nil }
                        }
                    ),
                    eventToEdit: curr_event
                )
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
                let yPos = topInset + (CGFloat(yearOffset) * document.pointsPerYear)
                 
                // Tick line
                var tickPath = Path()
                tickPath.move(to: CGPoint(x: axisX - tickLength, y: yPos))
                tickPath.addLine(to: CGPoint(x: axisX + tickLength, y: yPos))
                context.stroke(tickPath, with: .color(.primary), lineWidth: 1.5)
                 
                // Year Label
                let text: Text

                if document.pointsPerYear >= 320.0 {
                    text = Text("\(currentYear)")
                        .font(.body)
                } else if document.pointsPerYear >= 5120.0 {
                    text = Text("\(currentYear)")
                        .font(.headline)
                } else {
                    text = Text("\(currentYear)")
                        .font(.caption)
                        .bold() // Correct method name for bold text
                }
                 
                context.draw(text, at: CGPoint(x: axisX - tickLength - 10, y: yPos), anchor: .trailing)
            }
            
            if document.pointsPerYear >= 320.0 {
                for (yearIndex, yr) in document.years.enumerated() {
                    let yearTopPos = topInset + (CGFloat(yearIndex) * document.pointsPerYear)
                    let pointsPerMonth = document.pointsPerYear / CGFloat(yr.numMonths)
                    
                    for monthIndex in 1..<yr.numMonths {
                        let myPos = yearTopPos + (CGFloat(monthIndex) * pointsPerMonth)
                        
                        var tickPath = Path()
                        tickPath.move(to: CGPoint(x: axisX - (tickLength * 0.6), y: myPos))
                        tickPath.addLine(to: CGPoint(x: axisX + (tickLength * 0.6), y: myPos))
                        context.stroke(tickPath, with: .color(.secondary), lineWidth: 1.0)
                        
                        let mtext: Text

                        if document.pointsPerYear >= 5120.0 {
                            mtext = Text("M\(monthIndex + 1)")
                                .font(.body)
                        } else {
                            mtext = Text("M\(monthIndex + 1)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        context.draw(mtext, at: CGPoint(x: axisX - tickLength - 8, y: myPos), anchor: .trailing)
                    }
                }
            }
            
            if document.pointsPerYear >= 5120.0 {
                for (yearIndex, yr) in document.years.enumerated() {
                    let yearTopPos = topInset + (CGFloat(yearIndex) * document.pointsPerYear)
                    let pointsPerMonth = document.pointsPerYear / CGFloat(yr.numMonths)
                    
                    for monthIndex in 0..<yr.numMonths {
                        let monthTopPos = yearTopPos + (CGFloat(monthIndex) * pointsPerMonth)
                        
                        let currentMonth = yr.months[monthIndex]
                        let pointsPerDay = pointsPerMonth / CGFloat(currentMonth.numDays)
                        
                        for dayIndex in 1..<currentMonth.numDays {
                            let dayPos = monthTopPos + (CGFloat(dayIndex) * pointsPerDay)
                            
                            var tickPath = Path()
                            tickPath.move(to: CGPoint(x: axisX - (tickLength * 0.35), y: dayPos))
                            tickPath.addLine(to: CGPoint(x: axisX + (tickLength * 0.35), y: dayPos))
                            context.stroke(tickPath, with: .color(.secondary), lineWidth: 0.75)
                            
                            let dayText = Text("D\(dayIndex + 1)")
                                .font(.system(size: 8))
                                .foregroundColor(.secondary)
                            
                            context.draw(dayText, at: CGPoint(x: axisX - tickLength - 6, y: dayPos), anchor: .trailing)
                        }
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func nodeOverlay() -> some View {
        @Bindable var appState = appState
        
        if appState.filterVisibleOnly {
            // Step 1: Count how many times each event appears across visible arcs and characters
            let eventColorMap = computeEventColors()
            
            // Step 2: Render unique visible events with resolved color priority
            let allVisibleEvents = ($document.visibleArcs.flatMap { $0.events } + $document.visibleChars.flatMap { $0.events })
            
            // Remove duplicate bindings by ID to prevent duplicate SwiftUI views
            let uniqueEvents = Dictionary(grouping: allVisibleEvents, by: { $0.wrappedValue.id })
                .compactMap { $0.value.first }
            
            ForEach(uniqueEvents) { $node in
                let resolvedColor = resolveColor(for: $node, fallbackColor: eventColorMap[node.id] ?? "Default")
                nodeView(node: $node, myColor: resolvedColor)
            }
        } else {
            ForEach($document.events) { $node in
                nodeView(node: $node, myColor: "Default")
            }
        }
    }
    
    private func resolveColor(for node: Binding<Event>, fallbackColor: String) -> String {
        if let manualColor = node.wrappedValue.nodeColor, !manualColor.isEmpty {
            return manualColor
        }
        return fallbackColor
    }
    
    /// Computes whether an event appears once (returns parent color) or multiple times (returns "Default")
    private func computeEventColors() -> [Event.ID: String] {
        var counts: [Event.ID: Int] = [:]
        var colorMap: [Event.ID: String] = [:]
        
        // Process visible arcs
        for arc in document.visibleArcs {
            for event in arc.events {
                counts[event.id, default: 0] += 1
                colorMap[event.id] = arc.myColor
            }
        }
        
        // Process visible characters
        for storyc in document.visibleChars {
            for event in storyc.events {
                counts[event.id, default: 0] += 1
                colorMap[event.id] = storyc.myColor
            }
        }
        
        // Override color to "Default" for overlapping events
        for (id, count) in counts where count > 1 {
            colorMap[id] = "Default"
        }
        
        return colorMap
    }
    
    @ViewBuilder
    private func nodeView(node: Binding<Event>, myColor: String) -> some View {
        let nodeReadOnly = node.wrappedValue
        let yPos = yPosition(event: nodeReadOnly)
        let isLeft = nodeReadOnly.side == "left"
        
        let clampedOffset: CGFloat = {
            if isLeft {
                return min(0, max(-axisX + 100, nodeReadOnly.xOffset))
            } else {
                return max(0, min(1000 - axisX - 100, nodeReadOnly.xOffset))
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
                 
                NodeCardView(
                    node: node,
                    document: document,
                    isLeft: isLeft,
                    axisX: axisX,
                    myColor: myColor,
                    onEdit: {
                        editingEvent = nodeReadOnly
                        isShowingEventEditSheet = true
                    },
                    onDelete: {
                        deleteEvent(nodeReadOnly)
                    }
                )
                .position(x: axisX - connectorWidth - (nodeReadOnly.size.width / 2), y: yPos)
            } else {
                Rectangle()
                    .fill(Color.secondary)
                    .frame(width: connectorWidth, height: 2)
                    .position(x: axisX + (connectorWidth / 2), y: yPos)
                 
                NodeCardView(
                    node: node,
                    document: document,
                    isLeft: isLeft,
                    axisX: axisX,
                    myColor: myColor,
                    onEdit: {
                        editingEvent = nodeReadOnly
                        isShowingEventEditSheet = true
                    },
                    onDelete: {
                        deleteEvent(nodeReadOnly)
                    }
                )
                .position(x: axisX + connectorWidth + (nodeReadOnly.size.width / 2), y: yPos)
            }
        }
    }
    
    private func deleteEvent(_ event: Event) {
        withAnimation {
            document.events.removeAll { $0.id == event.id }
            for arc in event.arcs {
                arc.events.removeAll { $0.id == event.id}
            }
            for storyc in event.characters {
                storyc.events.removeAll {$0.id == event.id}
            }
            
            let yearIndex = event.year - document.config.startYear
            if document.years.indices.contains(yearIndex) {
                let matchingYear = document.years[yearIndex]
                matchingYear.events.removeAll { $0.id == event.id }
                
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
            return CGFloat(yearIndex) * document.pointsPerYear
        }
         
        let matchingYear = document.years[yearIndex]
        guard !matchingYear.months.isEmpty, matchingYear.numMonths > 0 else {
            return CGFloat(yearIndex) * document.pointsPerYear
        }
         
        var yPos = CGFloat(yearIndex) * document.pointsPerYear
        let totalMonthsInYear = CGFloat(matchingYear.numMonths)
         
        if let monthNum = event.month {
            let monthIndex = monthNum - 1
            let elapsedMonths = CGFloat(max(0, monthIndex))
            let monthFraction = elapsedMonths / totalMonthsInYear
            yPos += monthFraction * document.pointsPerYear
             
            if let dayNum = event.day {
                var daysInMonth: CGFloat = 30
                 
                if matchingYear.months.indices.contains(monthIndex) {
                    daysInMonth = CGFloat(matchingYear.months[monthIndex].numDays)
                }
                 
                if daysInMonth > 0 {
                    let dayProgressWithinMonth = CGFloat(max(0, dayNum - 1)) / daysInMonth
                    let dayFractionInYear = dayProgressWithinMonth / totalMonthsInYear
                    yPos += dayFractionInYear * document.pointsPerYear
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
    var myColor: String
    
    var onEdit: (() -> Void)? = nil
    var onDelete: (() -> Void)? = nil
    
    @State private var isShowingDeleteAlert = false
    
    @State private var isShowingEventCard = false
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
        }
        .padding(16)
        .frame(width: node.size.width, height: node.size.height, alignment: .topLeading)
        // .background(Color(.windowBackgroundColor))
        .background(document.whatColor(name: myColor).1)
        .contentShape(Rectangle())
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                // .strokeBorder(Color.accentColor, lineWidth: 2)
                .strokeBorder(Color.black, lineWidth: 2)
        )
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
        .overlay(alignment: .topLeading) { cornerHandle(xMultiplier: -1, yMultiplier: -1) }
        .overlay(alignment: .topTrailing) { cornerHandle(xMultiplier: 1, yMultiplier: -1) }
        .overlay(alignment: .bottomLeading) { cornerHandle(xMultiplier: -1, yMultiplier: 1) }
        .overlay(alignment: .bottomTrailing) { cornerHandle(xMultiplier: 1, yMultiplier: 1) }
        .onTapGesture(count: 2) {
            node.side = (node.side == "left") ? "right" : "left"
        }
        .contextMenu {
            Button("Open") {
                isShowingEventCard = true
            }
            Button("Edit") {
                onEdit?()
            }
            Button("Delete", role: .destructive) {
//                onDelete?()
                isShowingDeleteAlert = true
            }
        }
        .alert("Delete Arc?", isPresented: $isShowingDeleteAlert) {
            Button("Delete", role: .destructive) {
                onDelete?()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to delete \"\(node.title)\"?")
        }
        .sheet(isPresented: $isShowingEventCard) {
            EventCard(
                node: $node,
                onEdit: {
                    isShowingEventCard = false                    
                    onEdit?()
                },
                onDelete: {
                    isShowingEventCard = false
                    onDelete?()
                }
            )
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

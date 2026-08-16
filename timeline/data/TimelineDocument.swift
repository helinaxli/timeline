//
//  Untitled.swift
//  timeline
//
//  Created by Helina L. on 8/3/26.
//

import Foundation
import SwiftData
import SwiftUI

@Model
class TimelineDocument {
    var title: String
    @Relationship(deleteRule: .cascade) var config: TimelineConfig
    @Relationship(deleteRule: .cascade) var arcs: [Arc] = []
    @Relationship(deleteRule: .cascade) var events: [Event] = []
    @Relationship(deleteRule: .cascade) var years: [FantasyYear] = []
    @Relationship(deleteRule: .cascade) var characters: [StoryChar] = []
    // TimelineDocument.swift
//    var colorPalette: [ColorOption] = [
//        ColorOption(name: "Default", fgHex: "#000000", bgHex: "#FFFFFF"),
//        ColorOption(name: "Red", fgHex: "#FF0000", bgHex: "#FF000026"),
//        ColorOption(name: "Orange", fgHex: "#FFA500", bgHex: "#FFA50026"),
//        ColorOption(name: "Yellow", fgHex: "#FFFF00", bgHex: "#FFFF0026"),
//        ColorOption(name: "Green", fgHex: "#008000", bgHex: "#00800026"),
//        ColorOption(name: "Mint", fgHex: "#00C7BE", bgHex: "#00C7BE26"),
//        ColorOption(name: "Blue", fgHex: "#0000FF", bgHex: "#0000FF26"),
//        ColorOption(name: "Purple", fgHex: "#800080", bgHex: "#80008026"),
//        ColorOption(name: "Indigo", fgHex: "#4B0082", bgHex: "#4B008226"),
//        ColorOption(name: "Pink", fgHex: "#FFC0CB", bgHex: "#FFC0CB26")
//    ]
    
    // var defaultColor = ColorOption(name: "Default", fgHex: "#000000", bgHex: "#FFFFFF")
    
    init(title: String = "Untitled", config: TimelineConfig) {
        self.title = title
        self.config = config
    }
    
    func configureTimeline() {
        // Prevent duplicate generation
        guard years.isEmpty else { return }
        
        let start = config.startYear
        let end = config.endYear
        let numMonths = config.numMonthsPerYear
        let numDays = config.numDaysPerMonth
        
        for y in start...end {
            let yearModel = FantasyYear(myself: y, numMonths: numMonths)
            for m in 1...numMonths {
                let monthModel = FantasyMonth(myself: m, year: y, numDays: numDays)
                yearModel.months.append(monthModel)
            }
            self.years.append(yearModel)
        }
        
        config.isConfigured = true
    }
    
    func addEvent(event: Event) {
        // 1. Append to document master list
        self.events.append(event)
        
        // 2. Attach to matching FantasyYear
        let yearIndex = event.year - self.config.startYear
        if self.years.indices.contains(yearIndex) {
            let matchingYear = self.years[yearIndex]
            matchingYear.events.append(event)
            
            // 3. Attach to matching FantasyMonth inside that year
            if let month = event.month {
                if matchingYear.months.indices.contains(month - 1) {
                    let matchingMonth = matchingYear.months[month - 1]
                    matchingMonth.events.append(event)
                }
            }
        }
    }
    
    func updateEvent(masterIndex: Int, updatedEvent: Event) {
        // 1. Replace in document master list
        self.events[masterIndex] = updatedEvent
        
        // 2. Replace in matching FantasyYear
        let yearIndex = updatedEvent.year - self.config.startYear
        if self.years.indices.contains(yearIndex) {
            if let yearEventIndex = self.years[yearIndex].events.firstIndex(where: { $0.id == updatedEvent.id }) {
                self.years[yearIndex].events[yearEventIndex] = updatedEvent
            }
            
            // 3. Replace in matching FantasyMonth inside that year
            if let month = updatedEvent.month {
                let monthIndex = month - 1
                if self.years[yearIndex].months.indices.contains(monthIndex) {
                    if let monthEventIndex = self.years[yearIndex].months[monthIndex].events.firstIndex(where: { $0.id == updatedEvent.id }) {
                        self.years[yearIndex].months[monthIndex].events[monthEventIndex] = updatedEvent
                    }
                }
            }
        }
    }
}

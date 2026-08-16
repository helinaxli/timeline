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

public var colorPalette: [String] = ["Default", "Red", "Orange", "Yellow", "Green", "Mint", "Blue", "Indigo", "Purple", "Pink"]

public var colorDictionary: [String: (Color, Color)] = [
    "Default": (.black, .white),
    "Red": (.black, .red.opacity(0.15)),
    "Orange": (.black, .orange.opacity(0.15)),
    "Yellow": (.black, .yellow.opacity(0.15)),
    "Green": (.black, .green.opacity(0.15)),
    "Blue": (.black, .blue.opacity(0.15)),
    "Indigo": (.black, .indigo.opacity(0.15)),
    "Purple": (.black, .purple.opacity(0.15)),
    "Pink": (.black, .pink.opacity(0.15))
]

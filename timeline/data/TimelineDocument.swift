//
//  Untitled.swift
//  timeline
//
//  Created by Helina L. on 8/3/26.
//

import Foundation
import SwiftData

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
    
    func add(event: Event) {
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
}

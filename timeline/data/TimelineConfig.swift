//
//  TimelineConfig.swift
//  timeline
//
//  Created by Helina L. on 8/3/26.
//

import SwiftData

@Model
final class TimelineConfig {
    var startYear: Int
    var endYear: Int
    var numMonthsPerYear: Int
    var numDaysPerMonth: Int
    var isConfigured: Bool
    
    init(startYear: Int = 2026, endYear: Int = 2026, numMonthsPerYear: Int = 12, numDaysPerMonth: Int = 30, isConfigured: Bool = false) {
        self.startYear = startYear
        self.endYear = endYear
        self.numMonthsPerYear = numMonthsPerYear
        self.numDaysPerMonth = numDaysPerMonth
        self.isConfigured = isConfigured
    }
}

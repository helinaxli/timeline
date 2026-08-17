//
//  TimelineConfig.swift
//  timeline
//
//  Created by Helina L. on 8/3/26.
//

import SwiftData
import SwiftUI

struct TimelineConfig: Codable, Identifiable {
    var id: UUID
    var title: String
    var startYear: Int
    var endYear: Int
    var numMonthsPerYear: Int
    var numDaysPerMonth: Int
    var isConfigured: Bool
    
    init(title: String = "", startYear: Int = 2026, endYear: Int = 2026, numMonthsPerYear: Int = 12, numDaysPerMonth: Int = 30, isConfigured: Bool = false) {
        self.id = UUID()
        self.title = title
        self.startYear = startYear
        self.endYear = endYear
        self.numMonthsPerYear = numMonthsPerYear
        self.numDaysPerMonth = numDaysPerMonth
        self.isConfigured = isConfigured
    }
    
//    func clone() -> Self {
//        return TimelineConfig(startYear: self.startYear,
//                              endYear: self.endYear,
//                              numMonthsPerYear: self.numMonthsPerYear,
//                              numDaysPerMonth: self.numDaysPerMonth,
//                              isConfigured: self.isConfigured) as! Self
//    }
}

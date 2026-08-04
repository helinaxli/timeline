//
//  TimelineConfig.swift
//  timeline
//
//  Created by Helina L. on 8/3/26.
//

import Foundation
import SwiftData

@Model
final class TimelineConfig {
    var startYear: Int
    var endYear: Int
    var isConfigured: Bool
    
    init(startYear: Int = 2026, endYear: Int = 2026, isConfigured: Bool = false) {
        self.startYear = startYear
        self.endYear = endYear
        self.isConfigured = isConfigured
    }
}

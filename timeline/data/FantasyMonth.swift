//
//  FantasyMonth.swift
//  timeline
//
//  Created by Helina L. on 8/6/26.
//

import SwiftData

@Model
class FantasyMonth {
    var myself: Int
    var year: Int
    var numDays: Int
    @Relationship var events: [Event] = []
    
    init(myself: Int, year: Int, numDays: Int = 30) {
        self.myself = myself
        self.year = year
        self.numDays = numDays
    }
}

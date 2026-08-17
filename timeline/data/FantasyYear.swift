//
//  Year.swift
//  timeline
//
//  Created by Helina L. on 8/6/26.
//

import SwiftData

@Model
class FantasyYear {
    var myself: Int
    var numMonths: Int
    @Relationship(deleteRule: .cascade) var months: [FantasyMonth] = []
    var events: [Event] = []
    
    init(myself: Int, numMonths: Int = 12) {
        self.myself = myself
        self.numMonths = numMonths
    }
}

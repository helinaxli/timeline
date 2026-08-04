//
//  Event.swift
//  timeline
//
//  Created by Helina L. on 8/3/26.
//

import Foundation
import SwiftData

@Model
class Event: Identifiable {
    var id: UUID
    var title: String
    var year: Int
    var month: Int
    var day: Int
    
    var details: String = ""
    @Relationship(inverse: \StoryChar.events)
    var characters: [StoryChar] = []
    var arcs: [Arc] = []
    
    init(id: UUID = UUID(), title: String, year: Int, month: Int, day: Int) {
        self.id = id
        self.title = title
        self.year = year
        self.month = month
        self.day = day
    }
}

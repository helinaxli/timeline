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
    var title: String = ""
    var year: Int?
    var month: Int?
    var day: Int?
    var side: String = "left"
    
    var details: String = ""
    @Relationship(inverse: \StoryChar.events)
    var characters: [StoryChar] = []
    var arcs: [Arc] = []
    
    init(id: UUID) {
        self.id = id
    }
}

//
//  Arc.swift
//  timeline
//
//  Created by Helina L. on 8/3/26.
//

import Foundation
import SwiftUI
import SwiftData

@Model
class Arc: Identifiable {
    var id: UUID
    var title: String = ""
    var side: String
    var summary: String = ""
    var myColor: String = "Default"
    
    @Relationship(inverse: \Event.arcs)
    var events: [Event] = []
    @Relationship(inverse: \StoryChar.arcs)
    var characters: [StoryChar] = []
    
    init(id: UUID = UUID(), side: String = "left") {
        self.id = id
        self.side = side
    }
}

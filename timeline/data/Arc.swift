//
//  Arc.swift
//  timeline
//
//  Created by Helina L. on 8/3/26.
//

import Foundation
import SwiftData

@Model
class Arc: Identifiable {
    var id: UUID
    var title: String
    
    @Relationship(inverse: \Event.arcs)
    var events: [Event] = []
    @Relationship(inverse: \StoryChar.arcs)
    var characters: [StoryChar] = []
    
    init(id: UUID = UUID(), title: String) {
        self.id = id
        self.title = title
    }
}

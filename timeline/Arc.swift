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
    var events: [Event]
    var characters: [StoryChar]
    
    init(id: UUID = UUID(), title: String, events: [Event], characters: [StoryChar]) {
        self.id = id
        self.title = title
        self.events = events
        self.characters = characters
    }
}

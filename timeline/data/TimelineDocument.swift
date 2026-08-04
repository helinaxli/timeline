//
//  Untitled.swift
//  timeline
//
//  Created by Helina L. on 8/3/26.
//

import Foundation
import SwiftData

@Model
class TimelineDocument: Identifiable {
    var title: String
    @Relationship(deleteRule: .cascade) var config: TimelineConfig
    @Relationship(deleteRule: .cascade) var arcs: [Arc] = []
    @Relationship(deleteRule: .cascade) var events: [Event] = []
    @Relationship(deleteRule: .cascade) var characters: [StoryChar] = []

    init(title: String = "Untitled", config: TimelineConfig) {
        self.title = title
        self.config = config
    }
}

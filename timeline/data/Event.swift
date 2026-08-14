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
    var year: Int
    var month: Int?
    var day: Int?
    var side: String
    var details: String = ""
    
    var width: CGFloat = 180
    var height: CGFloat = 90
    
    var size: CGSize {
        get { CGSize(width: width, height: height) }
        set {
            width = newValue.width
            height = newValue.height
        }
    }
    
    var xOffset: CGFloat = 0.0
    
    @Relationship(inverse: \StoryChar.events)
    var characters: [StoryChar] = []
    var arcs: [Arc] = []
    
    init(id: UUID, year: Int = 2026, side: String = "left") {
        self.year = year
        self.id = id
        self.side = side
    }
}

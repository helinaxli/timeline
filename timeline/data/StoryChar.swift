//
//  StoryChar.swift
//  timeline
//
//  Created by Helina L. on 8/3/26.
//

import Foundation
import SwiftData

@Model
class StoryChar: Identifiable {
    var id: UUID
    var name: String = ""
    var bday_y: Int?
    var bday_m: Int?
    var bday_d: Int?
    var background: String = ""
    
    var events: [Event] = []
    var arcs: [Arc] = []
    
    init(id: UUID = UUID()) {
        self.id = id

    }
}

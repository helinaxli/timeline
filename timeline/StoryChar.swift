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
    var name: String
    var role: String
    var summary: String
    
    init(id: UUID = UUID(), name: String, role: String, summary: String) {
        self.id = id
        self.name = name
        self.role = role
        self.summary = summary
    }
}

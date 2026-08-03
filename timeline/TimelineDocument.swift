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
    var arcs: [Arc]

    init(id: UUID = UUID(), title: String, events: [Event], arcs: [Arc]) {
        self.title = title
        self.arcs = arcs
    }
}

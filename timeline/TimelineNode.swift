//
//  TimelineNo.swift
//  timeline
//
//  Created by Helina L. on 8/3/26.
//

import Foundation

struct TimelineNode: Identifiable {
    let id: UUID
    let event: Event
    let side: AlignmentSide
    
    enum AlignmentSide {
        case left, right
    }
    
    // Convert a SwiftData `Event` into a rendering `TimelineNode`
    init(event: Event) {
        self.id = event.id
        self.event = event
        self.side = .left
    }
}

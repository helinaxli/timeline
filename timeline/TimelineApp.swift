//
//  timelineApp.swift
//  timeline
//
//  Created by Helina L. on 8/3/26.
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers

extension UTType {
    /// Custom document type for your app
    static var projectFile = UTType(
        exportedAs: "com.helinaxli.timeline.timeline",
        conformingTo: .data
    )
}

@main
struct ProjectApp: App {
    var body: some Scene {
        DocumentGroup(editing: Arc.self, contentType: .projectFile) {
            ContentView()
        }
    }
}

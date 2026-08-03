//
//  TimelineApp.swift
//  timeline
//
//  Created by Helina L. on 8/3/26.
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers

extension UTType {
    static var projectFile = UTType(
        exportedAs: "com.helinaxli.timeline.tl",
        conformingTo: .package
    )
}

@main
struct TimelineApp: App {
    var body: some Scene {
        DocumentGroup(editing: TimelineDocument.self, contentType: .projectFile) {
            ContentView()
        }
    }
}

//
//  timelineApp.swift
//  timeline
//
//  Created by Helina L. on 8/3/26.
//

import SwiftUI

@main
struct timelineApp: App {
    var body: some Scene {
        DocumentGroup(newDocument: timelineDocument()) { file in
            ContentView(document: file.$document)
        }
    }
}

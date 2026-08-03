//
//  ContentView.swift
//  timeline
//
//  Created by Helina L. on 8/3/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Binding var document: Arc

    var body: some View {
        List(document.events) { event in
            Text(event.id.uuidString)
        }
    }
}

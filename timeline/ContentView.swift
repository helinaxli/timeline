//
//  ContentView.swift
//  timeline
//
//  Created by Helina L. on 8/3/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Query private var items: [TimelineDocument]
    
    var body: some View {
        List(items) { item in
            Text(item.title)
        }
    }
}

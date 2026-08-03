//
//  ContentView.swift
//  timeline
//
//  Created by Helina L. on 8/3/26.
//

import SwiftUI

struct ContentView: View {
    @Binding var document: timelineDocument

    var body: some View {
        TextEditor(text: $document.text)
    }
}

#Preview {
    ContentView(document: .constant(timelineDocument()))
}

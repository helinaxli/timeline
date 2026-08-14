//
//  CharacterView.swift
//  timeline
//
//  Created by Helina L. on 8/11/26.
//

import SwiftUI

struct CharacterView: View {
    @Bindable var document: TimelineDocument
    
    @State private var isShowingNewEventSheet = false
    @State private var isShowingNewStoryCharEventSheet = false
    
    var body: some View {
        NavigationStack {
            Text("Characters")
                .font(.title)
                .padding(.top, 24)
            
            ScrollView([.vertical, .horizontal]) {
                VStack(spacing: 10) {
                    ForEach($document.characters) { $node in
                        CharCardView(node: node)
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu("Add New", systemImage: "plus") {
                        Button("New Character", systemImage: "person.badge.plus.fill") {
                            isShowingNewStoryCharEventSheet = true
                        }
                        Button("New Event", systemImage: "calendar.badge.plus") {
                            isShowingNewEventSheet = true
                        }
                        Button("New Arc", systemImage: "folder.fill.badge.plus") {
                            // stuff
                        }
                    }
                }
            }
            .sheet(isPresented: $isShowingNewEventSheet) {
                NewEventSheet(document: document, isPresented: $isShowingNewEventSheet)
            }
            .sheet(isPresented: $isShowingNewStoryCharEventSheet) {
                NewStoryCharSheet(document: document, isPresented: $isShowingNewStoryCharEventSheet)
            }
        }
    }
}

struct CharCardView: View {
    let node: StoryChar
    
    var body: some View {
        // 1. Set explicit leading alignment on the VStack
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 10) {
                Text(node.name)
                    .font(.title2)
                    .bold()
                
                Text(formattedDate)
                    .font(.body)
                
                Spacer() // Pushes header content to the left
            }
            
            Text(node.background)
                .font(.body)
                .multilineTextAlignment(.leading) // Ensures multiline text aligns left
        }
        .padding(16)
        .frame(width: 1000, height: 100, alignment: .topLeading)
        .background(.secondary)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.accentColor, lineWidth: 2)
        )
    }
    
    private var formattedDate: String {
        "\(node.bday_y.map(String.init) ?? "YYYY") / \(node.bday_m.map(String.init) ?? "MM") / \(node.bday_d.map(String.init) ?? "DD")"
    }
}

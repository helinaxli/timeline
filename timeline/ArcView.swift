//
//  ArcView.swift
//  timeline
//
//  Created by Helina L. on 8/14/26.
//

import SwiftUI

struct ArcView: View {
    @Bindable var document: TimelineDocument
    
    @State private var isShowingNewEventSheet = false
    @State private var isShowingNewStoryCharSheet = false
    @State private var isShowingNewArcSheet = false
    
    @State private var editingArc: Arc? = nil
    
    var body: some View {
        NavigationStack {
            Text("Arcs")
                .font(.title)
                .padding(.top, 24)
            
            ScrollView([.vertical, .horizontal]) {
                VStack(spacing: 10) {
                    ForEach($document.arcs) { $node in
                        ArcCardView(node: node, document: document, onEdit: {editingArc = node}, onDelete: {deleteArc(node)})
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu("Add New", systemImage: "plus") {
                        Button("New Character", systemImage: "person.badge.plus.fill") {
                            isShowingNewStoryCharSheet = true
                        }
                        Button("New Event", systemImage: "calendar.badge.plus") {
                            isShowingNewEventSheet = true
                        }
                        Button("New Arc", systemImage: "folder.fill.badge.plus") {
                            isShowingNewArcSheet = true
                        }
                    }
                }
            }
            // Sheet for creating a new character
            .sheet(isPresented: $isShowingNewStoryCharSheet) {
                NewStoryCharSheet(document: document, isPresented: $isShowingNewStoryCharSheet)
            }
            // Sheet for editing an existing character (presents when editingCharacter != nil)
            .sheet(isPresented: $isShowingNewEventSheet) {
                NewEventSheet(document: document, isPresented: $isShowingNewEventSheet)
            }
            .sheet(isPresented: $isShowingNewArcSheet) {
                NewArcSheet(document: document, isPresented: $isShowingNewArcSheet)
            }
            
            .sheet(item: $editingArc) { arc in
                // Pass the character to edit into your sheet
                NewArcSheet(document: document, isPresented: $isShowingNewArcSheet, arcToEdit: arc)
            }
        }
    }
    
    private func deleteArc(_ arc: Arc) {
        withAnimation {
            document.arcs.removeAll { $0.id == arc.id }
        }
        for event in arc.events {
            event.arcs.removeAll { $0.id == arc.id }
        }
        for storyc in arc.characters {
            storyc.arcs.removeAll { $0.id == arc.id }
        }
    }
}

struct ArcCardView: View {
    let node: Arc
    let document: TimelineDocument
    
    var onEdit: (() -> Void)? = nil
    var onDelete: (() -> Void)? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Text(node.title)
                    .font(.title)
                    .bold()
                
                Spacer()
                
                Button(action: { onEdit?() }) {
                    Image(systemName: "pencil")
                        .font(.caption)
                }
                .accessibilityLabel("Edit")
                
                Button(role: .destructive, action: { onDelete?() }) {
                    Image(systemName: "trash")
                        .font(.caption)
                }
                .accessibilityLabel("Delete")
            }
            .buttonStyle(.borderless)
        
            Text(node.summary)
                .font(.body)
                .multilineTextAlignment(.leading)
            
            Text("Characters")
                .font(.title2)
            ForEach(node.characters) { storyc in
                Text(storyc.name)
                    .font(.body)
            }
            
            Text("Events")
                .font(.title2)
            ForEach(node.events) { event in
                HStack(spacing: 10) {
                    Text(event.title)
                        .font(.body)
                        .bold()
                    
                    Text("\(event.year) / \(event.month.map(String.init) ?? "MM") / \(event.day.map(String.init) ?? "DD")")
                        .font(.body)
                    
                    Text(event.details)
                        .font(.body)
                        .multilineTextAlignment(.leading)
                        .lineLimit(1)
                    
                    Spacer()
                }
            }
        }
        .padding(16)
        .frame(width: 1000, alignment: .leading) // Forces content to left edge & expands width dynamically
        .background(document.whatColor(name: node.myColor).1)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                // .strokeBorder(Color.accentColor, lineWidth: 2)
                .strokeBorder(Color.black, lineWidth: 2)
        )
    }
}

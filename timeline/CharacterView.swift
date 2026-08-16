//
//  CharacterView.swift
//  timeline
//
//  Created by Helina L. on 8/11/26.
//

import SwiftUI

struct CharacterView: View {
    @Bindable var document: TimelineDocument
    
    @Environment(\.dismiss) private var dismiss
    @State private var isShowingNewEventSheet = false
    @State private var isShowingNewStoryCharSheet = false
    @State private var isShowingNewArcSheet = false
    
    // Track the specific character being edited
    @State private var editingCharacter: StoryChar? = nil
    
    var body: some View {
        VStack {
            Text("Characters")
                .font(.title)
                .padding(.top, 24)
            
            ScrollView([.vertical, .horizontal]) {
                VStack(spacing: 10) {
                    ForEach($document.characters) { $node in
                        CharCardView(
                            node: node,
                            document: document,
                            onEdit: {
                                editingCharacter = node
                            },
                            onDelete: {
                                deleteCharacter(node)
                            }
                        )
                    }
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                HStack {
                    Button {
                        document.showAllChars.toggle()
                        
                        if document.showAllChars {
                            document.visibleChars = document.characters
                            for storyc in document.characters {
                                storyc.visible = true
                            }
                        } else {
                            document.visibleChars = []
                            for storyc in document.characters {
                                storyc.visible = false
                            }
                        }
                    } label: {
                        // 2. View layout (only views go here)
                        Image(systemName: document.showAllChars ? "eye" : "eye.slash.fill")
                    }
                    
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
        }
        .background(
            Button("") {
                dismiss()
            }
            .keyboardShortcut("[", modifiers: .command)
            .hidden()
        )
        .background(
            Button("") {
                dismiss()
            }
            .keyboardShortcut("1", modifiers: .command)
            .hidden()
        )
        // Sheet for creating a new character
        .sheet(isPresented: $isShowingNewStoryCharSheet) {
            NewStoryCharSheet(document: document, isPresented: $isShowingNewStoryCharSheet)
        }
        // Sheet for editing an existing character (presents when editingCharacter != nil)
        .sheet(item: $editingCharacter) { character in
            // Pass the character to edit into your sheet
            NewStoryCharSheet(document: document, isPresented: $isShowingNewStoryCharSheet, characterToEdit: character)
        }
        .sheet(isPresented: $isShowingNewEventSheet) {
            NewEventSheet(document: document, isPresented: $isShowingNewEventSheet)
        }
        .sheet(isPresented: $isShowingNewArcSheet) {
            NewArcSheet(document: document, isPresented: $isShowingNewArcSheet)
        }
    }
    
    private func deleteCharacter(_ character: StoryChar) {
        withAnimation {
            document.characters.removeAll { $0.id == character.id }
        }
        for event in character.events {
            event.characters.removeAll { $0.id == character.id }
        }
        for arc in character.arcs {
            arc.characters.removeAll { $0.id == character.id }
        }
    }
}

struct CharCardView: View {
    @Bindable var node: StoryChar
    let document: TimelineDocument

    var onEdit: (() -> Void)? = nil
    var onDelete: (() -> Void)? = nil
    
    @State private var isShowingDeleteAlert = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header: Name + Date
            HStack(spacing: 10) {
                Text(node.name)
                    .font(.title2)
                    .bold()
                
                Text(formattedDate)
                    .font(.body)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                HStack(spacing: 12) {
                    Button {
                        for event in node.events {
                            event.side = "left"
                        }
                    } label: {
                        Image(systemName: "hand.point.left.fill")
                            .font(.caption)
                    }
                    
                    Button {
                        for event in node.events {
                            event.side = "right"
                        }
                    } label: {
                        Image(systemName: "hand.point.right.fill")
                            .font(.caption)
                    }
                    
                    Button {
                        // 1. Action logic (state changes go here)
                        node.visible.toggle()
                        
                        if node.visible {
                            document.visibleChars.append(node)
                        } else {
                            document.visibleChars.removeAll { $0.id == node.id }
                        }
                        
                        document.showAllChars = document.visibleChars == document.characters
                    } label: {
                        // 2. View layout (only views go here)
                        Image(systemName: node.visible ? "eye" : "eye.slash.fill")
                            .font(.caption)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Toggle Arc Visibility")
                    
                    Button(action: { onEdit?() }) {
                        Image(systemName: "pencil")
                            .font(.caption)
                    }
                    .accessibilityLabel("Edit")
                    
                    Button(role: .destructive, action: { isShowingDeleteAlert = true }) {
                        Image(systemName: "trash")
                            .font(.caption)
                    }
                    .accessibilityLabel("Delete")
                }
                .buttonStyle(.borderless)
            }
            
            .alert("Delete Character?", isPresented: $isShowingDeleteAlert) {
                Button("Delete", role: .destructive) {
                    onDelete?()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Are you sure you want to delete \(node.name)? This action cannot be undone.")
            }
            
            // Content: Background description
            Text(node.background)
                .font(.body)
                .multilineTextAlignment(.leading)
                .lineLimit(2) // Truncates gracefully if text is too long for the card height
            
            Text("Arcs")
                .font(.headline)
            ForEach(node.arcs) { arc in
                Text(arc.title)
                    .font(.body)
            }
        }
        .padding(16)
        .frame(width: 1000) // Fixed width, flexible height
        .background(document.whatColor(name: node.myColor).1)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(Color.black, lineWidth: 2)
        )
    }
    
    private var formattedDate: String {
        "\(node.bday_y.map(String.init) ?? "YYYY") / \(node.bday_m.map(String.init) ?? "MM") / \(node.bday_d.map(String.init) ?? "DD")"
    }
}

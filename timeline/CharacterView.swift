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
    @State private var isShowingNewStoryCharSheet = false
    
    // Track the specific character being edited
    @State private var editingCharacter: StoryChar? = nil
    
    var body: some View {
        NavigationStack {
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
                            // stuff
                        }
                    }
                }
            }
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
        }
    }
    
    private func deleteCharacter(_ character: StoryChar) {
        withAnimation {
            document.characters.removeAll { $0.id == character.id }
        }
    }
}

struct CharCardView: View {
    let node: StoryChar
    let document: TimelineDocument

    var onEdit: (() -> Void)? = nil
    var onDelete: (() -> Void)? = nil

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
            }
            
            // Content: Background description
            Text(node.background)
                .font(.body)
                .multilineTextAlignment(.leading)
                .lineLimit(2) // Truncates gracefully if text is too long for the card height
            
            // Bottom Action Bar
            HStack {
                Spacer()
                
                HStack(spacing: 12) {
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
            }
        }
        .padding(16)
        .frame(width: 1000, height: 100) // Fixed width, flexible height
        // .frame(minHeight: 100) // Ensures consistent minimum height
        .background(.secondary.opacity(0.2))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(Color.accentColor, lineWidth: 2)
        )
    }
    
    private var formattedDate: String {
        "\(node.bday_y.map(String.init) ?? "YYYY") / \(node.bday_m.map(String.init) ?? "MM") / \(node.bday_d.map(String.init) ?? "DD")"
    }
}

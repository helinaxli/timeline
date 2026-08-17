//
//  NewEvent.swift
//  timeline
//
//  Created by Helina L. on 8/3/26.
//

import SwiftUI
import SwiftData

struct NewEventSheet: View {
    @Bindable var document: TimelineDocument
    @State private var event = Event(id: UUID())
    @Binding var isPresented: Bool
    var eventToEdit: Event? = nil
    private var isEditing: Bool {
        eventToEdit != nil
    }
    
    @State private var charInputText: String = ""
    @State private var selectedChars: [StoryChar] = []
    @FocusState private var isCharTextFieldFocused: Bool
    
    var filteredCharacters: [StoryChar] {
        guard !charInputText.trimmingCharacters(in: .whitespaces).isEmpty else { return [] }
        return document.characters.filter { character in
            character.name.localizedCaseInsensitiveContains(charInputText) &&
            !selectedChars.contains(character)
        }
    }
    
    @State private var arcInputText: String = ""
    @State private var selectedArcs: [Arc] = []
    @FocusState private var isArcTextFieldFocused: Bool
    
    var filteredArcs: [Arc] {
        guard !arcInputText.trimmingCharacters(in: .whitespaces).isEmpty else {return []}
        return document.arcs.filter { arc in
            arc.title.localizedCaseInsensitiveContains(arcInputText) &&
            !selectedArcs.contains(arc)
        }
    }
    
    @Environment(\.dismiss) private var dismiss
    
    private var isYearInvalid: Bool {
        event.year < document.config.startYear || event.year > document.config.endYear
    }
    
    private let labelWidth: CGFloat = 50
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(isEditing ? "Edit Event" : "New Event")
                .font(.title2)
                .bold()
            
            HStack(spacing: 12) {
                TextField("Event Name", text: $event.title)
                    .textFieldStyle(.roundedBorder)
            }
            
            HStack(spacing: 8) {
                TextField("Year", value: $event.year, format: .number, prompt: Text("Year"))
                    .multilineTextAlignment(.center)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 120)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(isYearInvalid ? Color.red : Color.clear, lineWidth: 1)
                    )
                
                if isYearInvalid {
                    Label("Year not in range.", systemImage: "exclamationmark.triangle.fill")
                        .font(.caption)
                        .foregroundStyle(.red)
                        .transition(.opacity)
                }
                
                TextField("Month", value: $event.month, format: .number, prompt: Text("Month"))
                    .multilineTextAlignment(.center)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 80)
                
                TextField("Day", value: $event.day, format: .number, prompt: Text("Day"))
                    .multilineTextAlignment(.center)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 80)
            }
            
            TextField("Event Details", text: $event.details, axis: .vertical)
                .textFieldStyle(.roundedBorder)
            
            // 1. Display Selected Characters Above Input
            if !selectedChars.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(selectedChars) { storyc in
                            HStack(spacing: 6) {
                                VStack(alignment: .leading, spacing: 1) {
                                    Text(storyc.name)
                                        .font(.subheadline)
                                        // .fontWeight(.semibold)
                                }
                                
                                Button(action: {
                                    removeCharacter(storyc)
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.caption)
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
//                            .background(Color.blue.opacity(0.15))
//                            .foregroundColor(.blue)
                            .foregroundColor(document.whatColor(name: storyc.myColor).0)
                            .background(document.whatColor(name: storyc.myColor).1)
                            .clipShape(Capsule())
                        }
                    }
                }
            }
            
            // 2. Input TextField
            TextField("Search character name...", text: $charInputText)
                .textFieldStyle(.roundedBorder)
                .focused($isCharTextFieldFocused)
                .disableAutocorrection(true)
            
            // 3. Dropdown Menu for Matching StoryChars
            if isCharTextFieldFocused && !filteredCharacters.isEmpty {
                VStack(alignment: .leading, spacing: 0) {
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 0) {
                            ForEach(filteredCharacters) { storyc in
                                Button(action: {
                                    selectCharacter(storyc)
                                }) {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(storyc.name)
                                                .font(.body)
                                                .foregroundColor(document.whatColor(name: storyc.myColor).0)
                                        }
                                        Spacer()
                                    }
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 12)
                                    //.contentShape(Rectangle())
                                    // .background(Color.blue.opacity(0.15))
                                    .background(document.whatColor(name: storyc.myColor).1)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .frame(maxHeight: 200) // Limits dropdown height
                }
                // .background(.secondary)
                //.background(Color.blue.opacity(0.15))
                .cornerRadius(8)
                .shadow(color: Color.black.opacity(0.15), radius: 5, x: 0, y: 3)
            }
            
            if !selectedArcs.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(selectedArcs) { arc in
                            HStack(spacing: 6) {
                                VStack(alignment: .leading, spacing: 1) {
                                    Text(arc.title)
                                        .font(.subheadline)
                                        // .fontWeight(.semibold)
                                }
                                
                                Button(action: {
                                    removeArc(arc)
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.caption)
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            // .background(Color.blue.opacity(0.15))
                            // .foregroundColor(.blue)
                            .foregroundColor(document.whatColor(name: arc.myColor).0)
                            .background(document.whatColor(name: arc.myColor).1)
                            .clipShape(Capsule())
                        }
                    }
                }
            }
            
            // 2. Input TextField
            TextField("Search arc title...", text: $arcInputText)
                .textFieldStyle(.roundedBorder)
                .focused($isArcTextFieldFocused)
                .disableAutocorrection(true)
            
            // 3. Dropdown Menu for Matching StoryChars
            if isArcTextFieldFocused && !filteredArcs.isEmpty {
                VStack(alignment: .leading, spacing: 0) {
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 0) {
                            ForEach(filteredArcs) { arc in
                                Button(action: {
                                    selectArc(arc)
                                }) {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(arc.title)
                                                .font(.body)
                                                .foregroundColor(document.whatColor(name: arc.myColor).0)
                                        }
                                        Spacer()
                                    }
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 12)
                                    // .contentShape(Rectangle())
                                    .background(document.whatColor(name: arc.myColor).1)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .frame(maxHeight: 200) // Limits dropdown height
                }
                // .background(.secondary)
                //.background(Color.blue.opacity(0.15))
                .cornerRadius(8)
                .shadow(color: Color.black.opacity(0.15), radius: 5, x: 0, y: 3)
            }
            
            HStack {
                Button("Cancel", role: .cancel) {
                    dismiss()
                }
                
                Spacer()
                
                Button(isEditing ? "Save" : "Create") {
                    if let masterIndex = document.events.firstIndex(where: { $0.id == event.id }) {
                        event.characters = selectedChars
                        document.updateEvent(masterIndex: masterIndex, updatedEvent: event)
                    } else {
                        event.characters = selectedChars
                        document.addEvent(event: event)
                    }
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .keyboardShortcut(.defaultAction)
                .disabled(isYearInvalid)
            }
        }
        .padding(20)
        .frame(minWidth: 350, minHeight: 250)
        .onAppear {
            if let eventToEdit {
                event = eventToEdit
                selectedChars = eventToEdit.characters
                selectedArcs = eventToEdit.arcs
            }
        }
    }

    // Private functions are now in non-local struct scope
    private func selectCharacter(_ character: StoryChar) {
        if !selectedChars.contains(where: { $0.id == character.id }) {
            selectedChars.append(character)
        }
        
        // 1. Link Character <-> Event
        if !character.events.contains(where: { $0.id == event.id }) {
            character.events.append(event)
        }
        
        // 2. Link Character <-> Arcs tied to this Event
        for arc in selectedArcs {
            if !character.arcs.contains(where: { $0.id == arc.id }) {
                character.arcs.append(arc)
            }
        }
    }

    private func removeCharacter(_ character: StoryChar) {
        // 1. Remove character from this sheet's local selection
        selectedChars.removeAll { $0.id == character.id }
        
        // 2. Unlink character from this event
        character.events.removeAll { $0.id == event.id }
        
        // 3. Clean up Arcs (Scenario 2 Fix)
        // Check every arc currently selected in this view
        for arc in selectedArcs {
            // Does this character belong to ANY OTHER events in this arc?
            let hasOtherSharedEvents = arc.events.contains { arcEvent in
                arcEvent.id != event.id && character.events.contains { $0.id == arcEvent.id }
            }
            
            // If they share no other events in this arc, remove character from arc
            if !hasOtherSharedEvents {
                arc.characters.removeAll { $0.id == character.id }
                character.arcs.removeAll { $0.id == arc.id }
            }
        }
    }

    private func removeArc(_ arc: Arc) {
        // 1. Remove arc from this sheet's local selection
        selectedArcs.removeAll { $0.id == arc.id }
        
        // 2. Unlink arc from this event
        arc.events.removeAll { $0.id == event.id }
        
        // 3. Clean up Characters (Scenario 4 Fix)
        // Check every character currently selected in this view
        for character in selectedChars {
            // Does this character share ANY OTHER events in this arc?
            let hasOtherSharedEvents = arc.events.contains { arcEvent in
                arcEvent.id != event.id && character.events.contains { $0.id == arcEvent.id }
            }
            
            // If they share no other events in this arc, remove relationship
            if !hasOtherSharedEvents {
                arc.characters.removeAll { $0.id == character.id }
                character.arcs.removeAll { $0.id == arc.id }
            }
        }
    }
    
    private func selectArc(_ arc: Arc) {
        if !selectedArcs.contains(where: { $0.id == arc.id }) {
            selectedArcs.append(arc)
        }
        
        // 1. Link Arc <-> Event
        if !arc.events.contains(where: { $0.id == event.id }) {
            arc.events.append(event)
        }
        
        // 2. Link Arc <-> Characters tied to this Event
        for character in selectedChars {
            if !arc.characters.contains(where: { $0.id == character.id }) {
                arc.characters.append(character)
            }
        }
    }
}

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
    
    @State private var inputText: String = ""
    @State private var selectedChars: [StoryChar] = []
    @FocusState private var isTextFieldFocused: Bool
    
    var filteredCharacters: [StoryChar] {
        guard !inputText.trimmingCharacters(in: .whitespaces).isEmpty else { return [] }
        return document.characters.filter { character in
            character.name.localizedCaseInsensitiveContains(inputText) &&
            !selectedChars.contains(character)
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
                .padding()
            
            // 1. Display Selected Characters Above Input
            if !selectedChars.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(selectedChars) { storyc in
                            HStack(spacing: 6) {
                                VStack(alignment: .leading, spacing: 1) {
                                    Text(storyc.name)
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                }
                                
                                Button(action: {
                                    removeCharacter(storyc)
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.caption)
                                }
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color.indigo.opacity(0.15))
                            .foregroundColor(.indigo)
                            .clipShape(Capsule())
                        }
                    }
                }
            }
            
            // 2. Input TextField
            TextField("Search character name...", text: $inputText)
                .textFieldStyle(.roundedBorder)
                .focused($isTextFieldFocused)
                .disableAutocorrection(true)
            
            // 3. Dropdown Menu for Matching StoryChars
            if isTextFieldFocused && !filteredCharacters.isEmpty {
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
                                                .foregroundColor(.primary)
                                        }
                                        Spacer()
                                    }
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 12)
                                    .background(.ultraThinMaterial)
                                }
                                .buttonStyle(.plain)
                                Divider()
                            }
                        }
                    }
                    .frame(maxHeight: 200) // Limits dropdown height
                }
                .background(.secondary)
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
                .disabled(isYearInvalid)
            }
        }
        .padding(20)
        .frame(minWidth: 350, minHeight: 250)
        .onAppear {
            // Populate form fields if editing an existing character
            if let eventToEdit {
                event = eventToEdit
                selectedChars = eventToEdit.characters
            }
        }
    } // <-- Closing brace for `var body: some View` added here

    // Private functions are now in non-local struct scope
    private func selectCharacter(_ character: StoryChar) {
        selectedChars.append(character)
        inputText = "" // Clear textfield for next entry
        character.events.append(event)
    }

    private func removeCharacter(_ character: StoryChar) {
        selectedChars.removeAll { $0 == character }
        character.events.removeAll { $0 == event}
    }
}

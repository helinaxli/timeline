//
//  NewCharacterSheet.swift
//  timeline
//
//  Created by Helina L. on 8/6/26.
//

import SwiftUI

struct NewStoryCharSheet: View {
    @Bindable var document: TimelineDocument
    @Binding var isPresented: Bool
    
    // Optional character passed in for editing mode
    var characterToEdit: StoryChar? = nil
    
    // Environment property to dismiss the sheet cleanly
    @Environment(\.dismiss) private var dismiss
    
    // Local state for the form inputs
    @State private var storyc = StoryChar(id: UUID())
    
    // Helper to check if we are editing vs creating
    private var isEditing: Bool {
        characterToEdit != nil
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(isEditing ? "Edit Character" : "New Character")
                .font(.title2)
                .bold()
            
            TextField("Character Name", text: $storyc.name)
                .textFieldStyle(.roundedBorder)
            
            Text("Birthday")
                .font(.body)
                .bold()
            
            HStack(spacing: 8) {
                TextField("Year", value: $storyc.bday_y, format: .number, prompt: Text("Year"))
                    .multilineTextAlignment(.center)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 120)
                
                TextField("Month", value: $storyc.bday_m, format: .number, prompt: Text("Month"))
                    .multilineTextAlignment(.center)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 80)
                
                TextField("Day", value: $storyc.bday_d, format: .number, prompt: Text("Day"))
                    .multilineTextAlignment(.center)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 80)
            }
            
            TextField("Character Background", text: $storyc.background, axis: .vertical)
                .textFieldStyle(.roundedBorder)
            
            HStack {
                Button("Cancel", role: .cancel) {
                    dismiss()
                }
                
                Spacer()
                
                Button(isEditing ? "Save" : "Create") {
                    saveCharacter()
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(20)
        .frame(minWidth: 350, minHeight: 250)
        .onAppear {
            // Populate form fields if editing an existing character
            if let characterToEdit {
                storyc = characterToEdit
            }
        }
    }
    
    private func saveCharacter() {
        if let index = document.characters.firstIndex(where: { $0.id == storyc.id }) {
            // Existing character found: update in-place
            document.characters[index] = storyc
        } else {
            // New character: append to list
            document.characters.append(storyc)
        }
    }
}

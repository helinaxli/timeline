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
    @State private var isExpanded = false
    
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
            
            // Color
            VStack(spacing: 6) {
                // 1. Dropdown Header Button
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isExpanded.toggle()
                    }
                }) {
                    HStack {
                        Text(storyc.myColor.isEmpty ? "Select Color" : storyc.myColor)
                            .font(.body)
                            // .fontWeight(.semibold)
                            .foregroundColor(document.whatColor(name: storyc.myColor).0)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.up")
                            .font(.body)
                            .rotationEffect(.degrees(isExpanded ? 0 : 180))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 6)
                    .background(document.whatColor(name: storyc.myColor).1)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.black, lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)

                // 2. Expandable Items List
                if isExpanded {
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 0) {
                            ForEach(document.colorPalette, id: \.self) { col in
                                Button(action: {
                                    storyc.myColor = col
                                    withAnimation {
                                        isExpanded = false
                                    }
                                }) {
                                    HStack {
                                        Text(col)
                                            .font(.body)
                                            .foregroundColor(document.whatColor(name: col).0)
                                            //.fontWeight(.semibold)
                                        Spacer()
                                    }
                                    .padding(.vertical, 6)
                                    .padding(.horizontal, 16)
                                    .background(document.whatColor(name: col).1)
                                }
                                .buttonStyle(.plain)
                            }
                        }

                    }
                    .frame(maxHeight: 180)
                    .background(Color.white)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.black, lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.15), radius: 6, x: 2, y: 4)
                }
            }
            
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

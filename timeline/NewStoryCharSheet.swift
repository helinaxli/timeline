//
//  NewCharacterSheet.swift
//  timeline
//
//  Created by Helina L. on 8/6/26.
//

import SwiftUI
import SwiftData

struct NewStoryCharSheet: View {
    @Bindable var document: TimelineDocument
    @Bindable var storyc = StoryChar(id: UUID())
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("New Character")
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
                Spacer()
                Button("Create") {
                    document.characters.append(storyc)
                    isPresented = false
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(20)
        .frame(minWidth: 350, minHeight: 250)
    }
}

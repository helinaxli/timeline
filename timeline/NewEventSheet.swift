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
    @Bindable var event = Event(id: UUID())
    @Binding var isPresented: Bool
    private var isYearInvalid: Bool {
        event.year < document.config.startYear || event.year > document.config.endYear
    }
    
    private let labelWidth: CGFloat = 50
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("New Event")
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
            
            HStack {
                Spacer()
                Button("Create") {
                    document.add(event: event)
                    isPresented = false
                }
                .buttonStyle(.borderedProminent)
                .disabled(isYearInvalid)
            }
        }
        .padding(20)
        .frame(minWidth: 350, minHeight: 250)
    }
}

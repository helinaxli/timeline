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
            
            HStack {
                Button("Cancel", role: .cancel) {
                    dismiss()
                }
                
                Spacer()
                
                Button(isEditing ? "Save" : "Create") {
                    if let masterIndex = document.events.firstIndex(where: { $0.id == event.id }) {
                        document.updateEvent(masterIndex: masterIndex, updatedEvent: event)
                    } else {
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
            }
        }
    }
}

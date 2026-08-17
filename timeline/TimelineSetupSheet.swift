//
//  TimelineSetUpSheet.swift
//  timeline
//
//  Created by Helina L. on 8/16/26.
//

import SwiftData
import SwiftUI

struct TimelineSetupSheet: View {
    @Bindable var document: TimelineDocument
    @Binding var isPresented: Bool
    private var isYearRangeInvalid: Bool {
        document.config.endYear < document.config.startYear
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Set Up Your Timeline")
                .font(.title2)
                .bold()
            
            Form {
                TextField("Title", text: $document.title)
                    .textFieldStyle(.roundedBorder)
                    .padding(.bottom, 8)
                
                TextField("Start Year", value: $document.config.startYear, format: .number)
                    .textFieldStyle(.roundedBorder)
                TextField("End Year", value: $document.config.endYear, format: .number)
                    .textFieldStyle(.roundedBorder)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(isYearRangeInvalid ? Color.red : Color.clear, lineWidth: 1)
                    )
                
                if isYearRangeInvalid {
                    Label("End year cannot be earlier than start year.", systemImage: "exclamationmark.triangle.fill")
                        .font(.caption)
                        .foregroundStyle(.red)
                        .transition(.opacity)
                }
                Text("There is no min. for start year / no max. for end year.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.bottom, 8)
                
                TextField("Months Per Year", value: $document.config.numMonthsPerYear, format: .number)
                    .textFieldStyle(.roundedBorder)
                Text("This can customize this for each year later.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                
                TextField("Days Per Month", value: $document.config.numDaysPerMonth, format: .number)
                    .textFieldStyle(.roundedBorder)
                Text("You can customize this for each month later.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
            }
            
            HStack {
                Button("Cancel", role: .cancel) {
                    cancelSetup()
                }
                .keyboardShortcut(.escape, modifiers: [])
                
                Spacer()
                
                Button("Get Started") {
                    document.configureTimeline()
                    isPresented = false
                }
                .buttonStyle(.borderedProminent)
                .disabled(isYearRangeInvalid)
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding()
        .frame(minWidth: 250, minHeight: 250) // Essential for macOS sheet sizing
    }
    
    private func cancelSetup() {
        isPresented = false
        
        #if os(macOS)
        // If this sheet was opened inside a new, unconfigured DocumentGroup window,
        // closing the window returns the user to the macOS Open/Welcome dialog.
        NSApp.keyWindow?.close()
        #else
        dismiss()
        #endif
    }
}

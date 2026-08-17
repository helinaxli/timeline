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
    var configToEdit: TimelineConfig? = nil
    private var isEditing: Bool {
        configToEdit != nil
    }
    
    @State private var tlconfig = TimelineConfig()
    
    private var isYearRangeInvalid: Bool {
        tlconfig.endYear < tlconfig.startYear
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(isEditing ? "Configure Your Timeline" : "Set Up Your Timeline")
                .font(.title2)
                .bold()
            
            Form {
                TextField("Title", text: $tlconfig.title)
                    .textFieldStyle(.roundedBorder)
                    .padding(.bottom, 8)
                
                TextField("Start Year", value: $tlconfig.startYear, format: .number)
                    .textFieldStyle(.roundedBorder)
                TextField("End Year", value: $tlconfig.endYear, format: .number)
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
                if isEditing {
                    Label("Caution: Events outside of year range will be deleted.", systemImage: "exclamationmark.triangle")
                        .font(.caption)
                        .foregroundStyle(.orange)
                        .transition(.opacity)
                }
                
                Text("There is no min. for start year / no max. for end year.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.bottom, 8)
                
                TextField("Months Per Year", value: $tlconfig.numMonthsPerYear, format: .number)
                    .textFieldStyle(.roundedBorder)
                Text("This can customize this for each year later.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                
                TextField("Days Per Month", value: $tlconfig.numDaysPerMonth, format: .number)
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
                
                Button(isEditing ? "Save" : "Get Started") {
                    if isEditing {
                        deleteYears()
                        addYears()
                    } else {
                        for y in tlconfig.startYear...tlconfig.endYear {
                            document.years.append(createFantasyYear(y))
                        }
                    }
                    tlconfig.isConfigured = true
                    document.title = tlconfig.title
                    document.config = tlconfig
                    try? document.modelContext?.save()
                    isPresented = false
                }
                .buttonStyle(.borderedProminent)
                .disabled(isYearRangeInvalid)
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding()
        .frame(minWidth: 250, minHeight: 250)
        .onAppear {
            if let configToEdit {
                tlconfig = configToEdit
            }
        }
    }
    
    private func deleteYears() {
        if let context = document.modelContext {
            // Find all out-of-bounds years
            let yearsToDelete = document.years.filter {
                $0.myself < tlconfig.startYear || $0.myself > tlconfig.endYear
            }

            for year in yearsToDelete {
                // 1. Explicitly deletes months stored in year
                for month in year.months {
                    context.delete(month)
                }
                year.months.removeAll()
                
                // 2. Delete top-level year events stored in year
//                for event in year.events {
//                    context.delete(event)
//                }
//                year.events.removeAll()

                 // 3. Delete top-level document events outside year bounds (if document maintains an events array)
                document.events.removeAll { event in
                    let isOut = event.year < tlconfig.startYear || event.year > tlconfig.endYear
                    if isOut { context.delete(event) }
                    return isOut
                }

                context.delete(year)
            }

            // Update document's in-memory array
            document.years.removeAll {
                $0.myself < tlconfig.startYear || $0.myself > tlconfig.endYear
            }
        }
    }
    
    private func addYears() {
        if tlconfig.startYear < document.config.startYear {
            let frontYears = (tlconfig.startYear..<document.config.startYear).map { y in
                createFantasyYear(y)
            }
            document.years.insert(contentsOf: frontYears, at: 0)
        }
        
        // Append missing years
        if tlconfig.endYear > document.config.endYear {
            let backYears = ((document.config.endYear + 1)...tlconfig.endYear).map { y in
                createFantasyYear(y)
            }
            document.years.append(contentsOf: backYears)
        }
    }
    
    private func createFantasyYear(_ yearNumber: Int) -> FantasyYear {
        let yearModel = FantasyYear(myself: yearNumber, numMonths: tlconfig.numMonthsPerYear)
        for m in 1...tlconfig.numMonthsPerYear {
            let monthModel = FantasyMonth(myself: m, year: yearNumber, numDays: tlconfig.numDaysPerMonth)
            yearModel.months.append(monthModel)
        }
        return yearModel
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

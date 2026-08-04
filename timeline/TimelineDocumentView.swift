//
//  TimelineDocumentView.swift
//  timeline
//
//  Created by Helina L. on 8/3/26.
//

import SwiftUI
import SwiftData

struct TimelineDocumentContainerView: View {
    
    @Query private var documents: [TimelineDocument]
    var body: some View {
        if let document = documents.first {
            // Pass the guaranteed non-optional model down
            TimelineDocumentView(document: document)
        } else {
            // Displays briefly while SwiftData boots up the document context
            ProgressView("Loading document...")
        }
    }
}

struct TimelineDocumentView: View {
    @Bindable var document: TimelineDocument
    @State private var showSetupSheet = false
    
    @State private var isShowingNewEventSheet = false

    var body: some View {
        NavigationStack {
            VStack {
                if document.config.isConfigured {
                    Text(document.title)
                        .font(.headline)
                    
                    // Main timeline content goes here
                } else {
                    Text("Setting up your timeline...")
                        .foregroundStyle(.secondary)
                }
            }
            // .navigationTitle(document.title)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu("Add New", systemImage: "plus") {
                        Button("New Character", systemImage: "person.badge.plus.fill") {
                            // stuff
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
            .task(id: document) {
                checkInitialSetup()
            }
            // Present setup sheet if unconfigured
            .sheet(isPresented: $showSetupSheet) {
                TimelineSetupSheet(document: document, isPresented: $showSetupSheet)
                    .interactiveDismissDisabled()
            }
            .sheet(isPresented: $isShowingNewEventSheet) {
                NewEventSheet(document: document, isPresented: $isShowingNewEventSheet)
            }
        }
    }

    private func checkInitialSetup() {
        // If the document's config hasn't been set up yet, show the sheet
        if !document.config.isConfigured {
            showSetupSheet = true
        }
    }
}

// Separate view file or inline struct for the pop-up
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
                Text("Note: There is no min. for start year / no max. for end year.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                
                if isYearRangeInvalid {
                    Label("End year cannot be earlier than start year.", systemImage: "exclamationmark.triangle.fill")
                        .font(.caption)
                        .foregroundStyle(.red)
                        .transition(.opacity)
                }
            }
            
            HStack {
                Spacer()
                Button("Get Started") {
                    document.config.isConfigured = true
                    isPresented = false
                }
                .buttonStyle(.borderedProminent)
                .disabled(isYearRangeInvalid)
            }
        }
        .padding()
        .frame(minWidth: 250, minHeight: 250) // Essential for macOS sheet sizing
    }
}

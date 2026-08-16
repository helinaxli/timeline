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
    
    @Environment(AppState.self) private var appState
    
    @State private var isShowingNewEventSheet = false
    @State private var isShowingNewStoryCharSheet = false
    @State private var isShowingNewArcSheet = false

    var body: some View {
        @Bindable var appState = appState
        
        NavigationStack {
            VStack {
                if document.config.isConfigured {
                    TimelinePanel(document: document)
                } else {
                    Text("Setting up your timeline...")
                        .foregroundStyle(.secondary)
                }
            }
            // .navigationTitle(document.title)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    HStack {
                        Button {
                            appState.filterVisibleOnly.toggle()
                        } label: {
                            // 2. View layout (only views go here)
                            Image(systemName: appState.filterVisibleOnly ? "eye" : "eye.fill")
                        }
                        
                        NavigationLink {
                            CharacterView(document: document)
                        } label: {
                            Label("Character View", systemImage: "person.fill")
                        }
                        
                        NavigationLink {
                            ArcView(document: document)
                        } label: {
                            Label("Arc View", systemImage: "folder.fill")
                        }
                        
                        Menu("Add New", systemImage: "plus") {
                            Button("New Character", systemImage: "person.badge.plus.fill") {
                                isShowingNewStoryCharSheet = true
                            }
                            Button("New Event", systemImage: "calendar.badge.plus") {
                                isShowingNewEventSheet = true
                            }
                            Button("New Arc", systemImage: "folder.fill.badge.plus") {
                                isShowingNewArcSheet = true
                            }
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
            .sheet(isPresented: $isShowingNewStoryCharSheet) {
                NewStoryCharSheet(document: document, isPresented: $isShowingNewStoryCharSheet)
            }
            .sheet(isPresented: $isShowingNewArcSheet) {
                NewArcSheet(document: document, isPresented: $isShowingNewArcSheet)
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

//
//  TimelineDocumentView.swift
//  timeline
//
//  Created by Helina L. on 8/3/26.
//

import SwiftUI
import SwiftData

struct TimelineDocumentView: View {
    // @Environment(TimelineDocument.self) private var document: TimelineDocument?
//     let document: TimelineDocument?
    
    @Query private var documents: [TimelineDocument]
    private var document: TimelineDocument? {
        documents.first
    }
    
    @State private var showSetupSheet = false

    var body: some View {
        NavigationStack {
            VStack {
                if let config = document?.config, config.isConfigured {
                    Text("Timeline Years: \(config.startYear) – \(config.endYear)")
                        .font(.headline)
                    
                    // Main timeline content goes here
                } else {
                    Text("Setting up your timeline...")
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle(document?.title ?? "Untitled")
            .task(id: document) {
                checkInitialSetup()
            }
            .onChange(of: document?.config.isConfigured) { _, _ in
                checkInitialSetup()
            }
            // Present setup sheet if unconfigured
            .sheet(isPresented: $showSetupSheet) {
                if let document {
                    TimelineSetupSheet(document: document, isPresented: $showSetupSheet)
                        .interactiveDismissDisabled()
                }
            }
        }
    }

    private func checkInitialSetup() {
        // If the document's config hasn't been set up yet, show the sheet
        if let config = document?.config, !config.isConfigured {
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
                
                Text("Note: There is no min. or max. for years.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                
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
        .frame(minWidth: 350, minHeight: 250) // Essential for macOS sheet sizing
    }
}

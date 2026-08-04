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
    
    @Query private var configs: [TimelineConfig]
    
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
            .task {
                print("configs:", configs.count)
            }
            .onChange(of: document?.config.isConfigured) { _, _ in
                checkInitialSetup()
            }
            // Present setup sheet if unconfigured
            .sheet(isPresented: $showSetupSheet) {
                if let config = document?.config {
                    TimelineSetupSheet(config: config, isPresented: $showSetupSheet)
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
    @Bindable var config: TimelineConfig
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Set Up Your Timeline")
                .font(.title2)
                .bold()
            
            Form {
                TextField("Start Year", value: $config.startYear, format: .number)
                    .textFieldStyle(.roundedBorder)
                TextField("End Year", value: $config.endYear, format: .number)
                    .textFieldStyle(.roundedBorder)
            }
            
            HStack {
                Spacer()
                Button("Get Started") {
                    config.isConfigured = true
                    isPresented = false
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .frame(minWidth: 350, minHeight: 250) // Essential for macOS sheet sizing
    }
}

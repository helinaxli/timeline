//
//  TimelineDocumentView.swift
//  timeline
//
//  Created by Helina L. on 8/3/26.
//

import SwiftUI
import SwiftData

struct TimelineDocumentView: View {
    @Environment(\.document) private var document: TimelineDocument?
    @Query private var configs: [TimelineConfig]
    
    @State private var showSetupSheet = false
    
    // Fallback or reference to current config
    private var currentConfig: TimelineConfig? {
        configs.first
    }

    var body: some View {
        NavigationStack {
            VStack {
                if let config = currentConfig, config.isConfigured {
                    Text("Timeline Years: \(config.startYear) – \(config.endYear)")
                        .font(.headline)
                    
                    // Main timeline content goes here
                } else {
                    Text("Setting up your timeline...")
                }
            }
            .navigationTitle("Timeline")
            .onAppear {
                checkInitialSetup()
            }
            // Present setup sheet if unconfigured
            .sheet(isPresented: $showSetupSheet) {
                if let config = currentConfig {
                    TimelineSetupSheet(config: config, isPresented: $showSetupSheet)
                }
            }
        }
    }

    private func checkInitialSetup() {
        if configs.isEmpty {
            // First time opening this blank document: create default config
            let newConfig = TimelineConfig()
            modelContext.insert(newConfig)
            showSetupSheet = true
        } else if let config = currentConfig, !config.isConfigured {
            // Config exists but hasn't been completed yet
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
            Text("Configure Timeline")
                .font(.title2)
                .bold()
            
            Form {
                Section("Timeline Range") {
                    Stepper("Start Year: \(config.startYear)", value: $config.startYear)
                    Stepper("End Year: \(config.endYear)", value: $config.endYear)
                }
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

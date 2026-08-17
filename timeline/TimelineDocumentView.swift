//
//  TimelineDocumentView.swift
//  timeline
//
//  Created by Helina L. on 8/3/26.
//

import SwiftUI
import SwiftData

struct TimelineDocumentContainerView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var documents: [TimelineDocument]
    
    var body: some View {
        Group {
            if let document = documents.first {
                TimelineDocumentView(document: document)
            } else {
                ProgressView("Loading document...")
            }
        }
        .onDisappear {
            if modelContext.hasChanges {
                modelContext.rollback()
            }
        }
    }
}

enum AppRoute: Hashable {
    case character
    case arc
}

struct TimelineDocumentView: View {
    @Bindable var document: TimelineDocument
    @State private var showSetupSheet = false
    
    @Environment(AppState.self) private var appState
    
    @State private var navigationPath = NavigationPath()
    
    @State private var isShowingNewEventSheet = false
    @State private var isShowingNewStoryCharSheet = false
    @State private var isShowingNewArcSheet = false

    var body: some View {
        @Bindable var appState = appState
        
        NavigationStack(path: $navigationPath) {
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
                        
                        NavigationLink(value: AppRoute.character) {
                            Label("Character View", systemImage: "person.fill")
                        }
                        
                        NavigationLink(value: AppRoute.arc) {
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
            .navigationDestination(for: AppRoute.self) { route in
                switch route {
                case .character:
                    CharacterView(document: document, navigationPath: $navigationPath)
                case .arc:
                    ArcView(document: document, navigationPath: $navigationPath)
                }
            }
            .background(
                Button("") {
                    navigationPath.append(AppRoute.character)
                }
                .keyboardShortcut("2", modifiers: .command)
                .opacity(0) // Use opacity(0) instead of .hidden() to preserve shortcut routing
            )
            .background(
                Button("") {
                    navigationPath.append(AppRoute.arc)
                }
                .keyboardShortcut("3", modifiers: .command)
                .opacity(0) // Use opacity(0) instead of .hidden() to preserve shortcut routing
            )
            .task(id: document) {
                checkInitialSetup()
            }
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
        if !document.config.isConfigured {
            showSetupSheet = true
        }
    }
}

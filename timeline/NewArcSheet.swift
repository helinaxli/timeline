//
//  NewArcSheet.swift
//  timeline
//
//  Created by Helina L. on 8/14/26.
//

import SwiftUI

struct NewArcSheet: View {
    @Bindable var document: TimelineDocument
    @Binding var isPresented: Bool
    
    var arcToEdit: Arc? = nil
    @Environment(\.dismiss) private var dismiss
    @State private var arc = Arc(id: UUID())
    
    private var isEditing: Bool {
        arcToEdit != nil
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(isEditing ? "Edit Arc" : "New Arc")
                .font(.title2)
                .bold()
            
            TextField("Arc Title", text: $arc.title)
                .textFieldStyle(.roundedBorder)
            
            TextField("Summary", text: $arc.summary, axis: .vertical)
                .textFieldStyle(.roundedBorder)
            
            // Color
            VStack(alignment: .leading, spacing: 0) {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 0) {
                        ForEach(document.colorPalette) { col in
                            Button(action: {
                                // selected color
                            }) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(col.name)
                                            .font(.body)
                                            .foregroundColor(col)
                                    }
                                    Spacer()
                                }
                                .padding(.vertical, 8)
                                .padding(.horizontal, 12)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .frame(maxHeight: 200)
            }
            
            HStack {
                Button("Cancel", role: .cancel) {
                    dismiss()
                }
                
                Spacer()
                
                Button(isEditing ? "Save" : "Create") {
                    saveArc()
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(20)
        .frame(minWidth: 350, minHeight: 250)
        .onAppear {
            // Populate form fields if editing an existing character
            if let arcToEdit {
                arc = arcToEdit
            }
        }
    }
    
    private func saveArc() {
        if let index = document.arcs.firstIndex(where: { $0.id == arc.id}) {
            document.arcs[index] = arc
        } else {
            document.arcs.append(arc)
        }
    }
}

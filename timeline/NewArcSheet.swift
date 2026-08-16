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
                        // Fix 1 & 2: Use id: \.self to iterate over [Color] directly
                        ForEach(document.colorPalette, id: \.self) { col in
                            Button(
                                action: {
                                    arc.myColor = col
                                },
                                label: {
                                    HStack {
                                        Text(col)
                                            .foregroundColor(whatColor(name: col).0)
                                        Spacer()
                                    }
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 12)
                                    .background(whatColor(name: col).1)
                                }
                            )
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

public func whatColor(name: String) -> (Color, Color) {
    if name == "Red" {
        return (.red, .red.opacity(0.15))
    } else if name == "Orange" {
        return (.orange, .orange.opacity(0.15))
    } else if name == "Yellow" {
        return (.yellow, .yellow.opacity(0.15))
    } else if name == "Green" {
        return (.green, .green.opacity(0.15))
    } else if name == "Mint" {
        return (.mint, .mint.opacity(0.15))
    } else if name == "Blue" {
        return (.blue, .blue.opacity(0.15))
    } else if name == "Purple" {
        return (.purple, .purple.opacity(0.15))
    } else if name == "Indigo" {
        return (.indigo, .indigo.opacity(0.15))
    } else if name == "Pink" {
        return (.pink, .pink.opacity(0.15))
    } else {
        return (.black, .white)
    }
}

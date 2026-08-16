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
    @State private var isExpanded = false
    
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
            VStack(spacing: 6) {
                // 1. Dropdown Header Button
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isExpanded.toggle()
                    }
                }) {
                    HStack {
                        Text(arc.myColor.isEmpty ? "Select Color" : arc.myColor)
                            .font(.body)
                            // .fontWeight(.semibold)
                            .foregroundColor(whatColor(name: arc.myColor).0)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.up")
                            .font(.body)
                            .rotationEffect(.degrees(isExpanded ? 0 : 180))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 6)
                    .background(whatColor(name: arc.myColor).1)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.black, lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)

                // 2. Expandable Items List
                if isExpanded {
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 0) {
                            ForEach(document.colorPalette, id: \.self) { col in
                                Button(action: {
                                    arc.myColor = col
                                    withAnimation {
                                        isExpanded = false
                                    }
                                }) {
                                    HStack {
                                        Text(col)
                                            .font(.body)
                                            .foregroundColor(whatColor(name: col).0)
                                            //.fontWeight(.semibold)
                                        Spacer()
                                    }
                                    .padding(.vertical, 6)
                                    .padding(.horizontal, 16)
                                    .background(whatColor(name: col).1)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .id(document.colorPalette)
                    }
                    .frame(maxHeight: 180)
                    .background(Color.white)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.black, lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.15), radius: 6, x: 2, y: 4)
                }
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
            // document.colorPalette = ["Default", "Red", "Orange", "Yellow", "Green", "Mint", "Blue", "Indigo", "Purple", "Pink"]
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
        return (.black, .red.opacity(0.15))
    } else if name == "Orange" {
        return (.black, .orange.opacity(0.15))
    } else if name == "Yellow" {
        return (.black, .yellow.opacity(0.15))
    } else if name == "Green" {
        return (.black, .green.opacity(0.15))
    } else if name == "Mint" {
        return (.black, .mint.opacity(0.15))
    } else if name == "Blue" {
        return (.black, .blue.opacity(0.15))
    } else if name == "Purple" {
        return (.black, .purple.opacity(0.15))
    } else if name == "Indigo" {
        return (.black, .indigo.opacity(0.15))
    } else if name == "Pink" {
        return (.black, .pink.opacity(0.15))
    } else {
        return (.black, .white)
    }
}

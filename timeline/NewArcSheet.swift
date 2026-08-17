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
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isExpanded.toggle()
                    }
                }) {
                    HStack {
                        Text(arc.myColor.isEmpty ? "Select Color" : arc.myColor)
                            .font(.body)
                            // .fontWeight(.semibold)
                            .foregroundColor(document.whatColor(name: arc.myColor).0)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.up")
                            .font(.body)
                            .rotationEffect(.degrees(isExpanded ? 0 : 180))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 6)
                    .background(document.whatColor(name: arc.myColor).1)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.black, lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)

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
                                            .foregroundColor(document.whatColor(name: col).0)
                                            //.fontWeight(.semibold)
                                        Spacer()
                                    }
                                    .padding(.vertical, 6)
                                    .padding(.horizontal, 16)
                                    .background(document.whatColor(name: col).1)
                                }
                                .buttonStyle(.plain)
                            }
                        }

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
                .keyboardShortcut(.defaultAction)
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

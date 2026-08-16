//
//  EventCard.swift
//  timeline
//
//  Created by Helina L. on 8/14/26.
//

import SwiftUI

struct EventCard: View {
    @Binding var node: Event
    
    @Environment(\.dismiss) private var dismiss
    var onEdit: (() -> Void)? = nil
    var onDelete: (() -> Void)? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Text(node.title)
                    .font(.title2)
                    .bold()
                
                Spacer()
                
                Button(action: { onEdit?() }) {
                    Image(systemName: "pencil")
                        .font(.caption)
                }
                .accessibilityLabel("Edit")
                
                Button(role: .destructive, action: { onDelete?() }) {
                    Image(systemName: "trash")
                        .font(.caption)
                }
                .accessibilityLabel("Delete")
                
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.caption)
                }
                .accessibilityLabel("Close")
            }
            .buttonStyle(.borderless)
            
            Text(formattedDate)
                .font(.body)
            
            Text("Characters")
                .font(.headline)
            ForEach(node.characters) { storyc in
                Text(storyc.name)
                    .font(.body)
            }
            
            Text("Arcs")
                .font(.headline)
            ForEach(node.arcs) { arc in
                Text(arc.title)
                    .font(.body)
            }
            
            Text("Details")
                .font(.headline)
            Text(node.details)
                .font(.body)
            
            Spacer()
        }
        .padding(20)
        .frame(minWidth: 350, minHeight: 250)
    }
    
    private var formattedDate: String {
        "\(node.year) / \(node.month.map(String.init) ?? "MM") / \(node.day.map(String.init) ?? "DD")"
    }
}

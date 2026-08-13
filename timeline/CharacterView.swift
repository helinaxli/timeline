//
//  CharacterView.swift
//  timeline
//
//  Created by Helina L. on 8/11/26.
//

import SwiftUI

struct CharacterView: View {
    @Bindable var document: TimelineDocument
    
    var body: some View {
        ScrollView([.vertical, .horizontal]) {
            VStack(spacing: 0) {
                ForEach($document.characters) { $node in
                    CharCardView(node: node)
                }
            }
        }
    }
}

struct CharCardView: View {
    let node: StoryChar
    
    var body: some View {
        VStack(spacing:0) {
            HStack(spacing: 0) {
                Text(node.name)
                    .font(.title2)
                    .bold()
                Text(formattedDate)
                    .font(.body)
            }
            
            Text(node.background)
                .font(.body)
        }
        .padding(16)
        .frame(width: 1000, height: 250, alignment: .topLeading)
        .background(.secondary)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.accentColor, lineWidth: 2)
        )
    }
    
    private var formattedDate: String {
        "\(node.bday_y.map(String.init) ?? "YYYY") / \(node.bday_m.map(String.init) ?? "MM") / \(node.bday_d.map(String.init) ?? "DD")"
    }
}

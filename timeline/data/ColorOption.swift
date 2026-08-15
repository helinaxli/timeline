//
//  ColorOptions.swift
//  timeline
//
//  Created by Helina L. on 8/15/26.
//

import SwiftUI

struct ColorOption: Identifiable, Hashable, Codable {
    let id: UUID
    let name: String
    let fgHex: String
    let bgHex: String

    var fgColor: Color { Color(hex: fgHex) }
    var bgColor: Color { Color(hex: bgHex) }

    init(id: UUID = UUID(), name: String, fgHex: String, bgHex: String) {
        self.id = id
        self.name = name
        self.fgHex = fgHex
        self.bgHex = bgHex
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        case 8: // ARGB / RGBA (32-bit)
            (r, g, b, a) = ((int >> 24) & 0xFF, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

//
//  InputPanelView.swift
//  timeline
//
//  Created by Helina L. on 8/3/26.
//

import SwiftUI

struct InputPanelView: View {
    @Binding var name: String
    @State var beginYear: Int = 2026
    @State var endYear: Int = 2026
    
    var body: some View {
        Form {
            Section(header: Text("Timeline Details")) {
                TextField("Timeline Name", text: $name)
                
                Stepper("Starting Year: \(beginYear)", value: $beginYear, in: -20000...20000)
                
                Stepper("Ending Year: \(endYear)", value: $endYear, in: -20000...20000)
            }
        }
    }
}

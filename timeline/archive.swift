//
//  archive.swift
//  timeline
//
//  Created by Helina L. on 8/6/26.
//

//struct NodeCardView: View {
//    let node: Event
//    @Binding var cardSize: CGSize
//    
//    private let minWidth: CGFloat = 180
//    private let minHeight: CGFloat = 90
//    
//    // Store drag offset while gesture is active
//    @GestureState private var dragOffset: CGSize = .zero
//    
//    var body: some View {
//        VStack(alignment: .leading, spacing: 8) {
//            Text(node.title)
//                .font(.title2)
//                .bold()
//            
//            Text(formattedDate)
//                .font(.body)
//            
//            Text(node.details)
//                .font(.body)
//        }
//        .padding(16)
//        .frame(width: cardSize.width, height: cardSize.height, alignment: .topLeading)
//        .background(.secondary)
//        .cornerRadius(12)
//        .overlay(
//            RoundedRectangle(cornerRadius: 12)
//                .stroke(Color.accentColor, lineWidth: 2)
//        )
//        .overlay(alignment: .topLeading) { cornerHandle(xMultiplier: -1, yMultiplier: -1) }
//        .overlay(alignment: .topTrailing) { cornerHandle(xMultiplier: 1, yMultiplier: -1) }
//        .overlay(alignment: .bottomLeading) { cornerHandle(xMultiplier: -1, yMultiplier: 1) }
//        .overlay(alignment: .bottomTrailing) { cornerHandle(xMultiplier: 1, yMultiplier: 1) }
//    }
//    
//    private func cornerHandle(xMultiplier: CGFloat, yMultiplier: CGFloat) -> some View {
//        Color.clear
//            .frame(width: 24, height: 24)
//            .contentShape(Rectangle())
//            .gesture(
//                DragGesture()
//                    .updating($dragOffset) { value, state, _ in
//                        state = value.translation
//                    }
//                    .onEnded { value in
//                        let deltaW = value.translation.width * xMultiplier
//                        let deltaH = value.translation.height * yMultiplier
//                        
//                        // Finalize size update on drop
//                        cardSize = CGSize(
//                            width: max(minWidth, cardSize.width + deltaW),
//                            height: max(minHeight, cardSize.height + deltaH)
//                        )
//                    }
//            )
//    }
//
//    private var formattedDate: String {
//        "\(node.year) / \(node.month.map(String.init) ?? "MM") / \(node.day.map(String.init) ?? "DD")"
//    }
//}

//.onTapGesture(count: 2) {
//    let oldOffset = node.xOffset
//    guard oldOffset != 0 else { return }
//    
//    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
//        node.xOffset = 0
//    }
//    
//    undoManager?.registerUndo(withTarget: document) { _ in
//        node.xOffset = oldOffset
//    }
//    undoManager?.setActionName("Reset Node Position")
//}

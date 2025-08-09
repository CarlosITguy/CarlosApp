//
//  ScrollUtilities.swift
//  CarlosV - Shared UI Components
//
//  Created by Carlos Valderrama on 3/1/25.
//

import SwiftUI

// MARK: - Scroll Position Tracking

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value += nextValue()
    }
}

// MARK: - Scroll Utilities Extension

extension View {
    /// Tracks scroll offset using GeometryReader and PreferenceKey
    func trackScrollOffset(coordinateSpace: String = "scroll") -> some View {
        self.background(
            GeometryReader { geometry in
                Color.clear
                    .preference(key: ScrollOffsetPreferenceKey.self, 
                               value: geometry.frame(in: .named(coordinateSpace)).minY)
            }
            .frame(height: 0)
        )
    }
}

#Preview {
    ScrollView {
        VStack {
            ForEach(0..<20, id: \.self) { index in
                Text("Item \(index)")
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .background(.blue.opacity(0.2))
                    .cornerRadius(8)
            }
        }
        .padding()
        .trackScrollOffset()
    }
    .coordinateSpace(name: "scroll")
    .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
        print("Scroll offset: \(value)")
    }
}
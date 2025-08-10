//
//  ModernButtonStyle.swift
//  CarlosV - Shared UI Components
//
//  Created by Carlos Valderrama on 3/1/25.
//

import SwiftUI

struct ModernButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .fontWeight(.semibold)
            .foregroundStyle(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(.red.gradient, in: Capsule())
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.2), value: configuration.isPressed)
    }
}

#Preview {
    Button("Sample Button") {
        // Preview action
    }
    .buttonStyle(ModernButtonStyle())
}
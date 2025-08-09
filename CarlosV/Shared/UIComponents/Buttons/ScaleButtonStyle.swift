//
//  ScaleButtonStyle.swift
//  CarlosV - Shared UI Components
//
//  Created by Carlos Valderrama on 3/1/25.
//

import SwiftUI

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.85 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

#Preview {
    Button("Scale Button") {
        // Preview action
    }
    .buttonStyle(ScaleButtonStyle())
    .padding()
    .background(.blue)
    .foregroundStyle(.white)
    .clipShape(RoundedRectangle(cornerRadius: 8))
}
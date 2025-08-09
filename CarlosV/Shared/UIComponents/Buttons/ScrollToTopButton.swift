//
//  ScrollToTopButton.swift
//  CarlosV - Shared UI Components
//
//  Created by Carlos Valderrama on 3/1/25.
//

import SwiftUI

struct ScrollToTopButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "arrow.up")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .frame(width: 50, height: 50)
                .background(
                    Circle()
                        .fill(.red.gradient)
                        .shadow(color: .red.opacity(0.3), radius: 8, x: 0, y: 4)
                )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

#Preview {
    ScrollToTopButton {
        print("Scroll to top tapped")
    }
    .padding()
}
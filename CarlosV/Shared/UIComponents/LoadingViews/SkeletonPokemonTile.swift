//
//  SkeletonPokemonTile.swift
//  CarlosV - Shared UI Components
//
//  Created by Carlos Valderrama on 3/1/25.
//

import SwiftUI

struct SkeletonPokemonTile: View {
    @State private var isAnimating = false
    @State private var shimmerOffset: CGFloat = -200
    
    var body: some View {
        VStack(spacing: 12) {
            // Pokemon image skeleton with shimmer
            Circle()
                .fill(.gray.opacity(0.15))
                .frame(width: 120, height: 120)
                .overlay(
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    .clear, 
                                    .white.opacity(0.8), 
                                    .clear
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .offset(x: shimmerOffset)
                        .clipShape(Circle())
                )
                .background(
                    Circle()
                        .fill(.gray.opacity(0.1))
                        .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
                )
            
            // Pokemon info skeleton
            VStack(spacing: 6) {
                // Name skeleton
                Rectangle()
                    .fill(.gray.opacity(0.15))
                    .frame(width: CGFloat.random(in: 60...100), height: 16)
                    .cornerRadius(8)
                    .overlay(
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [.clear, .white.opacity(0.6), .clear],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .offset(x: shimmerOffset)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    )
                
                HStack(spacing: 8) {
                    // Order skeleton
                    Rectangle()
                        .fill(.gray.opacity(0.1))
                        .frame(width: 35, height: 12)
                        .cornerRadius(6)
                    
                    // Type badge skeleton
                    Rectangle()
                        .fill(.gray.opacity(0.1))
                        .frame(width: 45, height: 14)
                        .cornerRadius(7)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.ultraThinMaterial.opacity(0.5))
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(.gray.opacity(0.1), lineWidth: 1)
                )
        )
        .onAppear {
            startShimmerAnimation()
        }
    }
    
    private func startShimmerAnimation() {
        withAnimation(
            .linear(duration: 2.0)
            .repeatForever(autoreverses: false)
        ) {
            shimmerOffset = 200
        }
    }
}

#Preview {
    LazyVGrid(columns: [
        GridItem(.flexible()),
        GridItem(.flexible())
    ], spacing: 16) {
        ForEach(0..<4, id: \.self) { _ in
            SkeletonPokemonTile()
        }
    }
    .padding()
}
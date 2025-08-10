//
//  HorizontalMovesView.swift
//  CarlosV - Horizontal Scrolling Moves Component
//
//  Created by Carlos Valderrama on 3/1/25.
//

import SwiftUI

struct HorizontalMovesView: View {
    let moves: [String]
    let pokemonType: PokemonType
    let showContent: Bool
    
    private var movesPerRow: Int { 3 }
    
    private var moveRows: [[String]] {
        var rows: [[String]] = Array(repeating: [], count: movesPerRow)
        
        for (index, move) in moves.enumerated() {
            let rowIndex = index % movesPerRow
            rows[rowIndex].append(move)
        }
        
        return rows
    }
    
    var body: some View {
        LazyVStack(spacing: 12) {
            ForEach(Array(moveRows.enumerated()), id: \.offset) { rowIndex, rowMoves in
                if !rowMoves.isEmpty {
                    moveRow(moves: rowMoves, rowIndex: rowIndex)
                }
            }
        }
        .frame(height: CGFloat(movesPerRow * 50 + (movesPerRow - 1) * 12)) // Fixed height for smooth animation
    }
    
    private func moveRow(moves: [String], rowIndex: Int) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 12) {
                ForEach(Array(moves.enumerated()), id: \.offset) { moveIndex, move in
                    EnhancedMovePill(
                        moveName: move,
                        pokemonType: pokemonType,
                        globalIndex: rowIndex * moves.count + moveIndex,
                        showContent: showContent
                    )
                }
                
                // Add some trailing padding for the last row
                if rowIndex == moveRows.count - 1 {
                    Color.clear
                        .frame(width: 20)
                }
            }
            .padding(.horizontal, 4)
        }
        .scrollTargetBehavior(.viewAligned)
    }
}

struct EnhancedMovePill: View {
    let moveName: String
    let pokemonType: PokemonType
    let globalIndex: Int
    let showContent: Bool
    @State private var hasAppeared = false
    
    private var formattedName: String {
        moveName.replacingOccurrences(of: "-", with: " ").capitalized
    }
    
    var body: some View {
        Text(formattedName)
            .font(.caption)
            .fontWeight(.semibold)
            .lineLimit(1)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: pokemonType.gradientColors + [pokemonType.color.opacity(0.6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(
                        color: pokemonType.color.opacity(0.3),
                        radius: hasAppeared ? 4 : 0,
                        x: 0,
                        y: 2
                    )
            )
            .foregroundStyle(.white)
            .scaleEffect(hasAppeared ? 1.0 : 0.8)
            .opacity(hasAppeared ? 1.0 : 0.0)
            .scrollTransition(.animated.threshold(.visible(0.9))) { content, phase in
                content
                    .scaleEffect(phase.isIdentity ? 1.0 : 0.95)
                    .opacity(phase.isIdentity ? 1.0 : 0.8)
                    .rotation3DEffect(
                        .degrees(phase.value * 8),
                        axis: (x: 0, y: 1, z: 0)
                    )
                    .blur(radius: phase.isIdentity ? 0 : 0.5)
            }
            .onAppear {
                if showContent {
                    let delay = Double(globalIndex) * 0.05 // Stagger animation
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(delay)) {
                        hasAppeared = true
                    }
                }
            }
            .onChange(of: showContent) { newValue in
                if newValue && !hasAppeared {
                    let delay = Double(globalIndex) * 0.05
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(delay)) {
                        hasAppeared = true
                    }
                }
            }
    }
}

#Preview {
    let sampleMoves = [
        "thunderbolt", "quick-attack", "thunder-wave", "agility", "double-team",
        "thunder", "substitute", "spark", "endure", "charm", "swift",
        "fake-out", "wish", "facade", "helping-hand", "volt-tackle",
        "magnet-rise", "discharge", "charge-beam", "electro-ball"
    ]
    
    return VStack(spacing: 20) {
        HorizontalMovesView(
            moves: sampleMoves,
            pokemonType: .electric,
            showContent: true
        )
    }
    .padding()
    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    .padding()
}
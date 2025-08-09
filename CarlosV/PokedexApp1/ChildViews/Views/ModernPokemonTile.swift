//
//  ModernPokemonTile.swift
//  CarlosV - Pokemon Tile Component
//
//  Created by Carlos Valderrama on 3/1/25.
//

import SwiftUI

struct ModernPokemonTile: View {
    let pokemon: PokemonDetails
    let heroNamespace: Namespace.ID
    let index: Int
    @State private var isPressed = false
    @State private var hasAppeared = false
    
    private var pokemonType: PokemonType {
        PokemonColorUtility.getPrimaryType(for: pokemon.name)
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // Pokemon Image with type-colored background
            AsyncImage(url: URL(string: pokemon.sprites.front_default ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .matchedGeometryEffect(
                        id: "pokemon-\(pokemon.name)",
                        in: heroNamespace
                    )
            } placeholder: {
                ProgressView()
                    .tint(pokemonType.color)
                    .frame(width: 100, height: 100)
            }
            .frame(width: 120, height: 120)
            .background(
                Circle()
                    .fill(pokemonType.lightColor)
                    .overlay(
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: pokemonType.gradientColors,
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 3
                            )
                    )
                    .shadow(color: pokemonType.color.opacity(0.3), radius: 8, x: 0, y: 4)
            )
            
            // Pokemon Info with type indicator
            VStack(spacing: 6) {
                HStack(spacing: 6) {
                    Text(pokemon.name.capitalized)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .lineLimit(1)
                    
                    // Type indicator dot
                    Circle()
                        .fill(pokemonType.color)
                        .frame(width: 8, height: 8)
                        .shadow(color: pokemonType.color.opacity(0.5), radius: 2)
                }
                
                HStack(spacing: 8) {
                    Text("#\(String(format: "%03d", pokemon.order))")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)
                    
                    // Type badge
                    Text(pokemonType.rawValue.capitalized)
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(pokemonType.color.gradient, in: Capsule())
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            pokemonType.lightColor.opacity(0.6),
                            pokemonType.lightColor.opacity(0.1),
                            Color(.systemBackground)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(
                    color: pokemonType.color.opacity(isPressed ? 0.3 : 0.15),
                    radius: isPressed ? 12 : 8,
                    x: 0,
                    y: isPressed ? 6 : 4
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [pokemonType.color.opacity(0.3), .clear],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        .opacity(hasAppeared ? 1 : 0)
        .scaleEffect(hasAppeared ? 1 : 0.8)
        .onAppear {
            let delay = Double(index % 6) * 0.1 // Stagger animation
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(delay)) {
                hasAppeared = true
            }
        }
    }
}

#Preview {
    @Namespace var heroNamespace
    
    return LazyVGrid(columns: [
        GridItem(.flexible()),
        GridItem(.flexible())
    ], spacing: 16) {
        ForEach(0..<4, id: \.self) { index in
            ModernPokemonTile(
                pokemon: PokemonDetails(
                    name: "pikachu",
                    order: 25,
                    moves: [],
                    sprites: Sprites(
                        back_default: nil,
                        back_female: nil,
                        back_shiny: nil,
                        back_shiny_female: nil,
                        front_default: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/25.png",
                        front_female: nil,
                        front_shiny: nil,
                        front_shiny_female: nil
                    )
                ),
                heroNamespace: heroNamespace,
                index: index
            )
        }
    }
    .padding()
}
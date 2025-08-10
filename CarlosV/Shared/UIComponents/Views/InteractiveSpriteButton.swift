//
//  InteractiveSpriteButton.swift
//  CarlosV - Interactive Sprite Selection Component
//
//  Created by Carlos Valderrama on 3/1/25.
//

import SwiftUI

struct InteractiveSpriteButton: View {
    let sprite: (name: String, url: String)
    let isSelected: Bool
    let pokemonType: PokemonType
    let heroNamespace: Namespace.ID
    let action: () -> Void
    
    var body: some View {
        VStack(spacing: 6) {
            AsyncImage(url: URL(string: sprite.url)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .matchedGeometryEffect(
                        id: "sprite-\(sprite.url)",
                        in: heroNamespace
                    )
            } placeholder: {
                ProgressView()
                    .frame(width: 40, height: 40)
                    .tint(pokemonType.color)
            }
            .frame(width: 50, height: 50)
            .background(
                Circle()
                    .fill(isSelected ? pokemonType.lightColor : Color(.systemGray6))
                    .overlay(
                        Circle()
                            .stroke(
                                isSelected ? pokemonType.color : Color.clear,
                                lineWidth: isSelected ? 3 : 0
                            )
                    )
                    .shadow(
                        color: isSelected ? pokemonType.color.opacity(0.3) : .clear,
                        radius: isSelected ? 8 : 0,
                        x: 0,
                        y: 2
                    )
            )
            .scaleEffect(isSelected ? 1.1 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
            
            Text(sprite.name)
                .font(.caption2)
                .fontWeight(isSelected ? .semibold : .medium)
                .foregroundStyle(isSelected ? pokemonType.color : .secondary)
                .lineLimit(1)
                .animation(.easeInOut(duration: 0.2), value: isSelected)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            action()
        }
    }
}

#Preview {
    @Namespace var heroNamespace
    
    return HStack(spacing: 16) {
        InteractiveSpriteButton(
            sprite: ("Front", "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/25.png"),
            isSelected: true,
            pokemonType: .electric,
            heroNamespace: heroNamespace
        ) {
            print("Front sprite selected")
        }
        
        InteractiveSpriteButton(
            sprite: ("Back", "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/back/25.png"),
            isSelected: false,
            pokemonType: .electric,
            heroNamespace: heroNamespace
        ) {
            print("Back sprite selected")
        }
    }
    .padding()
}
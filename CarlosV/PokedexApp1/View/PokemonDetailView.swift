//
//  PokemonDetailView.swift
//  CarlosV - Pokemon Detail Screen
//
//  Created by Carlos Valderrama on 3/1/25.
//

import SwiftUI

struct PokemonDetailView: View {
    let pokemon: PokemonDetails
    let heroNamespace: Namespace.ID
    @Environment(\.dismiss) private var dismiss
    @State private var showContent = false
    @State private var selectedSpriteURL: String
    @Namespace private var spriteHeroAnimation
    
    init(pokemon: PokemonDetails, heroNamespace: Namespace.ID) {
        self.pokemon = pokemon
        self.heroNamespace = heroNamespace
        self._selectedSpriteURL = State(initialValue: pokemon.sprites.front_default ?? "")
    }
    
    private var pokemonType: PokemonType {
        PokemonColorUtility.getPrimaryType(for: pokemon.name)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 0) {
                    // Hero Header
                    heroHeader
                    
                    // Content sections
                    if showContent {
                        contentSections
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        HapticFeedback.impact(.light)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6).delay(0.3)) {
                showContent = true
            }
        }
    }
    
    private var heroHeader: some View {
        VStack(spacing: 20) {
            // Pokemon Image with hero effect
            AsyncImage(url: URL(string: selectedSpriteURL)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .matchedGeometryEffect(
                        id: selectedSpriteURL.isEmpty ? "pokemon-\(pokemon.name)" : "sprite-\(selectedSpriteURL)",
                        in: selectedSpriteURL.isEmpty ? heroNamespace : spriteHeroAnimation
                    )
            } placeholder: {
                ProgressView()
                    .frame(width: 200, height: 200)
            }
            .frame(width: 200, height: 200)
            .background(
                Circle()
                    .fill(pokemonType.lightColor)
                    .overlay(
                        Circle()
                            .stroke(pokemonType.color.opacity(0.3), lineWidth: 4)
                    )
                    .shadow(color: pokemonType.color.opacity(0.3), radius: 20, x: 0, y: 10)
            )
            
            // Interactive Sprite Gallery
            if !availableSprites.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(availableSprites, id: \.name) { sprite in
                            InteractiveSpriteButton(
                                sprite: sprite,
                                isSelected: selectedSpriteURL == sprite.url,
                                pokemonType: pokemonType,
                                heroNamespace: spriteHeroAnimation
                            ) {
                                HapticFeedback.impact(.light)
                                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                    selectedSpriteURL = sprite.url
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            
            // Pokemon basic info
            VStack(spacing: 8) {
                Text(pokemon.name.capitalized)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("#\(String(format: "%03d", pokemon.order))")
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.top, 40)
        .padding(.bottom, 30)
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(
                colors: [pokemonType.lightColor.opacity(0.4), .clear],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
    
    private var contentSections: some View {
        LazyVStack(spacing: 24) {
            // Basic Stats Section
            basicStatsSection
            
            // Moves Section
            movesSection
            
            // Additional Info
            additionalInfoSection
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 40)
    }
    
    private var basicStatsSection: some View {
        ModernCardView(title: "Basic Information", icon: "info.circle.fill") {
            VStack(spacing: 16) {
                StatRow(label: "Order", value: "#\(pokemon.order)")
                
                if !pokemon.moves.isEmpty {
                    StatRow(label: "Known Moves", value: "\(pokemon.moves.count)")
                }
                
                // Sprite availability
                let spriteCount = [
                    pokemon.sprites.front_default,
                    pokemon.sprites.back_default,
                    pokemon.sprites.front_shiny,
                    pokemon.sprites.back_shiny,
                    pokemon.sprites.front_female,
                    pokemon.sprites.back_female
                ].compactMap { $0 }.count
                
                if spriteCount > 1 {
                    StatRow(label: "Available Sprites", value: "\(spriteCount)")
                }
            }
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
    
    private var movesSection: some View {
        ModernCardView(
            title: "Moves", 
            icon: "bolt.fill",
            subtitle: pokemon.moves.isEmpty ? "No moves available" : "\(pokemon.moves.count) moves"
        ) {
            if pokemon.moves.isEmpty {
                Text("No moves data available")
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 20)
            } else {
                HorizontalMovesView(
                    moves: pokemon.moves.map { $0.move.name },
                    pokemonType: pokemonType,
                    showContent: showContent
                )
            }
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
        .animation(.easeOut(duration: 0.5).delay(0.1), value: showContent)
    }
    
    private var additionalInfoSection: some View {
        EmptyView()
    }
    
    private var availableSprites: [(name: String, url: String)] {
        var sprites: [(name: String, url: String)] = []
        
        if let url = pokemon.sprites.front_default {
            sprites.append(("Front", url))
        }
        if let url = pokemon.sprites.back_default {
            sprites.append(("Back", url))
        }
        if let url = pokemon.sprites.front_shiny {
            sprites.append(("Shiny", url))
        }
        if let url = pokemon.sprites.back_shiny {
            sprites.append(("Shiny Back", url))
        }
        if let url = pokemon.sprites.front_female {
            sprites.append(("Female", url))
        }
        if let url = pokemon.sprites.back_female {
            sprites.append(("Female Back", url))
        }
        
        return sprites
    }
}

// MARK: - Supporting Views

struct ModernCardView<Content: View>: View {
    let title: String
    let icon: String
    var subtitle: String? = nil
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Card header
            HStack {
                Label(title, systemImage: icon)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                
                Spacer()
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            // Card content
            content()
        }
        .padding(20)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
    }
}

struct StatRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(.primary)
        }
        .padding(.vertical, 4)
    }
}


#Preview {
    @Namespace var heroNamespace
    
    return PokemonDetailView(
        pokemon: PokemonDetails(
            name: "pikachu",
            order: 25,
            moves: [
                MoveWrapper(move: Move(name: "thunderbolt", url: "")),
                MoveWrapper(move: Move(name: "quick-attack", url: "")),
                MoveWrapper(move: Move(name: "thunder-wave", url: "")),
                MoveWrapper(move: Move(name: "agility", url: "")),
                MoveWrapper(move: Move(name: "double-team", url: ""))
            ],
            sprites: Sprites(
                back_default: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/back/25.png",
                back_female: nil,
                back_shiny: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/back/shiny/25.png",
                back_shiny_female: nil,
                front_default: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/25.png",
                front_female: nil,
                front_shiny: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/shiny/25.png",
                front_shiny_female: nil
            )
        ),
        heroNamespace: heroNamespace
    )
}
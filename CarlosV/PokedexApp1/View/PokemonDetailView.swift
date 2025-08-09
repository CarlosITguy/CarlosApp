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
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                    ForEach(Array(pokemon.moves.prefix(10).enumerated()), id: \.offset) { index, moveWrapper in
                        MovePill(moveName: moveWrapper.move.name, pokemonType: pokemonType)
                    }
                    
                    if pokemon.moves.count > 10 {
                        Text("+ \(pokemon.moves.count - 10) more")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(.ultraThinMaterial, in: Capsule())
                    }
                }
            }
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
        .animation(.easeOut(duration: 0.5).delay(0.1), value: showContent)
    }
    
    private var additionalInfoSection: some View {
        ModernCardView(title: "Sprites Gallery", icon: "photo.stack.fill") {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(availableSprites, id: \.name) { sprite in
                        SpritePreview(
                            url: sprite.url,
                            name: sprite.name
                        )
                    }
                }
                .padding(.horizontal, 4)
            }
            .frame(height: 120)
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
        .animation(.easeOut(duration: 0.5).delay(0.2), value: showContent)
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

struct MovePill: View {
    let moveName: String
    let pokemonType: PokemonType
    
    init(moveName: String, pokemonType: PokemonType = .normal) {
        self.moveName = moveName
        self.pokemonType = pokemonType
    }
    
    var body: some View {
        Text(moveName.replacingOccurrences(of: "-", with: " ").capitalized)
            .font(.caption)
            .fontWeight(.medium)
            .lineLimit(1)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                LinearGradient(
                    colors: pokemonType.gradientColors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                in: Capsule()
            )
            .foregroundStyle(.white)
    }
}

struct SpritePreview: View {
    let url: String
    let name: String
    
    var body: some View {
        VStack(spacing: 8) {
            AsyncImage(url: URL(string: url)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } placeholder: {
                ProgressView()
                    .frame(width: 60, height: 60)
            }
            .frame(width: 80, height: 80)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
            
            Text(name)
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
    }
}

#Preview {
    PokemonDetailView(
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
        heroNamespace: Namespace().wrappedValue
    )
}
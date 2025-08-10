//
//  PokemonTypeColors.swift
//  CarlosV - Pokemon Type Color System
//
//  Created by Carlos Valderrama on 3/1/25.
//

import SwiftUI

// MARK: - Pokemon Type Enum

enum PokemonType: String, CaseIterable {
    case normal, fire, water, electric, grass, ice, fighting, poison
    case ground, flying, psychic, bug, rock, ghost, dragon, dark
    case steel, fairy
    
    var color: Color {
        switch self {
        case .normal: return Color(red: 0.66, green: 0.66, blue: 0.47)
        case .fire: return Color(red: 0.93, green: 0.51, blue: 0.19)
        case .water: return Color(red: 0.39, green: 0.56, blue: 0.93)
        case .electric: return Color(red: 0.98, green: 0.84, blue: 0.17)
        case .grass: return Color(red: 0.48, green: 0.78, blue: 0.30)
        case .ice: return Color(red: 0.60, green: 0.85, blue: 0.85)
        case .fighting: return Color(red: 0.75, green: 0.18, blue: 0.16)
        case .poison: return Color(red: 0.64, green: 0.26, blue: 0.64)
        case .ground: return Color(red: 0.90, green: 0.75, blue: 0.40)
        case .flying: return Color(red: 0.66, green: 0.56, blue: 0.95)
        case .psychic: return Color(red: 0.98, green: 0.33, blue: 0.45)
        case .bug: return Color(red: 0.65, green: 0.71, blue: 0.16)
        case .rock: return Color(red: 0.71, green: 0.64, blue: 0.26)
        case .ghost: return Color(red: 0.44, green: 0.35, blue: 0.60)
        case .dragon: return Color(red: 0.44, green: 0.22, blue: 0.98)
        case .dark: return Color(red: 0.44, green: 0.35, blue: 0.26)
        case .steel: return Color(red: 0.71, green: 0.71, blue: 0.80)
        case .fairy: return Color(red: 0.95, green: 0.68, blue: 0.95)
        }
    }
    
    var lightColor: Color {
        color.opacity(0.3)
    }
    
    var gradientColors: [Color] {
        [color.opacity(0.8), color.opacity(0.4)]
    }
}

// MARK: - Pokemon Color Utility

struct PokemonColorUtility {
    
    /// Determines Pokemon type based on name patterns and well-known Pokemon
    /// This is a fallback method when type data isn't available from API
    static func getPrimaryType(for pokemonName: String) -> PokemonType {
        let name = pokemonName.lowercased()
        
        // Electric Pokemon patterns
        if name.contains("pika") || name.contains("volt") || name.contains("thunder") ||
           name.contains("electric") || name.contains("zapdos") {
            return .electric
        }
        
        // Fire Pokemon patterns
        if name.contains("char") || name.contains("fire") || name.contains("flame") ||
           name.contains("magma") || name.contains("moltres") || name.contains("cinder") {
            return .fire
        }
        
        // Water Pokemon patterns
        if name.contains("squirt") || name.contains("water") || name.contains("sea") ||
           name.contains("ocean") || name.contains("surf") || name.contains("bubble") {
            return .water
        }
        
        // Grass Pokemon patterns
        if name.contains("bulb") || name.contains("ivy") || name.contains("leaf") ||
           name.contains("grass") || name.contains("seed") || name.contains("flower") {
            return .grass
        }
        
        // Dragon Pokemon patterns
        if name.contains("dragon") || name.contains("draco") || name.contains("dragon") {
            return .dragon
        }
        
        // Psychic Pokemon patterns
        if name.contains("abra") || name.contains("psychic") || name.contains("alakazam") ||
           name.contains("mewtwo") || name.contains("mew") {
            return .psychic
        }
        
        // Ghost Pokemon patterns
        if name.contains("ghost") || name.contains("gastly") || name.contains("gengar") ||
           name.contains("haunter") || name.contains("spirit") {
            return .ghost
        }
        
        // Fighting Pokemon patterns
        if name.contains("machop") || name.contains("machamp") || name.contains("fight") ||
           name.contains("punch") || name.contains("kick") {
            return .fighting
        }
        
        // Poison Pokemon patterns
        if name.contains("poison") || name.contains("toxic") || name.contains("nido") ||
           name.contains("weezing") || name.contains("venom") {
            return .poison
        }
        
        // Rock Pokemon patterns
        if name.contains("rock") || name.contains("stone") || name.contains("geodude") ||
           name.contains("onix") || name.contains("graveler") {
            return .rock
        }
        
        // Flying Pokemon patterns
        if name.contains("bird") || name.contains("wing") || name.contains("fly") ||
           name.contains("aerial") || name.contains("pidgey") {
            return .flying
        }
        
        // Steel Pokemon patterns
        if name.contains("steel") || name.contains("metal") || name.contains("iron") ||
           name.contains("magnet") {
            return .steel
        }
        
        // Ice Pokemon patterns
        if name.contains("ice") || name.contains("freeze") || name.contains("snow") ||
           name.contains("frost") || name.contains("articuno") {
            return .ice
        }
        
        // Bug Pokemon patterns
        if name.contains("bug") || name.contains("caterpie") || name.contains("weedle") ||
           name.contains("spider") || name.contains("bee") {
            return .bug
        }
        
        // Dark Pokemon patterns
        if name.contains("dark") || name.contains("evil") || name.contains("shadow") {
            return .dark
        }
        
        // Fairy Pokemon patterns
        if name.contains("fairy") || name.contains("pixie") || name.contains("clefairy") {
            return .fairy
        }
        
        // Ground Pokemon patterns
        if name.contains("ground") || name.contains("earth") || name.contains("sand") ||
           name.contains("dig") {
            return .ground
        }
        
        // Default to normal type
        return .normal
    }
    
    /// Gets a gradient background for Pokemon cards
    static func getCardGradient(for pokemonName: String) -> LinearGradient {
        let primaryType = getPrimaryType(for: pokemonName)
        return LinearGradient(
            colors: primaryType.gradientColors + [Color.clear],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    /// Gets accent color for Pokemon cards
    static func getAccentColor(for pokemonName: String) -> Color {
        getPrimaryType(for: pokemonName).color
    }
    
    /// Gets light background color for Pokemon cards
    static func getLightBackgroundColor(for pokemonName: String) -> Color {
        getPrimaryType(for: pokemonName).lightColor
    }
}

// MARK: - View Extensions

extension View {
    /// Applies Pokemon-themed styling based on the Pokemon's inferred type
    func pokemonTypeStyle(for pokemonName: String) -> some View {
        let type = PokemonColorUtility.getPrimaryType(for: pokemonName)
        return self
            .background(
                LinearGradient(
                    colors: [type.lightColor, type.lightColor.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(type.color.opacity(0.3), lineWidth: 1)
            )
    }
}
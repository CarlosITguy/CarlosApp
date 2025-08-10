//
//  TestData.swift
//  CarlosVTests - Shared Test Data
//
//  Created for testing both XCTest and Swift Testing approaches
//

import Foundation
@testable import CarlosV

/// Centralized test data for consistent testing across different frameworks
struct TestData {
    
    // MARK: - Sample Pokemon Data
    
    static let pikachuDetails = PokemonDetails(
        name: "pikachu",
        order: 25,
        moves: [
            MoveWrapper(move: Move(name: "thunderbolt", url: "https://pokeapi.co/api/v2/move/85/")),
            MoveWrapper(move: Move(name: "quick-attack", url: "https://pokeapi.co/api/v2/move/98/")),
            MoveWrapper(move: Move(name: "thunder-wave", url: "https://pokeapi.co/api/v2/move/86/")),
            MoveWrapper(move: Move(name: "agility", url: "https://pokeapi.co/api/v2/move/97/")),
            MoveWrapper(move: Move(name: "double-team", url: "https://pokeapi.co/api/v2/move/104/"))
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
    )
    
    static let charmanderDetails = PokemonDetails(
        name: "charmander",
        order: 4,
        moves: [
            MoveWrapper(move: Move(name: "ember", url: "https://pokeapi.co/api/v2/move/52/")),
            MoveWrapper(move: Move(name: "scratch", url: "https://pokeapi.co/api/v2/move/10/")),
            MoveWrapper(move: Move(name: "growl", url: "https://pokeapi.co/api/v2/move/45/"))
        ],
        sprites: Sprites(
            back_default: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/back/4.png",
            back_female: nil,
            back_shiny: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/back/shiny/4.png",
            back_shiny_female: nil,
            front_default: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/4.png",
            front_female: nil,
            front_shiny: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/shiny/4.png",
            front_shiny_female: nil
        )
    )
    
    static let squirtleDetails = PokemonDetails(
        name: "squirtle",
        order: 7,
        moves: [
            MoveWrapper(move: Move(name: "bubble", url: "https://pokeapi.co/api/v2/move/145/")),
            MoveWrapper(move: Move(name: "tackle", url: "https://pokeapi.co/api/v2/move/33/")),
            MoveWrapper(move: Move(name: "withdraw", url: "https://pokeapi.co/api/v2/move/110/"))
        ],
        sprites: Sprites(
            back_default: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/back/7.png",
            back_female: nil,
            back_shiny: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/back/shiny/7.png",
            back_shiny_female: nil,
            front_default: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/7.png",
            front_female: nil,
            front_shiny: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/shiny/7.png",
            front_shiny_female: nil
        )
    )
    
    // MARK: - Sample Pokemon List Data
    
    static let samplePokemonList = [pikachuDetails, charmanderDetails, squirtleDetails]
    
    static func samplePokemonDetails(for name: String) -> PokemonDetails? {
        switch name.lowercased() {
        case "pikachu":
            return pikachuDetails
        case "charmander":
            return charmanderDetails
        case "squirtle":
            return squirtleDetails
        default:
            // Return a generic Pokemon for unknown names
            return PokemonDetails(
                name: name,
                order: 1,
                moves: [MoveWrapper(move: Move(name: "tackle", url: ""))],
                sprites: Sprites(
                    back_default: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/back/1.png",
                    back_female: nil,
                    back_shiny: nil,
                    back_shiny_female: nil,
                    front_default: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/1.png",
                    front_female: nil,
                    front_shiny: nil,
                    front_shiny_female: nil
                )
            )
        }
    }
    
    // MARK: - Pokemon List Response Data
    
    static func samplePokemonListResponse(pageSize: Int = 10, offset: Int = 0) -> PokemonListRequest {
        let pokemonNames = ["pikachu", "charmander", "squirtle", "bulbasaur", "pidgey"]
        let results = pokemonNames.prefix(pageSize).map { name in
            Pokemon(name: name)
        }
        
        return PokemonListRequest(results: results)
    }
    
    static let emptyPokemonListResponse = PokemonListRequest(results: [])
    
    // MARK: - Error Scenarios
    
    static let networkErrorMessage = "Network request failed"
    static let parsingErrorMessage = "Failed to parse response"
    static let timeoutErrorMessage = "Request timed out"
    
    // MARK: - Helper Methods
    
    static func createMockPokemonList(count: Int) -> [PokemonDetails] {
        return (0..<count).map { index in
            PokemonDetails(
                name: "pokemon-\(index)",
                order: index + 1,
                moves: [MoveWrapper(move: Move(name: "tackle", url: ""))],
                sprites: Sprites(
                    back_default: nil,
                    back_female: nil,
                    back_shiny: nil,
                    back_shiny_female: nil,
                    front_default: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/\(index + 1).png",
                    front_female: nil,
                    front_shiny: nil,
                    front_shiny_female: nil
                )
            )
        }
    }
}
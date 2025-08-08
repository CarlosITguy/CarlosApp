//  Created by Carlos Valderrama on 2/15/25.

import Foundation

struct PokemonDetails: Decodable, Sendable {
    let name: String
    let order: Int
    let moves: [MoveWrapper]
    let sprites: Sprites
}

struct MoveWrapper: Decodable, Sendable {
    let move: Move
}

struct Move: Decodable, Sendable {
    let name: String
    let url: String
}

struct Sprites: Decodable, Sendable {
    let back_default: String?
    let back_female: String?
    let back_shiny: String?
    let back_shiny_female: String?
    let front_default: String?
    let front_female: String?
    let front_shiny: String?
    let front_shiny_female: String?
}

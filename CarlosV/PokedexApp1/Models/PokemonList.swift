//
//  PokemonList.swift
//  CarlosV
//
//  Created by Carlos Valderrama on 2/15/25.
//

import Foundation

struct PokemonListRequest: Decodable {
    var results: [Pokemon]
}

struct Pokemon: Decodable {
    let name: String
}

// Created by: Carlos Valderrama

import Foundation

struct PokemonTileViewModel {
  var pokemonDetails: PokemonDetails
  
  var name: String {
    pokemonDetails.name
  }
  
  var image: String? {
    pokemonDetails.sprites.front_default ??
    pokemonDetails.sprites.front_female ??
    pokemonDetails.sprites.front_shiny ??
    pokemonDetails.sprites.front_shiny_female ??
    nil
  }
}


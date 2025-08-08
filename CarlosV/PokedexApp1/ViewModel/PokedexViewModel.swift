//
//  PokemonViewModel.swift
//  CarlosV
//
//  Created by Carlos Valderrama on 2/14/25.
//

import Foundation

@MainActor
final class PokedexViewModel: ObservableObject {
    
    init(service: PokemonNetworkServiceProtocol = PokemonNetworkService ()) {
        self.service = service
    }
    
    let service: PokemonNetworkServiceProtocol
    private var pokemonOffset: Int = 0
    @Published private(set) var pokemonList: [PokemonDetails] = []
    private var isLoading = false
    var pageSize = 10
    
    func fetchPokemons() async  {
        guard !isLoading else { return }
        isLoading = true
        
        guard let pokemonListRequest = await service.fetchPokemonList(
            pageSize: pageSize,
            offset: pokemonOffset)
        else {
            isLoading = false
            return
        }
        
        for pokemon in pokemonListRequest.results {
            guard let pokemonDetails = await fetchPokemonDetails(for: pokemon.name) else { continue }
            self.pokemonList.append(pokemonDetails)
        }
        
        
        isLoading = false
        pokemonOffset += 10
    }
    
    func fetchPokemonDetails(for pokemon: String) async -> PokemonDetails?  {
        await service.fetchPokemonDetails(for: pokemon)
    }
    
}


//
//  PokemonNetworkService.swift
//  CarlosV - Pokédex App
//
//  Created by Carlos Valderrama on 2/14/25.
//

import Foundation

/// Protocol for Pokemon-specific network operations
/// Abstracts Pokemon API calls for better testability
protocol PokemonNetworkServiceProtocol: Sendable {
    func fetchPokemonList(pageSize: Int, offset: Int) async -> PokemonListRequest?
    func fetchPokemonDetails(for name: String) async -> PokemonDetails?
}

/// Pokemon-specific network service implementation
/// Uses the generic NetworkService for actual HTTP operations
struct PokemonNetworkService: PokemonNetworkServiceProtocol {
    
    init(networkService: NetworkServiceProtocol = NetworkService()) {
        self.networkService = networkService
    }
    
    private let networkService: NetworkServiceProtocol
    
    func fetchPokemonList(pageSize: Int, offset: Int = 20) async -> PokemonListRequest? {
        let endpoint = PokemonEndpoint.list(pageSize: pageSize, offset: offset)
        guard let url = PokemonAPI.init(path: endpoint.path, queryItems: endpoint.queryItems).url else {
            print(NetworkErrors.badUrl)
            return nil
        }
        return await networkService.fetch(url: url)
    }
    
    func fetchPokemonDetails(for name: String) async -> PokemonDetails? {
        let endpoint = PokemonEndpoint.details(name: name)
        
        guard let url = PokemonAPI(path: endpoint.path, queryItems: endpoint.queryItems).url else {
            print(NetworkErrors.badUrl)
            return nil
        }
        
        return await networkService.fetch(url: url)
    }
}
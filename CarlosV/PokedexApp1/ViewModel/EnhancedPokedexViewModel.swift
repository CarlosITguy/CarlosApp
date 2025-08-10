//
//  EnhancedPokedexViewModel.swift
//  CarlosV - Modern Pokédex ViewModel
//
//  Created by Carlos Valderrama on 3/1/25.
//

import Foundation
import SwiftUI

// MARK: - LoadingState Enum

enum LoadingState: Equatable {
    case idle
    case loading
    case loaded
    case error(String)
    
    var isLoading: Bool {
        self == .loading
    }
    
    var errorMessage: String? {
        if case .error(let message) = self {
            return message
        }
        return nil
    }
}

// MARK: - Enhanced ViewModel

@MainActor
final class EnhancedPokedexViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published private(set) var pokemonList: [PokemonDetails] = []
    @Published private(set) var loadingState: LoadingState = .idle
    
    // MARK: - Private Properties
    private let service: PokemonNetworkServiceProtocol
    private var pokemonOffset: Int = 0
    private let pageSize = 20
    private var isLoadingMore = false
    
    // MARK: - Initialization
    
    init(service: PokemonNetworkServiceProtocol = PokemonNetworkService()) {
        self.service = service
    }
    
    // MARK: - Public Methods
    
    /// Fetches the initial batch of Pokemon or loads more if already populated
    func fetchPokemons() async {
        // Prevent multiple simultaneous loads and avoid unnecessary loads
        guard !isLoadingMore && loadingState != .loading else { return }
        
        // Set loading state only for initial load
        if pokemonList.isEmpty {
            loadingState = .loading
        } else {
            isLoadingMore = true
        }
        
        do {
            let newPokemon = try await loadPokemonBatch()
            await updatePokemonList(with: newPokemon)
            loadingState = .loaded
        } catch {
            await handleError(error)
        }
        
        isLoadingMore = false
    }
    
    /// Refreshes the entire Pokemon list
    func refreshPokemons() async {
        // Prevent multiple simultaneous refreshes
        guard !isLoadingMore else { return }
        
        // Set loading state first
        loadingState = .loading
        
        // Reset pagination and clear list
        pokemonOffset = 0
        pokemonList.removeAll()
        
        // Directly load new data without calling fetchPokemons to avoid state conflicts
        do {
            let newPokemon = try await loadPokemonBatch()
            pokemonList = newPokemon.sorted { $0.order < $1.order }
            loadingState = .loaded
        } catch {
            await handleError(error)
        }
    }
    
    // MARK: - Private Methods
    
    private func loadPokemonBatch() async throws -> [PokemonDetails] {
        // Fetch Pokemon list
        guard let pokemonListRequest = await service.fetchPokemonList(
            pageSize: pageSize,
            offset: pokemonOffset
        ) else {
            throw PokemonError.networkError("Failed to fetch Pokemon list")
        }
        
        // Fetch details for each Pokemon concurrently
        let pokemonDetails = await withTaskGroup(of: PokemonDetails?.self) { group in
            var results: [PokemonDetails] = []
            
            for pokemon in pokemonListRequest.results {
                group.addTask {
                    await self.service.fetchPokemonDetails(for: pokemon.name)
                }
            }
            
            for await result in group {
                if let pokemonDetails = result {
                    results.append(pokemonDetails)
                }
            }
            
            return results
        }
        
        // Update offset for next batch
        pokemonOffset += pageSize
        
        return pokemonDetails
    }
    
    private func updatePokemonList(with newPokemon: [PokemonDetails]) async {
        // Sort by order to maintain consistent display
        let sortedNewPokemon = newPokemon.sorted { $0.order < $1.order }
        
        // Add to existing list
        pokemonList.append(contentsOf: sortedNewPokemon)
        
        // Remove duplicates (just in case)
        pokemonList = Array(Set(pokemonList)).sorted { $0.order < $1.order }
    }
    
    private func handleError(_ error: Error) async {
        let errorMessage: String
        
        if let pokemonError = error as? PokemonError {
            errorMessage = pokemonError.localizedDescription
        } else if let urlError = error as? URLError {
            switch urlError.code {
            case .notConnectedToInternet:
                errorMessage = "No internet connection. Please check your network and try again."
            case .timedOut:
                errorMessage = "Request timed out. Please try again."
            case .cannotFindHost:
                errorMessage = "Cannot reach the Pokemon database. Please try again later."
            default:
                errorMessage = "Network error occurred. Please try again."
            }
        } else {
            errorMessage = "An unexpected error occurred. Please try again."
        }
        
        loadingState = .error(errorMessage)
        
        // Send haptic feedback for error
        HapticFeedback.notification(.error)
    }
}

// MARK: - Custom Errors

enum PokemonError: LocalizedError {
    case networkError(String)
    case decodingError(String)
    case unknownError
    
    var errorDescription: String? {
        switch self {
        case .networkError(let message):
            return "Network Error: \(message)"
        case .decodingError(let message):
            return "Data Error: \(message)"
        case .unknownError:
            return "An unknown error occurred"
        }
    }
}

// MARK: - Extensions

extension PokemonDetails: Hashable {
    static func == (lhs: PokemonDetails, rhs: PokemonDetails) -> Bool {
        lhs.name == rhs.name && lhs.order == rhs.order
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(order)
    }
}

extension PokemonDetails: Identifiable {
    var id: String { name }
}
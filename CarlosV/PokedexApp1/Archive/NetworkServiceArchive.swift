//
//  NetworkServiceArchive.swift
//  CarlosV - Interview Preparation Archive
//
//  Created by Carlos Valderrama on 2/15/25.
//  Archive of networking implementations for interview study
//
//  NOTE: This archive uses the new shared structure:
//  - NetworkService and NetworkServiceProtocol are now in Shared/Networking/
//  - NetworkErrors and HTTPMethod are in Shared/
//

import Foundation

// ARCHIVED: Alternative implementation of PokemonNetworkService
// This shows a direct approach without generic networking layer
// Good for demonstrating understanding of URLSession, error handling, and async/await

struct PokemonNetworkServiceAlternative {
    private let urlSession = URLSession.shared
    private let decoder = JSONDecoder()

    func fetchPokemonList(pageSize: Int, offset: Int = 20) async -> PokemonListRequest? {
        let endpoint = PokemonEndpoint.list(pageSize: pageSize, offset: offset)

        guard let url = PokemonAPI.init(path: endpoint.path, queryItems: endpoint.queryItems).url
        else { return nil }

        do {
            let (data, response) = try await urlSession.data(from: url)
            guard (response as? HTTPURLResponse)?.statusCode == 200 else {
                print(NetworkErrors.badResponse)
                return nil
            }
            return try decoder.decode(PokemonListRequest.self, from: data)
        } catch {
            print(NetworkErrors.decodingError)
            return nil
        }
    }

    func fetchPokemonDetails(for name: String) async -> PokemonDetails? {
        let endpoint = PokemonEndpoint.details(name: name)

        guard let url = PokemonAPI(path: endpoint.path, queryItems: endpoint.queryItems).url else {
            print(NetworkErrors.badUrl)
            return nil
        }

        do {
            let (data, response) = try await urlSession.data(from: url)

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print(NetworkErrors.badResponse)
                return nil
            }

            let pokemonDetails = try decoder.decode(PokemonDetails.self, from: data)
            return pokemonDetails
        } catch {
            print(NetworkErrors.decodingError)
            return nil
        }
    }
}

/*
Interview Discussion Points:

1. **Direct vs Generic Approach**: 
   - This archive shows direct URLSession usage
   - Main code uses generic NetworkService
   - Both approaches have merits for different scenarios

2. **Error Handling Patterns**:
   - Shows explicit status code checking
   - Demonstrates do-catch for async operations
   - Good example of nil-return error handling

3. **Swift Concurrency**:
   - async/await implementation
   - URLSession.data(from:) modern API usage

4. **Networking Architecture**:
   - Separation of concerns with endpoints
   - Decode pattern with JSONDecoder
   - URL construction and validation

5. **Trade-offs Discussion**:
   - Direct approach: More explicit, less abstraction
   - Generic approach: More reusable, better separation of concerns
*/
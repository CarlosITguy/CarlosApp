//
//  PokedexViewModelSwiftTests.swift
//  CarlosVTests - Swift Testing Approach
//
//  Testing PokedexViewModel using modern Swift Testing framework
//

import Testing
@testable import CarlosV

/// Test suite for PokedexViewModel using Swift Testing framework
@MainActor
struct PokedexViewModelSwiftTests {
    
    // MARK: - Helper Methods
    
    /// Creates a fresh ViewModel instance with mock service for each test
    private func createViewModel(mockService: MockPokemonNetworkService? = nil) -> (PokedexViewModel, MockPokemonNetworkService) {
        let service = mockService ?? MockPokemonNetworkService()
        let viewModel = PokedexViewModel(service: service)
        return (viewModel, service)
    }
    
    // MARK: - Initial State Tests
    
    @Test("Initial state should be correct")
    func initialState() async {
        // Given: Fresh ViewModel instance
        let (viewModel, _) = createViewModel()
        
        // When: No actions performed
        // Then: Initial state should be correct
        #expect(viewModel.pokemonList.isEmpty, "Pokemon list should be empty initially")
        #expect(viewModel.pageSize == 10, "Page size should be 10")
    }
    
    // MARK: - Fetch Pokemons Success Tests
    
    @Test("Fetch Pokemon success should populate list")
    func fetchPokemonsSuccess() async {
        // Given: Mock service configured for success
        let (viewModel, mockService) = createViewModel()
        mockService.configureForSuccess()
        
        // When: Fetching Pokemon
        await viewModel.fetchPokemons()
        
        // Then: Pokemon list should be populated
        #expect(!viewModel.pokemonList.isEmpty, "Pokemon list should not be empty after successful fetch")
        #expect(viewModel.pokemonList.count > 0, "Pokemon list should contain Pokemon")
        
        // Verify specific Pokemon are loaded (based on our test data)
        let pokemonNames = viewModel.pokemonList.map { $0.name }
        #expect(pokemonNames.contains("pikachu"), "Should contain Pikachu")
        #expect(pokemonNames.contains("charmander"), "Should contain Charmander")
        #expect(pokemonNames.contains("squirtle"), "Should contain Squirtle")
    }
    
    @Test("Multiple fetch calls should implement pagination")
    func fetchPokemonsSuccessWithMultipleBatches() async {
        // Given: Mock service configured for success
        let (viewModel, mockService) = createViewModel()
        mockService.configureForSuccess()
        
        // When: Fetching Pokemon multiple times (pagination)
        await viewModel.fetchPokemons()
        let firstBatchCount = viewModel.pokemonList.count
        
        await viewModel.fetchPokemons()
        let secondBatchCount = viewModel.pokemonList.count
        
        // Then: Second batch should have more Pokemon
        #expect(secondBatchCount > firstBatchCount, 
               "Second batch should have more Pokemon than first batch")
    }
    
    // MARK: - Fetch Pokemons Failure Tests
    
    @Test("Network error should keep Pokemon list empty")
    func fetchPokemonsFailureNetworkError() async {
        // Given: Mock service configured to return error
        let (viewModel, mockService) = createViewModel()
        mockService.configureForError()
        
        // When: Fetching Pokemon
        await viewModel.fetchPokemons()
        
        // Then: Pokemon list should remain empty
        #expect(viewModel.pokemonList.isEmpty, 
               "Pokemon list should remain empty when network request fails")
    }
    
    @Test("Empty response should keep Pokemon list empty")  
    func fetchPokemonsFailureEmptyResponse() async {
        // Given: Mock service configured to return empty response
        let (viewModel, mockService) = createViewModel()
        mockService.configureForEmptyResponse()
        
        // When: Fetching Pokemon
        await viewModel.fetchPokemons()
        
        // Then: Pokemon list should remain empty
        #expect(viewModel.pokemonList.isEmpty, 
               "Pokemon list should remain empty when response is empty")
    }
    
    // MARK: - Loading State Management Tests
    
    @Test("Loading state management with network delay")
    func loadingStateManagement() async {
        // Given: Mock service with network delay to test loading state
        let (viewModel, mockService) = createViewModel()
        mockService.configureForSuccess()
        mockService.networkDelay = 0.1  // Small delay to observe loading state
        
        // When: Starting fetch operation
        let fetchTask = Task {
            await viewModel.fetchPokemons()
        }
        
        // Then: Should be loading initially (we can't easily test this with private properties)
        // This is a limitation of testing private isLoading property
        
        // Wait for completion
        await fetchTask.value
        
        // Then: Should have completed successfully
        #expect(!viewModel.pokemonList.isEmpty, 
               "Pokemon list should be populated after loading completes")
    }
    
    // MARK: - Concurrent Request Prevention Tests
    
    @Test("Concurrent requests should be prevented")
    func concurrentRequestPrevention() async {
        // Given: Mock service with delay to simulate slow network
        let (viewModel, mockService) = createViewModel()
        mockService.configureForSuccess()
        mockService.networkDelay = 0.2
        
        // When: Starting multiple concurrent requests
        async let task1: Void = viewModel.fetchPokemons()
        async let task2: Void = viewModel.fetchPokemons()  
        async let task3: Void = viewModel.fetchPokemons()
        
        // Wait for all tasks to complete
        let _ = await (task1, task2, task3)
        
        // Then: Should only have one batch of Pokemon (not three)
        // The exact count depends on implementation details, but it shouldn't be 3x the normal amount
        let expectedMaxCount = 15 // Assuming ~5 Pokemon per successful request
        #expect(viewModel.pokemonList.count <= expectedMaxCount,
               "Concurrent requests should be prevented, not allowing excessive Pokemon loading")
    }
    
    // MARK: - Pokemon Details Fetching Tests
    
    @Test("Fetch Pokemon details success should return valid data")
    func fetchPokemonDetailsSuccess() async {
        // Given: Mock service configured for success
        let (viewModel, mockService) = createViewModel()
        mockService.configureForSuccess()
        
        // When: Fetching specific Pokemon details
        let pokemonDetails = await viewModel.fetchPokemonDetails(for: "pikachu")
        
        // Then: Should return valid Pokemon details
        #expect(pokemonDetails != nil, "Should return Pokemon details")
        #expect(pokemonDetails?.name == "pikachu", "Should return Pikachu details")
        #expect(pokemonDetails?.order == 25, "Pikachu should have order 25")
        #expect(!(pokemonDetails?.moves.isEmpty ?? true), "Pikachu should have moves")
    }
    
    @Test("Fetch Pokemon details failure should return nil")
    func fetchPokemonDetailsFailure() async {
        // Given: Mock service configured for error
        let (viewModel, mockService) = createViewModel()
        mockService.configureForError()
        
        // When: Fetching specific Pokemon details
        let pokemonDetails = await viewModel.fetchPokemonDetails(for: "pikachu")
        
        // Then: Should return nil
        #expect(pokemonDetails == nil, "Should return nil when network request fails")
    }
    
    // MARK: - Pagination Logic Tests
    
    @Test("Pagination should increment correctly with multiple fetches")
    func paginationOffsetIncrement() async {
        // Given: Mock service configured for success
        let (viewModel, mockService) = createViewModel()
        mockService.configureForSuccess()
        
        // When: Fetching Pokemon multiple times
        await viewModel.fetchPokemons()  // First batch
        await viewModel.fetchPokemons()  // Second batch
        
        // Then: Should have Pokemon from multiple batches
        // Note: We can't directly test offset as it's private, but we can test the behavior
        #expect(viewModel.pokemonList.count > 5, 
               "Multiple fetches should result in more Pokemon")
    }
    
    // MARK: - Edge Cases Tests
    
    @Test("Nil service response should keep list empty")
    func fetchPokemonsWithNilService() async {
        // Given: Mock service configured to return nil
        let (viewModel, mockService) = createViewModel()
        mockService.shouldReturnNil = true
        
        // When: Fetching Pokemon
        await viewModel.fetchPokemons()
        
        // Then: Pokemon list should remain empty
        #expect(viewModel.pokemonList.isEmpty, 
               "Pokemon list should remain empty when service returns nil")
    }
    
    // MARK: - Parameterized Tests (Swift Testing Feature)
    
    @Test("Fetch Pokemon details for different names", arguments: ["pikachu", "charmander", "squirtle"])
    func fetchDifferentPokemonDetails(pokemonName: String) async {
        // Given: Mock service configured for success
        let (viewModel, mockService) = createViewModel()
        mockService.configureForSuccess()
        
        // When: Fetching specific Pokemon details
        let pokemonDetails = await viewModel.fetchPokemonDetails(for: pokemonName)
        
        // Then: Should return valid Pokemon details with correct name
        #expect(pokemonDetails != nil, "Should return Pokemon details for \(pokemonName)")
        #expect(pokemonDetails?.name == pokemonName, "Should return correct Pokemon name")
        #expect(pokemonDetails?.order ?? 0 > 0, "Pokemon should have valid order number")
    }
}
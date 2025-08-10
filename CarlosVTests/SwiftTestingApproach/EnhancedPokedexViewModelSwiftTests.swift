//
//  EnhancedPokedexViewModelSwiftTests.swift
//  CarlosVTests - Swift Testing Approach
//
//  Testing EnhancedPokedexViewModel using modern Swift Testing framework
//

import Testing
@testable import CarlosV

/// Test suite for EnhancedPokedexViewModel using Swift Testing framework
@MainActor
struct EnhancedPokedexViewModelSwiftTests {
    
    // MARK: - Helper Methods
    
    /// Creates a fresh ViewModel instance with mock service for each test
    private func createViewModel(mockService: MockPokemonNetworkService? = nil) -> (EnhancedPokedexViewModel, MockPokemonNetworkService) {
        let service = mockService ?? MockPokemonNetworkService()
        let viewModel = EnhancedPokedexViewModel(service: service)
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
        #expect(viewModel.loadingState == LoadingState.idle, "Loading state should be idle initially")
    }
    
    // MARK: - LoadingState Enum Tests
    
    @Test("LoadingState properties should work correctly")
    func loadingStateProperties() async {
        // Test LoadingState.isLoading property
        #expect(!LoadingState.idle.isLoading, "idle should not be loading")
        #expect(LoadingState.loading.isLoading, "loading should be loading")
        #expect(!LoadingState.loaded.isLoading, "loaded should not be loading")
        #expect(!LoadingState.error("test").isLoading, "error should not be loading")
        
        // Test LoadingState.errorMessage property
        #expect(LoadingState.idle.errorMessage == nil, "idle should have no error message")
        #expect(LoadingState.loading.errorMessage == nil, "loading should have no error message")
        #expect(LoadingState.loaded.errorMessage == nil, "loaded should have no error message")
        #expect(LoadingState.error("test error").errorMessage == "test error", "error should return error message")
    }
    
    // MARK: - Fetch Pokemons Success Tests
    
    @Test("Initial fetch should populate Pokemon list")
    func fetchPokemonsSuccessInitialLoad() async {
        // Given: Mock service configured for success
        let (viewModel, mockService) = createViewModel()
        mockService.configureForSuccess()
        
        // When: Fetching Pokemon for the first time
        await viewModel.fetchPokemons()
        
        // Then: State should be correct
        #expect(viewModel.loadingState == LoadingState.loaded, "Loading state should be loaded")
        #expect(!viewModel.pokemonList.isEmpty, "Pokemon list should not be empty")
        #expect(viewModel.pokemonList.count > 0, "Pokemon list should contain Pokemon")
        
        // Verify Pokemon are sorted by order
        let orders = viewModel.pokemonList.map { $0.order }
        let sortedOrders = orders.sorted()
        #expect(orders == sortedOrders, "Pokemon should be sorted by order")
    }
    
    @Test("Load more should add additional Pokemon")
    func fetchPokemonsSuccessLoadMore() async {
        // Given: Mock service configured for success and initial data loaded
        let (viewModel, mockService) = createViewModel()
        mockService.configureForSuccess()
        await viewModel.fetchPokemons()  // Initial load
        let initialCount = viewModel.pokemonList.count
        
        // When: Loading more Pokemon
        await viewModel.fetchPokemons()
        
        // Then: Should have more Pokemon
        #expect(viewModel.loadingState == LoadingState.loaded, "Loading state should be loaded")
        #expect(viewModel.pokemonList.count > initialCount, "Should have more Pokemon after loading more")
    }
    
    // MARK: - Fetch Pokemons Error Tests
    
    @Test("Network error should set error state")
    func fetchPokemonsError() async {
        // Given: Mock service configured for error
        let (viewModel, mockService) = createViewModel()
        mockService.configureForError()
        
        // When: Fetching Pokemon
        await viewModel.fetchPokemons()
        
        // Then: Should be in error state
        if case .error(let message) = viewModel.loadingState {
            #expect(!message.isEmpty, "Error message should not be empty")
        } else {
            Issue.record("Loading state should be error")
        }
        
        #expect(viewModel.pokemonList.isEmpty, "Pokemon list should remain empty on error")
    }
    
    @Test("Error during load more should preserve existing data")
    func fetchPokemonsErrorWithExistingData() async {
        // Given: Mock service with existing data, then configured for error
        let (viewModel, mockService) = createViewModel()
        mockService.configureForSuccess()
        await viewModel.fetchPokemons()  // Load initial data
        let existingCount = viewModel.pokemonList.count
        
        mockService.configureForError()
        
        // When: Fetching more Pokemon fails
        await viewModel.fetchPokemons()
        
        // Then: Should be in error state but keep existing data
        if case .error = viewModel.loadingState {
            // Expected error state
        } else {
            Issue.record("Loading state should be error")
        }
        
        #expect(viewModel.pokemonList.count == existingCount, 
               "Should keep existing Pokemon when additional fetch fails")
    }
    
    // MARK: - Refresh Pokemons Tests
    
    @Test("Refresh should reload Pokemon list")
    func refreshPokemonsSuccess() async {
        // Given: Mock service with existing data
        let (viewModel, mockService) = createViewModel()
        mockService.configureForSuccess()
        await viewModel.fetchPokemons()  // Load initial data
        #expect(!viewModel.pokemonList.isEmpty, "Should have initial data")
        
        // When: Refreshing Pokemon list
        await viewModel.refreshPokemons()
        
        // Then: Should have refreshed data
        #expect(viewModel.loadingState == LoadingState.loaded, "Loading state should be loaded")
        #expect(!viewModel.pokemonList.isEmpty, "Pokemon list should not be empty after refresh")
        
        // Verify Pokemon are sorted by order
        let orders = viewModel.pokemonList.map { $0.order }
        let sortedOrders = orders.sorted()
        #expect(orders == sortedOrders, "Pokemon should be sorted by order after refresh")
    }
    
    @Test("Failed refresh should clear existing data")
    func refreshPokemonsError() async {
        // Given: Mock service with initial success, then error
        let (viewModel, mockService) = createViewModel()
        mockService.configureForSuccess()
        await viewModel.fetchPokemons()  // Load initial data
        #expect(!viewModel.pokemonList.isEmpty, "Should have initial data")
        
        mockService.configureForError()
        
        // When: Refreshing Pokemon list fails
        await viewModel.refreshPokemons()
        
        // Then: Should be in error state with empty list (refresh clears existing data)
        if case .error = viewModel.loadingState {
            // Expected error state
        } else {
            Issue.record("Loading state should be error")
        }
        
        #expect(viewModel.pokemonList.isEmpty, "Pokemon list should be empty after failed refresh")
    }
    
    // MARK: - Concurrent Request Prevention Tests
    
    @Test("Concurrent fetch requests should be prevented")
    func concurrentFetchPrevention() async {
        // Given: Mock service with delay
        let (viewModel, mockService) = createViewModel()
        mockService.configureForSuccess()
        mockService.networkDelay = 0.2
        
        // When: Starting multiple concurrent fetch requests
        async let task1: Void = viewModel.fetchPokemons()
        async let task2: Void = viewModel.fetchPokemons()
        async let task3: Void = viewModel.fetchPokemons()
        
        // Wait for all tasks to complete
        let _ = await (task1, task2, task3)
        
        // Then: Should not have excessive duplicates
        let expectedMaxCount = 15  // Conservative estimate
        #expect(viewModel.pokemonList.count <= expectedMaxCount,
               "Concurrent requests should be prevented")
    }
    
    @Test("Concurrent refresh requests should be prevented")
    func concurrentRefreshPrevention() async {
        // Given: Mock service with delay and initial data
        let (viewModel, mockService) = createViewModel()
        mockService.configureForSuccess()
        await viewModel.fetchPokemons()  // Initial data
        
        mockService.networkDelay = 0.2
        
        // When: Starting multiple concurrent refresh requests
        async let task1: Void = viewModel.refreshPokemons()
        async let task2: Void = viewModel.refreshPokemons()
        
        // Wait for all tasks to complete
        let _ = await (task1, task2)
        
        // Then: Should have reasonable amount of Pokemon (not duplicated)
        let expectedMaxCount = 10
        #expect(viewModel.pokemonList.count <= expectedMaxCount,
               "Concurrent refresh should be prevented")
        #expect(viewModel.loadingState == LoadingState.loaded, "Should end in loaded state")
    }
    
    // MARK: - Pokemon Deduplication Tests
    
    @Test("Pokemon deduplication should prevent duplicates")
    func pokemonDeduplication() async {
        // Given: Mock service configured for success
        let (viewModel, mockService) = createViewModel()
        mockService.configureForSuccess()
        
        // When: Fetching Pokemon multiple times
        await viewModel.fetchPokemons()
        await viewModel.fetchPokemons()
        await viewModel.fetchPokemons()
        
        // Then: Should not have duplicate Pokemon
        let pokemonNames = viewModel.pokemonList.map { $0.name }
        let uniqueNames = Set(pokemonNames)
        
        #expect(pokemonNames.count == uniqueNames.count, 
               "Should not have duplicate Pokemon names")
    }
    
    // MARK: - State Transition Tests
    
    @Test("State should transition correctly through fetch cycle")
    func stateTransitionSequence() async {
        // Given: Mock service configured for success
        let (viewModel, mockService) = createViewModel()
        mockService.configureForSuccess()
        
        // Initial state
        #expect(viewModel.loadingState == LoadingState.idle, "Should start in idle state")
        
        // When: Fetching Pokemon (we can't easily observe the loading state due to async nature)
        await viewModel.fetchPokemons()
        
        // Then: Should end in loaded state
        #expect(viewModel.loadingState == LoadingState.loaded, "Should end in loaded state")
    }
    
    // MARK: - Error Handling Tests
    
    @Test("Different error types should be handled correctly")
    func errorHandlingDifferentErrorTypes() async {
        let (viewModel, mockService) = createViewModel()
        
        // Test with network error
        mockService.shouldReturnError = true
        await viewModel.fetchPokemons()
        
        if case .error(let message) = viewModel.loadingState {
            #expect(!message.isEmpty, "Error message should not be empty")
        } else {
            Issue.record("Should be in error state")
        }
        
        // Reset for next test
        mockService.reset()
        mockService.shouldReturnNil = true
        
        // Test with nil response
        await viewModel.refreshPokemons()
        
        if case .error(let message) = viewModel.loadingState {
            #expect(!message.isEmpty, "Error message should not be empty for nil response")
        } else {
            Issue.record("Should be in error state for nil response")
        }
    }
    
    // MARK: - Edge Cases Tests
    
    @Test("Empty response should be handled gracefully")
    func emptyResponseHandling() async {
        // Given: Mock service configured for empty response
        let (viewModel, mockService) = createViewModel()
        mockService.configureForEmptyResponse()
        
        // When: Fetching Pokemon
        await viewModel.fetchPokemons()
        
        // Then: Should handle empty response gracefully
        #expect(viewModel.loadingState == LoadingState.loaded, 
               "Should be in loaded state even with empty response")
        #expect(viewModel.pokemonList.isEmpty, "Pokemon list should remain empty")
    }
    
    // MARK: - Parameterized Tests (Swift Testing Feature)
    
    @Test("LoadingState equality", arguments: [
        (LoadingState.idle, LoadingState.idle, true),
        (LoadingState.loading, LoadingState.loading, true),
        (LoadingState.loaded, LoadingState.loaded, true),
        (LoadingState.error("test"), LoadingState.error("test"), true),
        (LoadingState.idle, LoadingState.loading, false),
        (LoadingState.error("a"), LoadingState.error("b"), false)
    ])
    func loadingStateEquality(first: LoadingState, second: LoadingState, shouldBeEqual: Bool) async {
        if shouldBeEqual {
            #expect(first == second, "LoadingStates should be equal")
        } else {
            #expect(first != second, "LoadingStates should not be equal")
        }
    }
    
    @Test("Error messages", arguments: [
        "Network connection lost",
        "Server timeout",
        "Invalid response format",
        "Authentication failed"
    ])
    func errorMessageHandling(errorMessage: String) async {
        let errorState = LoadingState.error(errorMessage)
        #expect(errorState.errorMessage == errorMessage, "Should preserve error message")
        #expect(!errorState.isLoading, "Error state should not be loading")
    }
}
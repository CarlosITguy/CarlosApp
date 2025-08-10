//
//  EnhancedPokedexViewModelXCTests.swift
//  CarlosVTests - XCTest Approach
//
//  Testing EnhancedPokedexViewModel using traditional XCTest framework
//

import XCTest
@testable import CarlosV

@MainActor
final class EnhancedPokedexViewModelXCTests: XCTestCase {
    
    var viewModel: EnhancedPokedexViewModel!
    var mockService: MockPokemonNetworkService!
    
    override func setUp() async throws {
        try await super.setUp()
        
        // Create fresh instances for each test
        mockService = MockPokemonNetworkService()
        viewModel = EnhancedPokedexViewModel(service: mockService)
    }
    
    override func tearDown() async throws {
        viewModel = nil
        mockService = nil
        
        try await super.tearDown()
    }
    
    // MARK: - Initial State Tests
    
    func testInitialState() async throws {
        // Given: Fresh ViewModel instance
        // When: No actions performed
        // Then: Initial state should be correct
        
        XCTAssertTrue(viewModel.pokemonList.isEmpty, "Pokemon list should be empty initially")
        XCTAssertEqual(viewModel.loadingState, LoadingState.idle, "Loading state should be idle initially")
    }
    
    // MARK: - LoadingState Enum Tests
    
    func testLoadingStateProperties() async throws {
        // Test LoadingState.isLoading property
        XCTAssertFalse(LoadingState.idle.isLoading, "idle should not be loading")
        XCTAssertTrue(LoadingState.loading.isLoading, "loading should be loading")
        XCTAssertFalse(LoadingState.loaded.isLoading, "loaded should not be loading")
        XCTAssertFalse(LoadingState.error("test").isLoading, "error should not be loading")
        
        // Test LoadingState.errorMessage property
        XCTAssertNil(LoadingState.idle.errorMessage, "idle should have no error message")
        XCTAssertNil(LoadingState.loading.errorMessage, "loading should have no error message")
        XCTAssertNil(LoadingState.loaded.errorMessage, "loaded should have no error message")
        XCTAssertEqual(LoadingState.error("test error").errorMessage, "test error", "error should return error message")
    }
    
    // MARK: - Fetch Pokemons Success Tests
    
    func testFetchPokemonsSuccessInitialLoad() async throws {
        // Given: Mock service configured for success
        mockService.configureForSuccess()
        
        // When: Fetching Pokemon for the first time
        await viewModel.fetchPokemons()
        
        // Then: State should be correct
        XCTAssertEqual(viewModel.loadingState, LoadingState.loaded, "Loading state should be loaded")
        XCTAssertFalse(viewModel.pokemonList.isEmpty, "Pokemon list should not be empty")
        XCTAssertTrue(viewModel.pokemonList.count > 0, "Pokemon list should contain Pokemon")
        
        // Verify Pokemon are sorted by order
        let orders = viewModel.pokemonList.map { $0.order }
        let sortedOrders = orders.sorted()
        XCTAssertEqual(orders, sortedOrders, "Pokemon should be sorted by order")
    }
    
    func testFetchPokemonsSuccessLoadMore() async throws {
        // Given: Mock service configured for success and initial data loaded
        mockService.configureForSuccess()
        await viewModel.fetchPokemons()  // Initial load
        let initialCount = viewModel.pokemonList.count
        
        // When: Loading more Pokemon
        await viewModel.fetchPokemons()
        
        // Then: Should have more Pokemon
        XCTAssertEqual(viewModel.loadingState, LoadingState.loaded, "Loading state should be loaded")
        XCTAssertGreaterThan(viewModel.pokemonList.count, initialCount, "Should have more Pokemon after loading more")
    }
    
    // MARK: - Fetch Pokemons Error Tests
    
    func testFetchPokemonsError() async throws {
        // Given: Mock service configured for error
        mockService.configureForError()
        
        // When: Fetching Pokemon
        await viewModel.fetchPokemons()
        
        // Then: Should be in error state
        if case .error(let message) = viewModel.loadingState {
            XCTAssertFalse(message.isEmpty, "Error message should not be empty")
        } else {
            XCTFail("Loading state should be error")
        }
        
        XCTAssertTrue(viewModel.pokemonList.isEmpty, "Pokemon list should remain empty on error")
    }
    
    func testFetchPokemonsErrorWithExistingData() async throws {
        // Given: Mock service with existing data, then configured for error
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
            XCTFail("Loading state should be error")
        }
        
        XCTAssertEqual(viewModel.pokemonList.count, existingCount, 
                      "Should keep existing Pokemon when additional fetch fails")
    }
    
    // MARK: - Refresh Pokemons Tests
    
    func testRefreshPokemonsSuccess() async throws {
        // Given: Mock service with existing data
        mockService.configureForSuccess()
        await viewModel.fetchPokemons()  // Load initial data
        XCTAssertFalse(viewModel.pokemonList.isEmpty, "Should have initial data")
        
        // When: Refreshing Pokemon list
        await viewModel.refreshPokemons()
        
        // Then: Should have refreshed data
        XCTAssertEqual(viewModel.loadingState, LoadingState.loaded, "Loading state should be loaded")
        XCTAssertFalse(viewModel.pokemonList.isEmpty, "Pokemon list should not be empty after refresh")
        
        // Verify Pokemon are sorted by order
        let orders = viewModel.pokemonList.map { $0.order }
        let sortedOrders = orders.sorted()
        XCTAssertEqual(orders, sortedOrders, "Pokemon should be sorted by order after refresh")
    }
    
    func testRefreshPokemonsError() async throws {
        // Given: Mock service with initial success, then error
        mockService.configureForSuccess()
        await viewModel.fetchPokemons()  // Load initial data
        XCTAssertFalse(viewModel.pokemonList.isEmpty, "Should have initial data")
        
        mockService.configureForError()
        
        // When: Refreshing Pokemon list fails
        await viewModel.refreshPokemons()
        
        // Then: Should be in error state with empty list (refresh clears existing data)
        if case .error = viewModel.loadingState {
            // Expected error state
        } else {
            XCTFail("Loading state should be error")
        }
        
        XCTAssertTrue(viewModel.pokemonList.isEmpty, 
                     "Pokemon list should be empty after failed refresh")
    }
    
    // MARK: - Concurrent Request Prevention Tests
    
    func testConcurrentFetchPrevention() async throws {
        // Given: Mock service with delay
        mockService.configureForSuccess()
        mockService.networkDelay = 0.2
        
        // When: Starting multiple concurrent fetch requests
        let task1 = Task { await viewModel.fetchPokemons() }
        let task2 = Task { await viewModel.fetchPokemons() }
        let task3 = Task { await viewModel.fetchPokemons() }
        
        // Wait for all tasks to complete
        await task1.value
        await task2.value
        await task3.value
        
        // Then: Should not have excessive duplicates
        let expectedMaxCount = 15  // Conservative estimate
        XCTAssertLessThanOrEqual(viewModel.pokemonList.count, expectedMaxCount,
                               "Concurrent requests should be prevented")
    }
    
    func testConcurrentRefreshPrevention() async throws {
        // Given: Mock service with delay and initial data
        mockService.configureForSuccess()
        await viewModel.fetchPokemons()  // Initial data
        
        mockService.networkDelay = 0.2
        
        // When: Starting multiple concurrent refresh requests
        let task1 = Task { await viewModel.refreshPokemons() }
        let task2 = Task { await viewModel.refreshPokemons() }
        
        // Wait for all tasks to complete
        await task1.value
        await task2.value
        
        // Then: Should have reasonable amount of Pokemon (not duplicated)
        let expectedMaxCount = 10
        XCTAssertLessThanOrEqual(viewModel.pokemonList.count, expectedMaxCount,
                               "Concurrent refresh should be prevented")
        XCTAssertEqual(viewModel.loadingState, LoadingState.loaded, "Should end in loaded state")
    }
    
    // MARK: - Pokemon Deduplication Tests
    
    func testPokemonDeduplication() async throws {
        // Given: Mock service configured for success
        mockService.configureForSuccess()
        
        // When: Fetching Pokemon multiple times
        await viewModel.fetchPokemons()
        await viewModel.fetchPokemons()
        await viewModel.fetchPokemons()
        
        // Then: Should not have duplicate Pokemon
        let pokemonNames = viewModel.pokemonList.map { $0.name }
        let uniqueNames = Set(pokemonNames)
        
        XCTAssertEqual(pokemonNames.count, uniqueNames.count, 
                      "Should not have duplicate Pokemon names")
    }
    
    // MARK: - State Transition Tests
    
    func testStateTransitionSequence() async throws {
        // Given: Mock service configured for success
        mockService.configureForSuccess()
        
        // Initial state
        XCTAssertEqual(viewModel.loadingState, LoadingState.idle, "Should start in idle state")
        
        // When: Fetching Pokemon (we can't easily observe the loading state due to async nature)
        await viewModel.fetchPokemons()
        
        // Then: Should end in loaded state
        XCTAssertEqual(viewModel.loadingState, LoadingState.loaded, "Should end in loaded state")
    }
    
    // MARK: - Error Handling Tests
    
    func testErrorHandlingDifferentErrorTypes() async throws {
        // Test with network error
        mockService.shouldReturnError = true
        await viewModel.fetchPokemons()
        
        if case .error(let message) = viewModel.loadingState {
            XCTAssertFalse(message.isEmpty, "Error message should not be empty")
        } else {
            XCTFail("Should be in error state")
        }
        
        // Reset for next test
        mockService.reset()
        mockService.shouldReturnNil = true
        
        // Test with nil response
        await viewModel.refreshPokemons()
        
        if case .error(let message) = viewModel.loadingState {
            XCTAssertFalse(message.isEmpty, "Error message should not be empty for nil response")
        } else {
            XCTFail("Should be in error state for nil response")
        }
    }
    
    // MARK: - Edge Cases Tests
    
    func testEmptyResponseHandling() async throws {
        // Given: Mock service configured for empty response
        mockService.configureForEmptyResponse()
        
        // When: Fetching Pokemon
        await viewModel.fetchPokemons()
        
        // Then: Should handle empty response gracefully
        XCTAssertEqual(viewModel.loadingState, LoadingState.loaded, 
                      "Should be in loaded state even with empty response")
        XCTAssertTrue(viewModel.pokemonList.isEmpty, "Pokemon list should remain empty")
    }
}
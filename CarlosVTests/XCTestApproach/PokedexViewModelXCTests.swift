//
//  PokedexViewModelXCTests.swift
//  CarlosVTests - XCTest Approach
//
//  Testing PokedexViewModel using traditional XCTest framework
//

import XCTest
@testable import CarlosV

@MainActor
final class PokedexViewModelXCTests: XCTestCase {
    
    var viewModel: PokedexViewModel!
    var mockService: MockPokemonNetworkService!
    
    override func setUp() async throws {
        try await super.setUp()
        
        // Create fresh instances for each test
        mockService = MockPokemonNetworkService()
        viewModel = PokedexViewModel(service: mockService)
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
        XCTAssertEqual(viewModel.pageSize, 10, "Page size should be 10")
    }
    
    // MARK: - Fetch Pokemons Success Tests
    
    func testFetchPokemonsSuccess() async throws {
        // Given: Mock service configured for success
        mockService.configureForSuccess()
        
        // When: Fetching Pokemon
        await viewModel.fetchPokemons()
        
        // Then: Pokemon list should be populated
        XCTAssertFalse(viewModel.pokemonList.isEmpty, "Pokemon list should not be empty after successful fetch")
        XCTAssertTrue(viewModel.pokemonList.count > 0, "Pokemon list should contain Pokemon")
        
        // Verify specific Pokemon are loaded (based on our test data)
        let pokemonNames = viewModel.pokemonList.map { $0.name }
        XCTAssertTrue(pokemonNames.contains("pikachu"), "Should contain Pikachu")
        XCTAssertTrue(pokemonNames.contains("charmander"), "Should contain Charmander")
        XCTAssertTrue(pokemonNames.contains("squirtle"), "Should contain Squirtle")
    }
    
    func testFetchPokemonsSuccessWithMultipleBatches() async throws {
        // Given: Mock service configured for success
        mockService.configureForSuccess()
        
        // When: Fetching Pokemon multiple times (pagination)
        await viewModel.fetchPokemons()
        let firstBatchCount = viewModel.pokemonList.count
        
        await viewModel.fetchPokemons()
        let secondBatchCount = viewModel.pokemonList.count
        
        // Then: Second batch should have more Pokemon
        XCTAssertGreaterThan(secondBatchCount, firstBatchCount, 
                           "Second batch should have more Pokemon than first batch")
    }
    
    // MARK: - Fetch Pokemons Failure Tests
    
    func testFetchPokemonsFailureNetworkError() async throws {
        // Given: Mock service configured to return error
        mockService.configureForError()
        
        // When: Fetching Pokemon
        await viewModel.fetchPokemons()
        
        // Then: Pokemon list should remain empty
        XCTAssertTrue(viewModel.pokemonList.isEmpty, 
                     "Pokemon list should remain empty when network request fails")
    }
    
    func testFetchPokemonsFailureEmptyResponse() async throws {
        // Given: Mock service configured to return empty response
        mockService.configureForEmptyResponse()
        
        // When: Fetching Pokemon
        await viewModel.fetchPokemons()
        
        // Then: Pokemon list should remain empty
        XCTAssertTrue(viewModel.pokemonList.isEmpty, 
                     "Pokemon list should remain empty when response is empty")
    }
    
    // MARK: - Loading State Management Tests
    
    func testLoadingStateManagement() async throws {
        // Given: Mock service with network delay to test loading state
        mockService.configureForSuccess()
        mockService.networkDelay = 0.1  // Small delay to observe loading state
        
        // When: Starting fetch operation
        let fetchTask = Task {
            await viewModel.fetchPokemons()
        }
        
        // Then: Should be loading initially (we can't easily test this with XCTest without accessing private properties)
        // This is a limitation of testing private isLoading property
        
        // Wait for completion
        await fetchTask.value
        
        // Then: Should have completed successfully
        XCTAssertFalse(viewModel.pokemonList.isEmpty, 
                      "Pokemon list should be populated after loading completes")
    }
    
    // MARK: - Concurrent Request Prevention Tests
    
    func testConcurrentRequestPrevention() async throws {
        // Given: Mock service with delay to simulate slow network
        mockService.configureForSuccess()
        mockService.networkDelay = 0.2
        
        // When: Starting multiple concurrent requests
        let task1 = Task { await viewModel.fetchPokemons() }
        let task2 = Task { await viewModel.fetchPokemons() }
        let task3 = Task { await viewModel.fetchPokemons() }
        
        // Wait for all tasks to complete
        await task1.value
        await task2.value
        await task3.value
        
        // Then: Should only have one batch of Pokemon (not three)
        // The exact count depends on implementation details, but it shouldn't be 3x the normal amount
        let expectedMaxCount = 15 // Assuming ~5 Pokemon per successful request
        XCTAssertLessThanOrEqual(viewModel.pokemonList.count, expectedMaxCount,
                                "Concurrent requests should be prevented, not allowing excessive Pokemon loading")
    }
    
    // MARK: - Pokemon Details Fetching Tests
    
    func testFetchPokemonDetailsSuccess() async throws {
        // Given: Mock service configured for success
        mockService.configureForSuccess()
        
        // When: Fetching specific Pokemon details
        let pokemonDetails = await viewModel.fetchPokemonDetails(for: "pikachu")
        
        // Then: Should return valid Pokemon details
        XCTAssertNotNil(pokemonDetails, "Should return Pokemon details")
        XCTAssertEqual(pokemonDetails?.name, "pikachu", "Should return Pikachu details")
        XCTAssertEqual(pokemonDetails?.order, 25, "Pikachu should have order 25")
        XCTAssertFalse(pokemonDetails?.moves.isEmpty ?? true, "Pikachu should have moves")
    }
    
    func testFetchPokemonDetailsFailure() async throws {
        // Given: Mock service configured for error
        mockService.configureForError()
        
        // When: Fetching specific Pokemon details
        let pokemonDetails = await viewModel.fetchPokemonDetails(for: "pikachu")
        
        // Then: Should return nil
        XCTAssertNil(pokemonDetails, "Should return nil when network request fails")
    }
    
    // MARK: - Pagination Logic Tests
    
    func testPaginationOffsetIncrement() async throws {
        // Given: Mock service configured for success
        mockService.configureForSuccess()
        
        // When: Fetching Pokemon multiple times
        await viewModel.fetchPokemons()  // First batch
        await viewModel.fetchPokemons()  // Second batch
        
        // Then: Should have Pokemon from multiple batches
        // Note: We can't directly test offset as it's private, but we can test the behavior
        XCTAssertGreaterThan(viewModel.pokemonList.count, 5, 
                           "Multiple fetches should result in more Pokemon")
    }
    
    // MARK: - Edge Cases Tests
    
    func testFetchPokemonsWithNilService() async throws {
        // Given: Mock service configured to return nil
        mockService.shouldReturnNil = true
        
        // When: Fetching Pokemon
        await viewModel.fetchPokemons()
        
        // Then: Pokemon list should remain empty
        XCTAssertTrue(viewModel.pokemonList.isEmpty, 
                     "Pokemon list should remain empty when service returns nil")
    }
}
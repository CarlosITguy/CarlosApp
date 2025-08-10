//
//  MockPokemonNetworkService.swift
//  CarlosVTests - Shared Mock Service
//
//  Created for testing both XCTest and Swift Testing approaches
//

import Foundation
@testable import CarlosV

/// Mock implementation of PokemonNetworkServiceProtocol for testing
final class MockPokemonNetworkService: PokemonNetworkServiceProtocol, Sendable {
    
    // MARK: - Control Properties
    private let _shouldReturnError = SendableBox(false)
    private let _shouldReturnEmptyList = SendableBox(false)
    private let _shouldReturnNil = SendableBox(false)
    private let _networkDelay = SendableBox(0.0)
    
    var shouldReturnError: Bool {
        get { _shouldReturnError.value }
        set { _shouldReturnError.value = newValue }
    }
    
    var shouldReturnEmptyList: Bool {
        get { _shouldReturnEmptyList.value }
        set { _shouldReturnEmptyList.value = newValue }
    }
    
    var shouldReturnNil: Bool {
        get { _shouldReturnNil.value }
        set { _shouldReturnNil.value = newValue }
    }
    
    var networkDelay: TimeInterval {
        get { _networkDelay.value }
        set { _networkDelay.value = newValue }
    }
    
    // MARK: - PokemonNetworkServiceProtocol Implementation
    
    func fetchPokemonList(pageSize: Int, offset: Int) async -> PokemonListRequest? {
        // Simulate network delay if specified
        if networkDelay > 0 {
            try? await Task.sleep(nanoseconds: UInt64(networkDelay * 1_000_000_000))
        }
        
        // Return nil if configured
        if shouldReturnNil {
            return nil
        }
        
        // Return empty list if configured
        if shouldReturnEmptyList {
            return TestData.emptyPokemonListResponse
        }
        
        // Return error by returning nil (simulating network failure)
        if shouldReturnError {
            return nil
        }
        
        // Return successful response with test data
        return TestData.samplePokemonListResponse(pageSize: pageSize, offset: offset)
    }
    
    func fetchPokemonDetails(for name: String) async -> PokemonDetails? {
        // Simulate network delay if specified
        if networkDelay > 0 {
            try? await Task.sleep(nanoseconds: UInt64(networkDelay * 1_000_000_000))
        }
        
        // Return nil if configured
        if shouldReturnNil || shouldReturnError {
            return nil
        }
        
        // Return predefined Pokemon details
        return TestData.samplePokemonDetails(for: name)
    }
    
    // MARK: - Helper Methods for Testing
    
    func reset() {
        shouldReturnError = false
        shouldReturnEmptyList = false
        shouldReturnNil = false
        networkDelay = 0.0
    }
    
    func configureForSuccess() {
        reset()
    }
    
    func configureForError() {
        reset()
        shouldReturnError = true
    }
    
    func configureForEmptyResponse() {
        reset()
        shouldReturnEmptyList = true
    }
}

// MARK: - Sendable Helper

/// Helper class to make properties thread-safe for Sendable conformance
final class SendableBox<T>: @unchecked Sendable {
    private let lock = NSLock()
    private var _value: T
    
    init(_ value: T) {
        self._value = value
    }
    
    var value: T {
        get {
            lock.lock()
            defer { lock.unlock() }
            return _value
        }
        set {
            lock.lock()
            defer { lock.unlock() }
            _value = newValue
        }
    }
}
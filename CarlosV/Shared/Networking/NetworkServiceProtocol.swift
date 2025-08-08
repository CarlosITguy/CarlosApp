//
//  NetworkServiceProtocol.swift
//  CarlosV - Shared Networking
//
//  Created by Carlos Valderrama on 2/15/25.
//

import Foundation

/// Protocol defining the interface for generic network service
/// This protocol allows for dependency injection and easier testing
protocol NetworkServiceProtocol: Sendable {
    /// Fetch data using a URLRequest
    /// - Parameter request: The URLRequest to execute
    /// - Returns: Decoded object of type T, or nil if request fails
    func fetch<T: Decodable>(request: URLRequest) async -> T?
    
    /// Fetch data using a URL
    /// - Parameter url: The URL to fetch from
    /// - Returns: Decoded object of type T, or nil if request fails
    func fetch<T: Decodable>(url: URL) async -> T?
}
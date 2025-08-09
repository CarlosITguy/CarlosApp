//
//  NetworkService.swift
//  CarlosV - Shared Networking
//
//  Created by Carlos Valderrama on 2/15/25.
//

import Foundation

/// Generic network service implementation
/// Provides reusable networking functionality for all mini-apps in the portfolio
struct NetworkService: NetworkServiceProtocol {
    
    private let session = URLSession.shared
    
    func fetch<T>(url: URL) async -> T? where T: Decodable {
        let request = URLRequest(url: url)
        return await fetch(request: request)
    }
    
    func fetch<T: Decodable>(request: URLRequest) async -> T? {
        do {
            let (data, response) = try await session.data(for: request)
            
            guard isValid(response) else { return nil }
            
            return try JSONDecoder().decode(T.self, from: data)
        } catch let error as URLError {
            print("Network error \(error)")
            return nil
        } catch {
            print("Decoding error: \(error)")
            return nil
        }
    }
}

// MARK: - Response Validation
extension NetworkService {
    /// Validates HTTP response status codes
    /// - Parameter response: The URLResponse to validate
    /// - Returns: True if response is valid (2xx status code), false otherwise
    func isValid(_ response: URLResponse) -> Bool {
        guard let httpUrlResponse = response as? HTTPURLResponse else {
            print("Invalid response type")
            return false
        }
        
        guard (200...299).contains(httpUrlResponse.statusCode) else {
            let code = httpUrlResponse.statusCode
            switch code {
            case 404:
                print("Resource not found (404)")
            case 401:
                print("Unauthorized access (401)")
            case 500...599:
                print("Server error (\(code))")
            default:
                print("HTTP error with status code \(code)")
            }
            return false
        }
        return true
    }
}
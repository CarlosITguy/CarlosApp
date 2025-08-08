//
//  NetworkErrors.swift
//  CarlosV - Shared Networking
//
//  Created by Carlos Valderrama on 2/15/25.
//

import Foundation

/// Common network error types used across all mini-apps
enum NetworkErrors: Error {
    case badResponse
    case badUrl
    case decodingError
    
    var localizedDescription: String {
        switch self {
        case .badResponse:
            return "Invalid server response"
        case .badUrl:
            return "Invalid URL format"
        case .decodingError:
            return "Failed to decode response data"
        }
    }
}
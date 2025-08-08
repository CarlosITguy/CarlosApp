//
//  HTTPMethod.swift
//  CarlosV - Shared Utilities
//
//  Created by Carlos Valderrama on 2/15/25.
//

import Foundation

/// HTTP method enumeration for network requests
/// Used across all mini-apps for consistent API communication
public enum HTTPMethod: String, Equatable, Hashable, CaseIterable {
    case DELETE, GET, HEAD, PATCH, POST, PUT
}
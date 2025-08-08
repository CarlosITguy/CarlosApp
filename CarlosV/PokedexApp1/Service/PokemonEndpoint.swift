//  PokemonEndpoint.swift
//  CarlosV
//
//  Created by Carlos Valderrama on 2/15/25.

import Foundation

enum PokemonEndpoint {
    case list(pageSize: Int, offset: Int)
    case details(name: String)
    
    var path: String {
        switch self {
        case .list:
            return "/api/v2/pokemon"
        case .details(let name):
            return "/api/v2/pokemon/\(name)"
        }
    }
    
    var queryItems: [URLQueryItem] {
        switch self {
        case .list(let pageSize, let offset):
            return [
                URLQueryItem(name: "offset", value: "\(offset)"),
                URLQueryItem(name: "limit", value: "\(pageSize)")
            ]
        case .details:
            return []
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .list, .details:
            return .GET
        }
    }
}

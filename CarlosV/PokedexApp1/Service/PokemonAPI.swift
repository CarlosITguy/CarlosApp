//
//  PkemonEndpoint.swift
//  CarlosV
//
//  Created by Carlos Valderrama on 2/15/25.
//

import Foundation

struct PokemonAPI {
    init(path: String, queryItems: [URLQueryItem]) {
        self.path = path
        self.queryItems = queryItems
    }
    
    let scheme: String = "https"
    let path: String
    let queryItems: [URLQueryItem]
    let host: String = "pokeapi.co"
    
    var url: URL? {
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.path = path
        components.queryItems = queryItems
        
        return components.url
    }
}

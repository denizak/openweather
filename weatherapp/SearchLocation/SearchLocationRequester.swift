//
//  SearchLocationRequest.swift
//  weatherapp
//
//  Created by deni zakya on 29/08/23.
//

import Foundation

struct LocationResponse: Decodable {
    let name: String
    let lat: Double
    let lon: Double
    let country: String
    let state: String?
}

struct SearchLocationRequester {
    private let decoder = JSONDecoder()

    func getLocation(name: String) async throws -> [LocationResponse] {
        let path = "/geo/1.0/direct"
        let params = [
            "q": "\(name)",
            "limit": "3"
        ]
        if let url = API.makeURL(path: path, params: params) {
            let (data, _) = try await URLSession.shared.data(from: url)
            return try decoder.decode([LocationResponse].self, from: data)
        } else {
            return []
        }
    }
}

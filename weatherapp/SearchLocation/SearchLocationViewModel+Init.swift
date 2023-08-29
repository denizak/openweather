//
//  SearchLocationViewModel+Init.swift
//  weatherapp
//
//  Created by deni zakya on 29/08/23.
//

import Foundation

extension SearchLocationViewModel {
    static func make() -> SearchLocationViewModel {
        let requester = SearchLocationRequester()
        return .init { value in
            do {
                return try await requester.getLocation(name: value).map { $0.toLocation() }
            } catch {
                return []
            }
        }
    }
}

extension LocationResponse {
    func toLocation() -> Location {
        .init(city: name, state: state, country: country, coordinate: .init(lat: lat, long: lon))
    }
}

//
//  SearchLocationViewModel.swift
//  weatherapp
//
//  Created by deni zakya on 29/08/23.
//

import Foundation
import Combine

struct Location {
    let name: String
    let country: String
    let coordinate: Coordinate
}

final class SearchLocationViewModel {

    private(set) var currentLocations: [Location] = [] {
        didSet {
            reloadDataSubject.send(())
        }
    }

    private let reloadDataSubject = PassthroughSubject<Void, Never>()
    var reloadData: AnyPublisher<Void, Never> {
        reloadDataSubject.eraseToAnyPublisher()
    }

    typealias GetLocation = (String) async -> [Location]
    private var getLocation: GetLocation
    init(getLocation: @escaping GetLocation) {
        self.getLocation = getLocation
    }

    func search(_ value: String) {
        Task { [unowned self] in
            let locations = await getLocation(value)
            self.currentLocations = locations
        }
    }
}

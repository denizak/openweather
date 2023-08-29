//
//  SearchLocationViewModel.swift
//  weatherapp
//
//  Created by deni zakya on 29/08/23.
//

import Foundation
import Combine

final class SearchLocationViewModel {

    private(set) var currentLocations: [Location] = [] {
        didSet {
            reloadDataSubject.send(())
        }
    }

    private let searchTextSubject = PassthroughSubject<String, Never>()
    private var task: Task<Void, Never>?
    private var cancellable: AnyCancellable?

    private let reloadDataSubject = PassthroughSubject<Void, Never>()
    var reloadData: AnyPublisher<Void, Never> {
        reloadDataSubject.eraseToAnyPublisher()
    }

    typealias GetLocation = (String) async -> [Location]
    private var getLocation: GetLocation
    init(getLocation: @escaping GetLocation) {
        self.getLocation = getLocation
        cancellable = searchTextSubject.debounce(for: .seconds(1), scheduler: RunLoop.main)
            .sink { [weak self] text in
                self?.executeSearch(text)
            }
    }

    func search(_ value: String) {
        searchTextSubject.send(value)
    }

    private func executeSearch(_ value: String) {
        task?.cancel()
        task = Task { [unowned self] in
            let locations = await getLocation(value)
            self.currentLocations = locations
        }
    }
}

//
//  SearchLocationViewModelTests.swift
//  weatherappTests
//
//  Created by deni zakya on 29/08/23.
//

import XCTest
import Combine
@testable import weatherapp

final class SearchLocationViewModelTests: XCTestCase {

    private var subscribers: [AnyCancellable] = []
    override func tearDown() {
        subscribers = []
    }

    func testSearch() throws {
        let expectLocations = expectation(description: #function)
        var actualSearchText = ""
        let sut = SearchLocationViewModel(
            getLocation: { value in
                actualSearchText = value
                return [.init(city: "any-city", state: "any-state", country: "any-country", coordinate: .init(lat: 202, long: 303))]
            })
        sut.reloadData.sink(receiveValue: { _ in
            expectLocations.fulfill()
        }).store(in: &subscribers)

        sut.search("any-location")

        wait(for: [expectLocations])

        let firstActualLocation = try XCTUnwrap(sut.currentLocations.first)
        XCTAssertEqual(firstActualLocation.city, "any-city")
        XCTAssertEqual(actualSearchText, "any-location")
    }
}

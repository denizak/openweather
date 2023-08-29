//
//  SearchLocationRequesterTests.swift
//  weatherappIntegrationTests
//
//  Created by deni zakya on 29/08/23.
//

import XCTest
@testable import weatherapp

final class SearchLocationRequesterTests: XCTestCase {

    func testGetLocation() async throws {
        let sut = SearchLocationRequester()

        let response = try await sut.getLocation(name: "Berlin")

        let firstLocation = try XCTUnwrap(response.first)
        XCTAssertEqual(firstLocation.name, "Berlin")
        XCTAssertEqual(firstLocation.country, "DE")
        XCTAssertGreaterThan(firstLocation.lat, 0)
        XCTAssertGreaterThan(firstLocation.lon, 0)
    }

}

//
//  OpenWeatherRequesterTests.swift
//  weatherappIntegrationTests
//
//  Created by Deni Zakya on 27/08/23.
//

import XCTest
@testable import weatherapp

final class OpenWeatherRequesterTests: XCTestCase {
    
    func testGetWeatherWithCoordinate() async throws {
        let sut = OpenWeatherRequester()
        let coordinate = Coordinate(lat: 52.520008, long: 13.404954)
        
        let response = try await sut.getWeather(coordinate: coordinate)
        
        let unwrappedResponse = try XCTUnwrap(response)
        XCTAssertEqual(unwrappedResponse.name, "Mitte")
        XCTAssertGreaterThanOrEqual(unwrappedResponse.main.temp, -20)
    }
}

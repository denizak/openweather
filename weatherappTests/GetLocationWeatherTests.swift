//
//  GetLocationWeatherTests.swift
//  weatherappTests
//
//  Created by Deni Zakya on 30/08/23.
//

import XCTest
@testable import weatherapp

final class GetLocationWeatherTests: XCTestCase {

    func testFetch_onLocationExists() {
        let expectEventUpdate = expectation(description: #function)
        let expectedWeatherInfo = WeatherInfo(
            city: "city-name",
            country: "any-country",
            temperature: 47,
            unit: .metric,
            coordinate: .init(lat: 101, long: 202))
        let sut = GetLocationWeather(requestWeatherInfo: { coordinate, unit in
                .init(city: "city-name", country: "any-country", temperature: 47, unit: unit, coordinate: coordinate)
        }, getActualLocationWeather: GetActualLocationWeatherSpy())

        var actualWeatherInfo: WeatherInfo?
        sut.eventUpdate = { event in
            if case .actualWeather(let info) = event {
                actualWeatherInfo = info
            } else {
                XCTFail("should receive .actualWeather")
            }

            expectEventUpdate.fulfill()
        }

        sut.fetch(unit: .metric, coordinate: .init(lat: 101, long: 202))

        wait(for: [expectEventUpdate])
        XCTAssertEqual(actualWeatherInfo, expectedWeatherInfo)
    }
    
    func testFetch_onLocationNil() {
        let getActualLocationWeather = GetActualLocationWeatherSpy()
        let sut = GetLocationWeather(requestWeatherInfo: { coordinate, unit in
                .init(city: "city-name", country: "any-country", temperature: 47, unit: unit, coordinate: coordinate)
        }, getActualLocationWeather: getActualLocationWeather)

        sut.fetch(unit: .imperial, coordinate: nil)

        XCTAssertTrue(getActualLocationWeather.fetchCalled)
        XCTAssertEqual(getActualLocationWeather.actualUnits, .imperial)
        XCTAssertNil(getActualLocationWeather.actualCoordinate)
    }
    
    func testFetch_onReceived_getWeatherError() {
        let sut =  GetLocationWeather(
            requestWeatherInfo: { _, _ in throw GetWeatherEvent.WeatherError.missingData },
            getActualLocationWeather: GetActualLocationWeatherDummy())

        var actualWeatherError: GetWeatherEvent.WeatherError?
        sut.eventUpdate = { event in
            if case .getWeatherError(let error) = event {
                actualWeatherError = error
            } else {
                XCTFail("should receive .getWeatherError")
            }
        }

        sut.fetch(unit: .metric, coordinate: .init(lat: 1, long: 1))

        XCTAssertEqual(actualWeatherError, .missingData)
    }
}

private final class GetActualLocationWeatherDummy: GetLocationWeatherProtocol {
    var eventUpdate: (GetWeatherEvent) -> Void = { _ in }
    func fetch(unit: Units, coordinate: Coordinate?) {}
}

private final class GetActualLocationWeatherSpy: GetLocationWeatherProtocol {
    var eventUpdate: (GetWeatherEvent) -> Void = { _ in }
    
    var fetchCalled = false
    var actualUnits: Units?
    var actualCoordinate: Coordinate? = .init(lat: 1, long: 1)
    func fetch(unit: Units, coordinate: Coordinate?) {
        fetchCalled = true
        actualUnits = unit
        actualCoordinate = coordinate
    }
}

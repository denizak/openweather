//
//  GetActualLocationWeatherTests.swift
//  weatherappTests
//
//  Created by deni zakya on 28/08/23.
//

import XCTest
@testable import weatherapp

final class GetActualLocationWeatherTests: XCTestCase {

    func testFetch_onReceived_actualWeather() {
        let expectEventUpdate = expectation(description: #function)
        let sut = GetActualLocationWeather(
            fetchLocation: { $0.locationUpdated(latitude: 101, longitude: 202) },
            requestWeatherInfo: { coordinate, unit in  .init(name: "name", temperature: 47, unit: unit) })

        var actualWeatherInfo: WeatherInfo?
        sut.eventUpdate = { event in
            if case .actualWeather(let info) = event {
                actualWeatherInfo = info
            } else {
                XCTFail("should receive .actualWeather")
            }

            expectEventUpdate.fulfill()
        }

        sut.fetch(unit: .metric)

        wait(for: [expectEventUpdate])
        XCTAssertEqual(actualWeatherInfo, .init(name: "name", temperature: 47, unit: .metric))
    }

    func testFetch_onReceived_unableToLocateUser() {
        let sut = GetActualLocationWeather(
            fetchLocation: { $0.locationError(error: .userDeniedLocationService) },
            requestWeatherInfo: { _, _ in nil })

        var actualEvent: GetWeatherEvent?
        sut.eventUpdate = { event in
            if case .unableToLocateUser = event {
                actualEvent = event
            } else {
                XCTFail("should receive .unableToLocateUser")
            }
        }

        sut.fetch(unit: .metric)

        XCTAssertEqual(actualEvent, .unableToLocateUser)
    }

    func testFetch_onReceived_getWeatherError() {
        let expectEventUpdate = expectation(description: #function)
        let sut = GetActualLocationWeather(
            fetchLocation: { $0.locationUpdated(latitude: 1, longitude: 1) },
            requestWeatherInfo: { _, _ in throw GetWeatherEvent.WeatherError.missingData })

        var actualWeatherError: GetWeatherEvent.WeatherError?
        sut.eventUpdate = { event in
            if case .getWeatherError(let error) = event {
                actualWeatherError = error
            } else {
                XCTFail("should receive .getWeatherError")
            }

            expectEventUpdate.fulfill()
        }

        sut.fetch(unit: .metric)

        wait(for: [expectEventUpdate])
        XCTAssertEqual(actualWeatherError, .missingData)
    }
}

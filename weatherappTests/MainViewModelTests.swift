//
//  MainViewModelTests.swift
//  weatherappTests
//
//  Created by deni zakya on 28/08/23.
//

import XCTest
import Combine
@testable import weatherapp

final class MainViewModelTests: XCTestCase {

    private var subscribers: [AnyCancellable] = []
    override func tearDown() {
        subscribers = []
    }

    func testViewLoad() {
        var actualTemperatureValue = ""
        var actualNameValue = ""
        var actualLoading: [Bool] = []

        let locationWeatherSpy = GetActualLocationWeatherSpy()
        let sut = MainViewModel(getWeather: locationWeatherSpy)
        sut.temperature.sink(receiveValue: { value in actualTemperatureValue = value }).store(in: &subscribers)
        sut.name.sink(receiveValue: { value in actualNameValue = value }).store(in: &subscribers)
        sut.showLoading.sink(receiveValue: { value in actualLoading.append(value) }).store(in: &subscribers)

        sut.viewLoad()
        locationWeatherSpy.eventUpdate(
            .actualWeather(
                .init(city: "any-city",
                      country: "any-country",
                      temperature: 77,
                      unit: .metric,
                      coordinate: .init(lat: 11, long: 22))
            )
        )

        XCTAssertEqual(actualLoading, [true, false])
        XCTAssertEqual(actualTemperatureValue, "77.0")
        XCTAssertEqual(actualNameValue, "any-city")
        XCTAssertTrue(locationWeatherSpy.fetchCalled)
        XCTAssertEqual(locationWeatherSpy.actualUnit, .metric)
    }

    func testEvent_unableToLocateUser() {
        var actualShowEnableLocationPermission = false

        let locationWeatherSpy = GetActualLocationWeatherSpy()
        let sut = MainViewModel(getWeather: locationWeatherSpy)
        sut.showEnableLocationPermission.sink(receiveValue: { actualShowEnableLocationPermission = $0 }).store(in: &subscribers)

        locationWeatherSpy.eventUpdate(.unableToLocateUser)

        XCTAssertTrue(actualShowEnableLocationPermission)
    }

    func testEvent_weatherUnavailable() {
        var actualShowWeatherUnavailable = false

        let locationWeatherSpy = GetActualLocationWeatherSpy()
        let sut = MainViewModel(getWeather: locationWeatherSpy)
        sut.showWeatherUnavailable.sink(receiveValue: { actualShowWeatherUnavailable = $0 }).store(in: &subscribers)

        locationWeatherSpy.eventUpdate(.getWeatherError(.missingData))

        XCTAssertTrue(actualShowWeatherUnavailable)
    }

    func testUpdate() {
        let locationWeatherSpy = GetActualLocationWeatherSpy()
        let sut = MainViewModel(getWeather: locationWeatherSpy)

        sut.update(unit: .imperial)

        XCTAssertTrue(locationWeatherSpy.fetchCalled)
        XCTAssertEqual(locationWeatherSpy.actualUnit, .imperial)
    }

    func testUpdateLocation() {
        let locationWeatherSpy = GetActualLocationWeatherSpy()
        let sut = MainViewModel(getWeather: locationWeatherSpy)

        sut.update(location: .init(city: "any-city", state: nil, country: "any-country", coordinate: .init(lat: 11, long: 22)),
                   unit: .imperial)

        XCTAssertTrue(locationWeatherSpy.fetchUnitCoordinateCalled)
        XCTAssertEqual(locationWeatherSpy.actualUnit, .imperial)
        XCTAssertEqual(locationWeatherSpy.actualCoordinate, .init(lat: 11, long: 22))
    }

}

final class GetActualLocationWeatherSpy : GetActualLocationWeatherProtocol {
    var eventUpdate: (GetWeatherEvent) -> Void = { _ in }

    var actualUnit: Units?
    var fetchCalled = false
    func fetch(unit: Units) {
        fetchCalled = true
        actualUnit = unit
    }

    var actualCoordinate: Coordinate?
    var fetchUnitCoordinateCalled = false
    func fetch(unit: Units, coordinate: Coordinate?) {
        fetchUnitCoordinateCalled = true
        actualUnit = unit
        actualCoordinate = coordinate
    }
}

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

    func testViewAppear() {
        var actualTemperatureValue = ""
        var actualNameValue = ""

        let locationWeatherSpy = GetActualLocationWeatherSpy()
        let sut = MainViewModel(getWeather: locationWeatherSpy)
        sut.temperature.sink(receiveValue: { value in actualTemperatureValue = value }).store(in: &subscribers)
        sut.name.sink(receiveValue: { value in actualNameValue = value }).store(in: &subscribers)

        sut.viewAppear(selectedUnit: .imperial)
        locationWeatherSpy.eventUpdate(.actualWeather(.init(name: "any-name", temperature: 77, unit: .metric)))

        XCTAssertEqual(actualTemperatureValue, "77.0")
        XCTAssertEqual(actualNameValue, "any-name")
        XCTAssertTrue(locationWeatherSpy.fetchCalled)
        XCTAssertEqual(locationWeatherSpy.actualUnit, .imperial)
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
        func testViewAppear() {
            let locationWeatherSpy = GetActualLocationWeatherSpy()
            let sut = MainViewModel(getWeather: locationWeatherSpy)

            sut.update(unit: .imperial)

            XCTAssertTrue(locationWeatherSpy.fetchCalled)
            XCTAssertEqual(locationWeatherSpy.actualUnit, .imperial)
        }
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
}

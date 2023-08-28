//
//  LocationManagerWrapperTests.swift
//  weatherappTests
//
//  Created by Deni Zakya on 27/08/23.
//

import XCTest
import CoreLocation
@testable import weatherapp

final class LocationManagerWrapperTests: XCTestCase {

    func testStart() {
        let event = LocationEventDummy()
        let (sut, locationManager) = makeSUT()

        sut.start(with: event)

        XCTAssertTrue(locationManager.startUpdatingLocationCalled)
    }

    func testLocationManagerDelegate_didChangeAuthorization_notDetermined() {
        let event = LocationEventSpy()
        let (sut, locationManager) = makeSUT(status: .notDetermined)

        sut.start(with: event)
        sut.locationManagerDidChangeAuthorization(.init())

        XCTAssertTrue(locationManager.requestWhenInUseAuthorizationCalled)
    }

    func testLocationManagerDelegate_didChangeAuthorization_authorized() {
        let event = LocationEventSpy()
        let (sut, locationManager) = makeSUT(status: .authorizedWhenInUse)

        sut.start(with: event)
        sut.locationManagerDidChangeAuthorization(.init())

        XCTAssertTrue(locationManager.requestLocationCalled)
    }

    func testLocationManagerDelegate_didChangeAuthorization_denied() {
        let event = LocationEventSpy()
        let (sut, _) = makeSUT(status: .denied)

        sut.start(with: event)
        sut.locationManagerDidChangeAuthorization(.init())

        XCTAssertTrue(event.locationErrorCalled)
        XCTAssertEqual(event.actualLocationError, .userDeniedLocationService)
    }

    func testLocationManagerDelegate_didChangeAuthorization_restricted() {
        let event = LocationEventSpy()
        let (sut, _) = makeSUT(status: .restricted)

        sut.start(with: event)
        sut.locationManagerDidChangeAuthorization(.init())

        XCTAssertTrue(event.locationErrorCalled)
        XCTAssertEqual(event.actualLocationError, .userDeniedLocationService)
    }

    func testLocationManagerDelegate_didUpdateLocation() {
        let event = LocationEventSpy()
        let (sut, _) = makeSUT()

        sut.start(with: event)
        sut.locationManager(.init(), didUpdateLocations: [.init(latitude: 101, longitude: 202)])

        XCTAssertTrue(event.locationUpdatedCalled)
        XCTAssertEqual(event.actualLatitudeValue, 101)
        XCTAssertEqual(event.actualLongitudeValue, 202)
    }

    func testLocationManagerDelegate_didFailWithError() {
        let event = LocationEventSpy()
        let (sut, _) = makeSUT()

        sut.start(with: event)
        sut.locationManager(.init(), didFailWithError: CLError(.denied))

        XCTAssertTrue(event.locationErrorCalled)
        XCTAssertEqual(event.actualLocationError, .userDeniedLocationService)
    }

    private func makeSUT(status: CLAuthorizationStatus = .notDetermined) -> (LocationManagerWrapper, LocationManagerSpy) {
        let locationManager = LocationManagerSpy()
        locationManager.authorizationStatusStubbed = status
        return (LocationManagerWrapper(locationManager: locationManager), locationManager)
    }
}

private final class LocationEventDummy: LocationEvent {
    func locationUpdated(latitude: Double, longitude: Double) {}
    func locationError(error: LocationError) {}
}

private final class LocationEventSpy: LocationEvent {
    var locationUpdatedCalled = false
    var actualLatitudeValue: Double = -1
    var actualLongitudeValue: Double = -1
    func locationUpdated(latitude: Double, longitude: Double) {
        locationUpdatedCalled = true
        actualLatitudeValue = latitude
        actualLongitudeValue = longitude
    }

    var locationErrorCalled = false
    var actualLocationError: LocationError?
    func locationError(error: LocationError) {
        locationErrorCalled = true
        actualLocationError = error
    }
}

private final class LocationManagerSpy: LocationManager {
    var locationManagerDelegate: LocationManagerDelegate?

    var authorizationStatusStubbed: CLAuthorizationStatus?
    var authorizationStatus: CLAuthorizationStatus { authorizationStatusStubbed ?? .notDetermined }

    var startUpdatingLocationCalled = false
    func startUpdatingLocation() {
        startUpdatingLocationCalled = true
    }

    var requestWhenInUseAuthorizationCalled = false
    func requestWhenInUseAuthorization() {
        requestWhenInUseAuthorizationCalled = true
    }

    var requestLocationCalled = false
    func requestLocation() {
        requestLocationCalled = true
    }
    func stopUpdatingLocation() {}
}

private final class LocationManagerDelegateSpy: LocationManagerDelegate {
    var event: LocationEvent?

    func locationManagerDidChangeAuthorization() {}
    func locationManager(didUpdateLocations locations: [CLLocation]) {}
    func locationManager(didFailWithError error: Error) {}
}

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
        let locationManager = LocationManagerSpy()
        let delegate = LocationManagerDelegateSpy()
        let event = LocationEventDummy()
        let sut = LocationManagerWrapper(locationManager: locationManager, managerDelegate: delegate)

        sut.start(with: event)

        XCTAssertTrue(locationManager.startMonitoringCalled)
        XCTAssertTrue(delegate.event === event)
    }
}

private final class LocationEventDummy: LocationEvent {
    func locationUpdated(latitude: Double, longitude: Double) {}
    func locationError(error: LocationError) {}
}

private final class LocationManagerSpy: LocationManager {
    var locationManagerDelegate: LocationManagerDelegate?
    var authorizationStatus: CLAuthorizationStatus { .notDetermined }

    var startMonitoringCalled = false
    func startMonitoringSignificantLocationChanges() {
        startMonitoringCalled = true
    }

    func requestWhenInUseAuthorization() {}
    func requestLocation() {}
    func stopUpdatingLocation() {}
}

private final class LocationManagerDelegateSpy: LocationManagerDelegate {
    var event: LocationEvent?

    func locationManagerDidChangeAuthorization(_ manager: LocationManager) {}
    func locationManager(_ manager: LocationManager, didUpdateLocations locations: [CLLocation]) {}
    func locationManager(_ manager: weatherapp.LocationManager, didFailWithError error: Error) {}
}

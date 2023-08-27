//
//  CLLocationManagerDelegateImplTests.swift
//  weatherappTests
//
//  Created by Deni Zakya on 27/08/23.
//

import XCTest
import CoreLocation
@testable import weatherapp

final class CLLocationManagerDelegateImplTests: XCTestCase {

    func testLocationManagerDelegate_didChangeAuthorization_notDetermined() {
        let event = LocationEventImpl()
        let (sut, locationManager, locationManagerWrapper) = makeSUT(status: .notDetermined)
        
        locationManagerWrapper.start(with: event)
        sut.locationManagerDidChangeAuthorization(locationManager)

        XCTAssertTrue(locationManager.requestWhenInUseAuthCalled)
    }
    
    func testLocationManagerDelegate_didChangeAuthorization_authorized() {
        let event = LocationEventImpl()
        let (sut, locationManager, locationManagerWrapper) = makeSUT(status: .authorizedWhenInUse)

        locationManagerWrapper.start(with: event)
        sut.locationManagerDidChangeAuthorization(locationManager)

        XCTAssertTrue(locationManager.requestLocationCalled)
    }
    
    func testLocationManagerDelegate_didChangeAuthorization_denied() {
        let event = LocationEventImpl()
        let (sut, locationManager, locationManagerWrapper) = makeSUT(status: .denied)
        
        locationManagerWrapper.start(with: event)
        sut.locationManagerDidChangeAuthorization(locationManager)

        XCTAssertEqual(event.locationError, .userDeniedLocationService)
    }
    
    func testLocationManagerDelegate_didChangeAuthorization_restricted() {
        let event = LocationEventImpl()
        let (sut, locationManager, locationManagerWrapper) = makeSUT(status: .restricted)

        locationManagerWrapper.start(with: event)
        sut.locationManagerDidChangeAuthorization(locationManager)

        XCTAssertEqual(event.locationError, .userDeniedLocationService)
    }
    
    func testLocationManagerDelegate_didUpdateLocation() {
        let event = LocationEventImpl()
        let (sut, locationManager, locationManagerWrapper) = makeSUT()

        locationManagerWrapper.start(with: event)
        sut.locationManager(
            locationManager,
            didUpdateLocations: [.init(latitude: 101, longitude: 202)]
        )

        XCTAssertEqual(event.latitude, 101)
        XCTAssertEqual(event.longitude, 202)
    }
    
    func testLocationManagerDelegate_didFailWithError() {
        let event = LocationEventImpl()
        let (sut, locationManager, locationManagerWrapper) = makeSUT()

        locationManagerWrapper.start(with: event)
        sut.locationManager(
            locationManager,
            didFailWithError: CLError(.denied)
        )

        XCTAssertEqual(event.locationError, .userDeniedLocationService)
    }
    
    private func makeSUT(
        status: CLAuthorizationStatus = .notDetermined
    ) -> (CLLocationManagerDelegateImpl, LocationManagerMock, LocationManagerWrapper) {
        let sut = CLLocationManagerDelegateImpl()
        let locationManager = LocationManagerMock()
        locationManager.authorizationStatusStubbed = status
        let locationManagerWrapper = LocationManagerWrapper(locationManager: locationManager, managerDelegate: sut)
        
        return (sut, locationManager, locationManagerWrapper)
    }

}

private final class LocationEventImpl: LocationEvent {
    var latitude: Double = -1
    var longitude: Double = -1
    func locationUpdated(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
    
    var locationError: LocationError?
    func locationError(error: LocationError) {
        locationError = error
    }
}

private final class LocationManagerMock: LocationManager {
    var locationManagerDelegate: LocationManagerDelegate?

    var authorizationStatusStubbed: CLAuthorizationStatus = .notDetermined
    var authorizationStatus: CLAuthorizationStatus { authorizationStatusStubbed }

    var startMonitoringCalled = false
    func startMonitoringSignificantLocationChanges() {
        startMonitoringCalled = true
    }

    var requestWhenInUseAuthCalled = false
    func requestWhenInUseAuthorization() {
        requestWhenInUseAuthCalled = true
    }

    var requestLocationCalled = false
    func requestLocation() {
        requestLocationCalled = true
    }
    
    var stopUpdatingLocationCalled = false
    func stopUpdatingLocation() {
        stopUpdatingLocationCalled = true
    }
}

private final class LocationManagerDelegateSpy: LocationManagerDelegate {
    var event: LocationEvent?

    var didChangeAuthorizationCalled = false
    func locationManagerDidChangeAuthorization(_ manager: LocationManager) {
        didChangeAuthorizationCalled = true
    }
    
    
    func locationManager(_ manager: LocationManager, didUpdateLocations locations: [CLLocation]) {
        
    }
    
    func locationManager(_ manager: weatherapp.LocationManager, didFailWithError error: Error) {
    }
}

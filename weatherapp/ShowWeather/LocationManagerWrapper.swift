//
//  LocationManager.swift
//  weatherapp
//
//  Created by Deni Zakya on 27/08/23.
//

import Foundation
import CoreLocation

final class LocationManagerWrapper: NSObject, LocationManagerDelegate {
    private var locationManager: LocationManager

    init(locationManager: LocationManager = CLLocationManager()) {
        self.locationManager = locationManager

        super.init()
        self.locationManager.locationManagerDelegate = self
    }

    func start(with locationEvent: LocationEvent? = nil) {
        self.event = locationEvent
        locationManager.startUpdatingLocation()
    }

    // MARK: - LocationManagerDelegate

    weak var event: LocationEvent?
    
    func locationManagerDidChangeAuthorization() {
        switch locationManager.authorizationStatus {
        case .notDetermined: locationManager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            event?.locationError(error: .userDeniedLocationService)
        default: locationManager.requestLocation()
        }
    }
    
    func locationManager(didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            event?.locationUpdated(
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude
            )
        }
    }
    
    func locationManager(didFailWithError error: Error) {
        let errorCode = (error as? CLError)?.code
        switch errorCode {
        case .denied:
            locationManager.stopUpdatingLocation()
            event?.locationError(error: .userDeniedLocationService)
        default: break
        }
    }
}

extension LocationManagerWrapper: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager(didUpdateLocations: locations)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager(didFailWithError: error)
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        locationManagerDidChangeAuthorization()
    }
}

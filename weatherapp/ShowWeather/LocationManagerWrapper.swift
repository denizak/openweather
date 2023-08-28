//
//  LocationManager.swift
//  weatherapp
//
//  Created by Deni Zakya on 27/08/23.
//

import Foundation
import CoreLocation

final class LocationManagerWrapper {
    private var locationManager: LocationManager
    private let managerDelegate: LocationManagerDelegate

    init(
        locationManager: LocationManager = CLLocationManager(),
        managerDelegate: LocationManagerDelegate = CLLocationManagerDelegateImpl()
    ) {
        self.locationManager = locationManager
        self.managerDelegate = managerDelegate
        self.locationManager.locationManagerDelegate = managerDelegate
    }

    func start(with locationEvent: LocationEvent? = nil) {
        managerDelegate.event = locationEvent
        locationManager.startMonitoringSignificantLocationChanges() // low power location monitor
    }
}

final class CLLocationManagerDelegateImpl: NSObject, LocationManagerDelegate {
    weak var event: LocationEvent?
    
    func locationManagerDidChangeAuthorization(_ manager: LocationManager) {
        switch manager.authorizationStatus {
        case .notDetermined: manager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            event?.locationError(error: .userDeniedLocationService)
        default: manager.requestLocation()
        }
    }
    
    func locationManager(_ manager: LocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            event?.locationUpdated(
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude
            )
        }
    }
    
    func locationManager(_ manager: LocationManager, didFailWithError error: Error) {
        let errorCode = (error as? CLError)?.code
        switch errorCode {
        case .denied:
            manager.stopUpdatingLocation()
            event?.locationError(error: .userDeniedLocationService)
        default: break
        }
    }
}

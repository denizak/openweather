//
//  LocationManagerWrapper.swift
//  weatherapp
//
//  Created by Deni Zakya on 27/08/23.
//

import Foundation
import CoreLocation

protocol LocationManager {
    var locationManagerDelegate: LocationManagerDelegate? { get set }
    var authorizationStatus: CLAuthorizationStatus { get }
    func startMonitoringSignificantLocationChanges()
    func requestWhenInUseAuthorization()
    func requestLocation()
    func stopUpdatingLocation()
}

protocol LocationManagerDelegate: AnyObject {
    var event: LocationEvent? { get set }
    func locationManagerDidChangeAuthorization(_ manager: LocationManager)
    func locationManager(_ manager: LocationManager, didUpdateLocations locations: [CLLocation])
    func locationManager(_ manager: LocationManager, didFailWithError error: Error)
}

extension CLLocationManager: LocationManager {
    var locationManagerDelegate: LocationManagerDelegate? {
        get { return delegate as? LocationManagerDelegate }
        set { delegate = newValue as? CLLocationManagerDelegate }
    }
}

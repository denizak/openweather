//
//  Location.swift
//  weatherapp
//
//  Created by Deni Zakya on 30/08/23.
//

import Foundation

enum LocationError {
    case userDeniedLocationService
}

protocol LocationEvent: AnyObject {
    func locationUpdated(latitude: Double, longitude: Double)
    func locationError(error: LocationError)
}

struct Location {
    let city: String
    let state: String?
    let country: String
    let coordinate: Coordinate
}

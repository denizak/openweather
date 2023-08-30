//
//  WeatherInfo.swift
//  weatherapp
//
//  Created by Deni Zakya on 30/08/23.
//

import Foundation

struct WeatherInfo: Equatable {
    let city: String
    let country: String
    let temperature: Double
    let unit: Units
    let coordinate: Coordinate
}

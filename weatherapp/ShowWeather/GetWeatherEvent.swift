//
//  GetWeatherEvent.swift
//  weatherapp
//
//  Created by Deni Zakya on 30/08/23.
//

import Foundation

enum GetWeatherEvent: Equatable {
    enum WeatherError: Error {
        case missingData
    }

    case actualWeather(WeatherInfo)
    case unableToLocateUser
    case getWeatherError(WeatherError)
}

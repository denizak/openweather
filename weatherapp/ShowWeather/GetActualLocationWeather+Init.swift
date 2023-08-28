//
//  GetActualLocationWeather+Init.swift
//  weatherapp
//
//  Created by deni zakya on 28/08/23.
//

import Foundation

extension GetActualLocationWeather {
    static func make() -> GetActualLocationWeather {
        let locationManager = LocationManagerWrapper()
        let openWeatherRequester = OpenWeatherRequester()

        return .init(fetchLocation: { event in
            locationManager.start(with: event)
        }, requestWeatherInfo: { coordinate, unit in
            let response = try await openWeatherRequester.getWeather(coordinate: coordinate, unit: unit)
            return response?.toWeatherInfo(unit: unit)
        })
    }
}

extension WeatherResponse {
    func toWeatherInfo(unit: Units) -> WeatherInfo {
        .init(name: name, temperature: main.temp, unit: unit)
    }
}

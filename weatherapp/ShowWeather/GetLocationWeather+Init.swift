//
//  GetLocationWeather+Init.swift
//  weatherapp
//
//  Created by Deni Zakya on 30/08/23.
//

import Foundation

extension GetLocationWeather {
    static func make() -> GetLocationWeather {
        let openWeatherRequester = OpenWeatherRequester()
        return .init(requestWeatherInfo: { coordinate, unit in
            let response = try await openWeatherRequester.getWeather(coordinate: coordinate, unit: unit)
            return response?.toWeatherInfo(unit: unit)
        }, getActualLocationWeather: GetActualLocationWeather.make())
    }
}

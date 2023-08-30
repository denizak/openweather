//
//  GetLocationWeather.swift
//  weatherapp
//
//  Created by Deni Zakya on 30/08/23.
//

import Foundation

protocol GetLocationWeatherProtocol {
    var eventUpdate: (GetWeatherEvent) -> Void { get set }
    func fetch(unit: Units, coordinate: Coordinate?)
}

final class GetLocationWeather: GetLocationWeatherProtocol {
    var eventUpdate: (GetWeatherEvent) -> Void = { _ in }

    private var unit: Units = .metric

    private var getActualLocationWeather: GetLocationWeatherProtocol
    private var requestWeatherInfo: (Coordinate, Units) async throws -> WeatherInfo?

    init(
        requestWeatherInfo: @escaping (Coordinate, Units) async throws -> WeatherInfo?,
        getActualLocationWeather: GetLocationWeatherProtocol
    ) {
        self.getActualLocationWeather = getActualLocationWeather
        self.requestWeatherInfo = requestWeatherInfo
        
        self.getActualLocationWeather.eventUpdate = { [weak self] event in
            self?.eventUpdate(event)
        }
    }

    func fetch(unit: Units, coordinate: Coordinate?) {
        self.unit = unit

        if let location = coordinate {
            requestWeatherInfo(coordinate: location, unit: unit)
        } else {
            getActualLocationWeather.fetch(unit: unit, coordinate: nil)
        }
    }

    private func requestWeatherInfo(coordinate: Coordinate, unit: Units) {
        Task {
            do {
                if let weatherInfo = try await requestWeatherInfo(coordinate, unit) {
                    eventUpdate(.actualWeather(weatherInfo))
                } else {
                    eventUpdate(.getWeatherError(GetWeatherEvent.WeatherError.missingData))
                }
            } catch {
                eventUpdate(.getWeatherError(GetWeatherEvent.WeatherError.missingData))
                print(error)
            }
        }
    }
}

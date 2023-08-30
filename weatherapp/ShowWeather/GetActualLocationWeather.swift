//
//  GetActualLocationWeather.swift
//  weatherapp
//
//  Created by deni zakya on 28/08/23.
//

import Foundation

final class GetActualLocationWeather: GetLocationWeatherProtocol {
    var eventUpdate: (GetWeatherEvent) -> Void = { _ in }

    private var unit: Units = .metric

    private var fetchLocation: (LocationEvent) -> Void
    private var lastLocation: () -> Coordinate?
    private var requestWeatherInfo: (Coordinate, Units) async throws -> WeatherInfo?

    init(fetchLocation: @escaping (LocationEvent) -> Void,
         lastLocation: @escaping () -> Coordinate?,
         requestWeatherInfo: @escaping (Coordinate, Units) async throws -> WeatherInfo?) {
        self.fetchLocation = fetchLocation
        self.lastLocation = lastLocation
        self.requestWeatherInfo = requestWeatherInfo
    }

    func fetch(unit: Units, coordinate _: Coordinate?) {
        self.unit = unit

        let weatherLocation = lastLocation()
        if let location = weatherLocation {
            requestWeatherInfo(coordinate: location, unit: unit)
        } else {
            fetchLocation(self)
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

extension GetActualLocationWeather: LocationEvent {
    func locationUpdated(latitude: Double, longitude: Double) {
        requestWeatherInfo(coordinate: .init(lat: latitude, long: longitude), unit: self.unit)
    }

    func locationError(error: LocationError) {
        eventUpdate(.unableToLocateUser)
        print(error)
    }
}

//
//  GetActualLocationWeather.swift
//  weatherapp
//
//  Created by deni zakya on 28/08/23.
//

import Foundation

final class GetActualLocationWeather {
    var eventUpdate: (GetWeatherEvent) -> Void = { _ in }

    private var unit: Units = .metric

    private var fetchLocation: (LocationEvent) -> Void
    private var requestWeatherInfo: (Coordinate, Units) async throws -> WeatherInfo?

    init(fetchLocation: @escaping (LocationEvent) -> Void, requestWeatherInfo: @escaping (Coordinate, Units) async throws -> WeatherInfo?) {
        self.fetchLocation = fetchLocation
        self.requestWeatherInfo = requestWeatherInfo
    }

    func fetch(unit: Units) {
        self.unit = unit
        fetchLocation(self)
    }
}

extension GetActualLocationWeather: LocationEvent {
    func locationUpdated(latitude: Double, longitude: Double) {
        Task {
            do {
                if let weatherInfo = try await requestWeatherInfo(.init(lat: latitude, long: longitude), unit) {
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

    func locationError(error: LocationError) {
        eventUpdate(.unableToLocateUser)
        print(error)
    }
}

struct WeatherInfo: Equatable {
    let name: String
    let temperature: Double
    let unit: Units
}

enum GetWeatherEvent: Equatable {
    enum WeatherError: Error {
        case missingData
    }

    case actualWeather(WeatherInfo)
    case unableToLocateUser
    case getWeatherError(WeatherError)
}

struct Coordinate {
    let lat: Double
    let long: Double
}

enum Units: String {
    case metric
    case imperial
}

enum LocationError {
    case userDeniedLocationService
}

protocol LocationEvent: AnyObject {
    func locationUpdated(latitude: Double, longitude: Double)
    func locationError(error: LocationError)
}

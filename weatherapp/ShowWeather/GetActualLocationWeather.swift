//
//  GetActualLocationWeather.swift
//  weatherapp
//
//  Created by deni zakya on 28/08/23.
//

import Foundation

protocol GetActualLocationWeatherProtocol {
    var eventUpdate: (GetWeatherEvent) -> Void { get set }
    func fetch(unit: Units)
    func fetch(unit: Units, coordinate: Coordinate?)
}

final class GetActualLocationWeather: GetActualLocationWeatherProtocol {
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

    func fetch(unit: Units) {
        fetch(unit: unit, coordinate: nil)
    }

    func fetch(unit: Units, coordinate: Coordinate?) {
        self.unit = unit

        let weatherLocation = coordinate ?? lastLocation()
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

struct WeatherInfo: Equatable {
    let city: String
    let country: String
    let temperature: Double
    let unit: Units
    let coordinate: Coordinate
}

enum GetWeatherEvent: Equatable {
    enum WeatherError: Error {
        case missingData
    }

    case actualWeather(WeatherInfo)
    case unableToLocateUser
    case getWeatherError(WeatherError)
}

struct Coordinate: Equatable {
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

struct Location {
    let city: String
    let state: String?
    let country: String
    let coordinate: Coordinate
}

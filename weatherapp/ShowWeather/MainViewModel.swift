//
//  MainViewModel.swift
//  weatherapp
//
//  Created by deni zakya on 28/08/23.
//

import Foundation
import Combine

final class MainViewModel {

    private let temperatureSubject = PassthroughSubject<String, Never>()
    var temperature: AnyPublisher<String, Never> {
        temperatureSubject.eraseToAnyPublisher()
    }

    private let citySubject = PassthroughSubject<String, Never>()
    var name: AnyPublisher<String, Never> {
        citySubject.eraseToAnyPublisher()
    }

    private let showEnableLocationPermissionSubject = PassthroughSubject<Bool, Never>()
    var showEnableLocationPermission: AnyPublisher<Bool, Never> {
        showEnableLocationPermissionSubject.eraseToAnyPublisher()
    }

    private let showWeatherUnavailableSubject = PassthroughSubject<Bool, Never>()
    var showWeatherUnavailable: AnyPublisher<Bool, Never> {
        showWeatherUnavailableSubject.eraseToAnyPublisher()
    }
    
    private let showLoadingSubject = PassthroughSubject<Bool, Never>()
    var showLoading: AnyPublisher<Bool, Never> {
        showLoadingSubject.eraseToAnyPublisher()
    }

    private var location: Location?
    private var unit: Units = .metric

    private var getWeather: GetActualLocationWeatherProtocol
    init(getWeather: GetActualLocationWeatherProtocol) {
        self.getWeather = getWeather
        self.getWeather.eventUpdate = { [weak self] event in
            var showEnableLocationPermission = false
            var showError = false

            switch event {
            case .actualWeather(let info):
                self?.location = info.toLocation()
                self?.temperatureSubject.send("\(info.temperature)")
                self?.citySubject.send("\(info.city)")
            case .getWeatherError(let error):
                print(error)
                showError = true
            case .unableToLocateUser:
                showEnableLocationPermission = true
            }

            self?.showWeatherUnavailableSubject.send(showError)
            self?.showEnableLocationPermissionSubject.send(showEnableLocationPermission)
            self?.showLoadingSubject.send(false)
        }
    }

    func viewLoad() {
        updateWeather()
    }

    func update(location: Location, unit: Units) {
        self.location = location
        self.unit = unit
        updateWeather()
    }

    func update(unit: Units) {
        self.unit = unit
        updateWeather()
    }

    private func updateWeather() {
        showLoadingSubject.send(true)
        if let coordinate = location?.coordinate {
            getWeather.fetch(unit: unit, coordinate: coordinate)
        } else {
            getWeather.fetch(unit: unit)
        }

    }
}

extension WeatherInfo {
    func toLocation() -> Location {
        .init(city: city, state: nil, country: country, coordinate: coordinate)
    }
}

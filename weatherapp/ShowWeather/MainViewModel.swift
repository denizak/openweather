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

    private let nameSubject = PassthroughSubject<String, Never>()
    var name: AnyPublisher<String, Never> {
        nameSubject.eraseToAnyPublisher()
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

    private var getWeather: GetActualLocationWeatherProtocol
    init(getWeather: GetActualLocationWeatherProtocol) {
        self.getWeather = getWeather
        self.getWeather.eventUpdate = { [weak self] event in
            var showEnableLocationPermission = false
            var showError = false

            switch event {
            case .actualWeather(let info):
                self?.temperatureSubject.send("\(info.temperature)")
                self?.nameSubject.send("\(info.name)")
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

    func viewAppear(selectedUnit: Units = .metric) {
        showLoadingSubject.send(true)
        getWeather.fetch(unit: selectedUnit)
    }

    func update(unit: Units) {
        showLoadingSubject.send(true)
        getWeather.fetch(unit: unit)
    }
}

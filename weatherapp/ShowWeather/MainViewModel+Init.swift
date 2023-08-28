//
//  MainViewModel+Init.swift
//  weatherapp
//
//  Created by deni zakya on 28/08/23.
//

import Foundation

extension MainViewModel {
    static func make() -> MainViewModel {
        .init(getWeather: GetActualLocationWeather.make())
    }
}

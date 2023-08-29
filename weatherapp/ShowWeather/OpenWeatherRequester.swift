//
//  OpenWeatherRequester.swift
//  weatherapp
//
//  Created by Deni Zakya on 27/08/23.
//

import Foundation

struct WeatherResponse: Decodable {
    struct Main: Decodable {
        let temp: Double
    }
    
    let main: Main
    let name: String
}

struct OpenWeatherRequester {
    private let decoder = JSONDecoder()

    func getWeather(coordinate: Coordinate, unit: Units = .metric) async throws -> WeatherResponse? {
        let path = "/data/2.5/weather"
        let params = [
            "lat": "\(coordinate.lat)",
            "lon": "\(coordinate.long)",
            "units": unit.rawValue
        ]
        if let url = API.makeURL(path: path, params: params) {
            let (data, _) = try await URLSession.shared.data(from: url)
            return try decoder.decode(WeatherResponse.self, from: data)
        } else {
            return nil
        }
    }
}

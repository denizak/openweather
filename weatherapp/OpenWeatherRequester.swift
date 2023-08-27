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
    private let host = "api.openweathermap.org"
    private let appid = "8873455a2cc5af0232f9657dc50c4083"
    private let decoder = JSONDecoder()

    struct Coordinate {
        let lat: Double
        let long: Double
    }

    func getWeather(coordinate: Coordinate) async throws -> WeatherResponse? {
        let path = "/data/2.5/weather"
        let params = [
            "lat": "\(coordinate.lat)",
            "lon": "\(coordinate.long)",
            "appid": appid
        ]
        if let url = makeURL(path: path, params: params) {
            let (data, _) = try await URLSession.shared.data(from: url)
            return try decoder.decode(WeatherResponse.self, from: data)
        } else {
            return nil
        }
    }
    
    private func makeURL(path: String, params: [String: String]) -> URL? {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = host
        urlComponents.path = path
        urlComponents.queryItems = params.map { key, value in
            URLQueryItem(name: key, value: value)
        }
        return urlComponents.url
    }
}

//
//  APIURL.swift
//  weatherapp
//
//  Created by deni zakya on 29/08/23.
//

import Foundation

struct API {
    private static let host = "api.openweathermap.org"
    private static let appid = "8873455a2cc5af0232f9657dc50c4083"

    static func makeURL(path: String, params: [String: String]) -> URL? {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = API.host
        urlComponents.path = path
        urlComponents.queryItems = params.map { key, value in
            URLQueryItem(name: key, value: value)
        } + [URLQueryItem(name: "appid", value: API.appid)]
        return urlComponents.url
    }
}

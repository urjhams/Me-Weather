//
//  Constants.swift
//  viewtTesting
//
//  Created by urjhams on 3/8/18.
//  Copyright © 2018 urjhams. All rights reserved.
//

import Foundation

struct Constants {
    struct DarkSkyApi {
        static let baseUrl = "https://api.darksky.net/forecast/"
        static let secrectKey = "801a76a9a0cda6c36172a77a32361ed4"
        static let currentlyKey = "currently"
        static let hourlyKey = "hourly"
    }
    struct CityLocateApi {
        static let baseUrl = "https://raw.githubusercontent.com/lutangar/cities.json/master/cities.json"
    }
}

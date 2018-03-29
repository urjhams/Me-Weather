//
//  CityLocation.swift
//  viewtTesting
//
//  Created by urjhams on 3/9/18.
//  Copyright © 2018 urjhams. All rights reserved.
//

import Foundation

struct CityLocation {
    public let country: String
    public let name: String
    public let latitude: String
    public let longtitude: String
    
    init?(withData data: NSDictionary) {
        guard
            let country = data.string(forKeyPath: "country"),
            let name = data.string(forKeyPath: "name"),
            let latitude = data.string(forKeyPath: "lat"),
            let longtitude = data.string(forKeyPath: "lng")
        else {
            return nil
        }
        self.country = country
        self.name = name
        self.latitude = latitude
        self.longtitude = longtitude
    }
}

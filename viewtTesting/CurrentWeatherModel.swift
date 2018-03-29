//
//  CurrentWeatherModel.swift
//  viewtTesting
//
//  Created by urjhams on 3/8/18.
//  Copyright © 2018 urjhams. All rights reserved.
//

import Foundation

struct CurrentWeatherModel {
    public let temp: Double         // nhiệt độ (F) (- 32)/1.8
    public let windSpd: Double      // tốc độ gió
    public let humidity: Double     // độ ẩm
    public let cloud: Double        // độ che phủ mây
    public let icon: String         // tổng quan (for icon)
    public let visibility: Double    // tầm nhìn xa (km)
    public let pressure: Double     // áp lực
    
    init?(withData data: NSDictionary) {
        guard
            let temp = data.double(forKeyPath: "temperature"),
            let windSpd = data.double(forKeyPath: "windSpeed"),
            let humidity = data.double(forKeyPath: "humidity"),
            let cloud = data.double(forKeyPath: "cloudCover"),
            let icon = data.string(forKeyPath: "icon"),
            let visibility = data.exactlyDouble(forKeyPath: "visibility"),
            let pressure = data.double(forKeyPath: "pressure")
            else {
                return nil
        }
        self.temp = temp
        self.windSpd = windSpd
        self.humidity = humidity
        self.cloud = cloud
        self.icon = icon
        self.visibility = visibility
        self.pressure = pressure
    }
}

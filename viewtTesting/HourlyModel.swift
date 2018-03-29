//
//  HourlyModel.swift
//  viewtTesting
//
//  Created by urjhams on 3/8/18.
//  Copyright © 2018 urjhams. All rights reserved.
//

import Foundation

struct HourlyModel {
    public let temp: Double
    public let icon: String
    public let time: Int64
    
    init?(withData data: NSDictionary) {
        guard
            let temp = data.double(forKeyPath: "temperature"),
            let icon = data.string(forKeyPath: "icon"),
            let time = data.int64(forKeyPath: "time")
            else {
                return nil
        }
        self.temp = temp
        self.icon = icon
        self.time = time
    }
}

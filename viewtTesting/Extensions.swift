//
//  Extensions.swift
//  viewtTesting
//
//  Created by urjhams on 3/7/18.
//  Copyright © 2018 urjhams. All rights reserved.
//

import Foundation

extension NSDictionary {
    func double(forKeyPath keyPath: String) -> Double? {
        return value(forKeyPath: keyPath) as? Double
    }
    func int64(forKeyPath keyPath: String) -> Int64? {
        return value(forKeyPath: keyPath) as? Int64
    }
    func string(forKeyPath keyPath: String) -> String? {
        return value(forKeyPath: keyPath) as? String
    }
    func exactlyDouble(forKeyPath keyPath: String) -> Double? {
        return value(forKey: keyPath) as? Double ?? 0
    }
}

extension Date {
    var yesterday: Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: noon)!
    }
    var tomorrow: Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: noon)!
    }
    var noon: Date {
        return Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: self)!
    }
    var month: Int {
        return Calendar.current.component(.month,  from: self)
    }
    var isLastDayOfMonth: Bool {
        return tomorrow.month != month
    }
}

//-------------------------- public funcs
public func convertToDate(fromTimeStamp timeStamp: Int64) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "HH"
    if timeStamp == 0 {
        return ""
    } else {
        let time = Int(truncating: timeStamp as NSNumber)
        return formatter.string(from: Date(timeIntervalSince1970: TimeInterval(time)))
    }
}

public func convertToC(fromF f: Double) -> Double {
    return (f - 32) / 1.8
}
public func convertToF(fromC c: Double) -> Double {
    return c * 1.8 + 32
}


//-------------------------- public var
public enum TempType {
    case F
    case C
}

// at first time, if there isnt the stored value yet, it return false
public var currentTempMode: TempType = UserDefaults.standard.bool(forKey: "isCelcius") ? .C : .F



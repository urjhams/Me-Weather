//
//  HourlyCollectionViewCell.swift
//  viewtTesting
//
//  Created by urjhams on 3/8/18.
//  Copyright © 2018 urjhams. All rights reserved.
//

import UIKit

class HourlyCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var tempLabel: UILabel!
    var hourlyUnit:HourlyModel? {
        didSet {
            if let unit = hourlyUnit {
                timeLabel.text = convertToDate(fromTimeStamp: unit.time)
                tempLabel.text = String(Int(currentTempMode == .F ? unit.temp : convertToC(fromF: unit.temp))) + "º" + (currentTempMode == .F ? " F" : " C")
                iconImage.image = UIImage(named: unit.icon + "-icon")
            }
        }
    }
}

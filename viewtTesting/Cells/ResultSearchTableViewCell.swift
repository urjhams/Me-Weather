//
//  ResultSearchTableViewCell.swift
//  viewtTesting
//
//  Created by urjhams on 3/9/18.
//  Copyright © 2018 urjhams. All rights reserved.
//

import UIKit

class ResultSearchTableViewCell: UITableViewCell {
    @IBOutlet weak var contentLabel: UILabel!
    var lat: Double?
    var long: Double?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

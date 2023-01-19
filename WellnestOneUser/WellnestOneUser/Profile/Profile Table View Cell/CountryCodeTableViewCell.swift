//
//  CountryCodeTableViewCell.swift
//  Wellnest Technician
//
//  Created by Mayank Verma on 10/02/21.
//  Copyright © 2021 Wellnest Inc. All rights reserved.
//

import UIKit
import SDWebImage

class CountryCodeTableViewCell: UITableViewCell {

    @IBOutlet weak var imageViewCountry: UIImageView!
    @IBOutlet weak var lblCountryName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func setUpCell(countryCode: String, countryName: String) {
        self.lblCountryName.text = countryName
        self.imageViewCountry.layer.cornerRadius = self.imageViewCountry.frame.height / 2
        self.imageViewCountry.contentMode = .scaleAspectFill
        self.imageViewCountry.sd_setImage(with: URL.init(string: "https://flagcdn.com/h80/\(countryCode.lowercased()).png"))
    }
    
}

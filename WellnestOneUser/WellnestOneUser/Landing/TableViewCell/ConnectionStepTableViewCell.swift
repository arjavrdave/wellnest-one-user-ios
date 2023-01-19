//
//  ConnectionStepTableViewCell.swift
//  Wellnest Technician
//
//  Created by Nihar Jagad on 01/11/22.
//  Copyright © 2022 Wellnest Inc. All rights reserved.
//

import UIKit

class ConnectionStepTableViewCell: UITableViewCell {

    @IBOutlet weak var imageCheck: UIImageView!
    @IBOutlet weak var lblStepTitle: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func setupCell(stepTitle: String, isStepSelected: Bool) {
        self.lblStepTitle.text = stepTitle
        if isStepSelected {
            self.lblStepTitle.textColor = UIColor.black
            self.imageCheck.image = UIImage(named: "Green_check_icon")
        } else {
            self.lblStepTitle.textColor = UIColor.darkGray
            self.imageCheck.image = UIImage(named: "Deactivate_check_icon")
        }
    }
    
    

}

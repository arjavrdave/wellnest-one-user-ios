//
//  BluetoothPairTableViewCell.swift
//  Wellnest Technician
//
//  Created by Mayank Verma on 26/10/20.
//  Copyright © 2020 Wellnest Inc. All rights reserved.
//

import UIKit
import WellnestBLE

protocol DeviceSelectProtocol : class {
    func didSelectPeripheral(peripheral : WellnestPeripheral?)
}

class BluetoothPairTableViewCell: UITableViewCell {

    @IBOutlet weak var lblBluetoothName: UILabel!
    @IBOutlet weak var btnPair: UIButton!
    
    var peripheral: WellnestPeripheral?
    
    weak var delegate: DeviceSelectProtocol?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.btnPair.layer.cornerRadius = self.btnPair.frame.height / 2
    }

    @IBAction func btnPairTapped(_ sender: UIButton) {
        self.btnPair.isEnabled = false;
        if let d = self.delegate {
            d.didSelectPeripheral(peripheral: self.peripheral)
        }
    }
}

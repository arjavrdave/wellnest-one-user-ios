//
//  RecordingsTableViewCell.swift
//  Wellnest Technician
//
//  Created by Mayank Verma on 04/06/20.
//  Copyright © 2020 Wellnest Inc. All rights reserved.
//

import UIKit

class RecordingsTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var imagePatient: UIImageView!
    @IBOutlet weak var lblPatientName: UILabel!
    @IBOutlet weak var lblReasons: UILabel!
    @IBOutlet weak var lblBPM: UILabel!
    @IBOutlet weak var lblRecordingStatus: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setupCell(recording: Recordings) {
        
        self.imagePatient.contentMode = .scaleAspectFill
        self.imagePatient.layer.cornerRadius = self.imagePatient.frame.height / 2
        if let imgData = recording.patientImage {
            self.imagePatient.image = UIImage.init(data: imgData)
        }
        else {
            let imageURL = URL.init(string: AzureUtil.shared.getProfileImageURL(id: recording.patient?.profileId ?? "", sasToken: SASTokenPublicRead))
            self.imagePatient.sd_setImage(with: imageURL, placeholderImage: UIImage.init(named: "ic_user"), completed: nil)
        }
        self.lblPatientName.text = recording.patient?.fullName
        self.lblReasons.text = (recording.reason?.isEmpty == false) ? recording.reason : "No Indication"
        self.lblBPM.text = "BPM " + String(recording.bpm ?? 0)
        self.lblDate.text = recording.displayDate
        
        if (recording.reviewStatus?.lowercased() == "feedbackgiven") {
            self.lblRecordingStatus.text = "Analysis Received"
            self.lblRecordingStatus.textColor = UIColor.colorAnalysisReceived
        } else if recording.forwarded == true {
            self.lblRecordingStatus.text = "Sent for Analysis"
            self.lblRecordingStatus.textColor = UIColor.colorSendForAnalysis
        } else {
            self.lblRecordingStatus.text = "Recording Complete"
            self.lblRecordingStatus.textColor = UIColor.colorRecordingComplete
        }
        
    }
    
}

//
//  RecordingPreviewViewController.swift
//  WellnestOneUser
//
//  Created by Nihar Jagad on 23/11/22.
//

import UIKit
import SwinjectStoryboard
import WellnestBLE
class RecordingPreviewViewController: UIParentViewController, UIScrollViewDelegate {

    var recording: IRecordings?
    var storage: IStorage?
    var patient: IPatient?
    @IBOutlet var viewCharts: [ViewWithGraph]!
    @IBOutlet weak var hScrollView: UIScrollView!
    @IBOutlet weak var viewShareAndAnalysis: UIViewShadow!
    @IBOutlet weak var btnLinkReport: UIButton!
    @IBOutlet weak var lblTitle: UILabel!

    @IBOutlet weak var btnReTake: UIButton!
    @IBOutlet weak var btnShare: UIButton!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnCancel: UIButton!
    
    @IBOutlet weak var imageDoctorSign: UIImageView!
    
    @IBOutlet weak var btnECGAnalysis: UIButton!
    
    @IBOutlet weak var lblPatientName: UILabel!
    @IBOutlet weak var lblGenderAge: UILabel!
    @IBOutlet weak var lblTestDate: UILabel!
    @IBOutlet weak var lblReasons: UILabel!
    @IBOutlet weak var lblCondition: UILabel!
    @IBOutlet weak var lblHeartRate: UILabel!
    @IBOutlet weak var lblST: UILabel!
    @IBOutlet weak var lblQRS: UILabel!
    @IBOutlet weak var lblQT: UILabel!
    @IBOutlet weak var lblPR: UILabel!
    @IBOutlet weak var lblQTc: UILabel!
    @IBOutlet weak var lblECGFindings: UILabel!
    @IBOutlet weak var lblFindingsInterpretations: UILabel!
    @IBOutlet weak var lblRecommendations: UILabel!
    @IBOutlet weak var lblDoctorName: UILabel!
    @IBOutlet weak var lblQualification: UILabel!
    @IBOutlet weak var lblContactNumber: UILabel!
    
    @IBOutlet weak var sViewGengerAge: UIStackView!
    @IBOutlet weak var sViewCondition: UIStackView!
    @IBOutlet weak var sViewECGDetails: UIStackView!
    
    @IBOutlet weak var viewAddMember: UIView!
    @IBOutlet weak var viewDarkBkg: UIView!
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtAge: UITextField!
    @IBOutlet weak var txtPhoneNo: UITextField!
    @IBOutlet weak var segmentGender: UISegmentedControl!
    @IBOutlet weak var btnSave: UIButton!
    
    @IBOutlet weak var constBottomBtnHeight: NSLayoutConstraint!
    @IBOutlet weak var constHeightSignatureView: NSLayoutConstraint!
    
    var selectedGender = "Male"
    
    var stagesOfInformation: Int = 0
    var currentLoadedStages: Int = 0 {
        didSet {
            if self.currentLoadedStages == self.stagesOfInformation {
                DispatchQueue.main.async {
                    UILoader.stopAnimating()
                    self.pdfPath = PDFGenerator().getPDfPath(user: self.patient as! Patient, recording: self.recording as! Recordings, signatureImage: self.imageDoctorSign.image, reportedBy: self.recording?.reportedBy)
                    if self.pageType != .recordingCompleted {
                        self.btnShare.isHidden = false
                    }
                }
            }
        }
    }
    //Max three stage
    //1) QRS LOADING
    //2) RECORDING DATA LOADING
    //3) SIGNATURE LOADING
    var pageType: RecordingPreviewPageType = .withoutPatient
    var presenter: RecordingPreviewPresenter?
    var communicationHandler: CommunicationProtocol = CommunicationModule.getCommunicationHandler()
    private var pdfPath: String?
    var sasTokenForReadSignature = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        self.presenter = RecordingPreviewPresenter(viewController: self)
        self.hScrollView.delegate = self
        
        self.viewAddMember.isHidden = true
        self.viewDarkBkg.isHidden = true
        self.viewAddMember.layer.cornerRadius = 10
        
        self.btnShare.isHidden = true
        DispatchQueue.main.async {
            UILoader.startAnimating()
        }
        if pageType == .withoutPatient {
            self.setupAddMemberView()
            
            self.stagesOfInformation = 2
            self.sViewGengerAge.isHidden = true
            self.sViewCondition.isHidden = true
            self.sViewECGDetails.isHidden = true
            
            self.btnBack.isHidden = true
            
            self.lblPatientName.isHidden = true
            self.viewShareAndAnalysis.isHidden = true
            self.btnLinkReport.isHidden = false
            if self.recording?.fileName == "" || self.recording?.fileName == nil {
                let recordingName = UUID().uuidString
                self.recording?.fileName = recordingName
            }
            self.storage?.fileName = self.recording?.fileName
            self.presenter?.getUploadTokenForRecording(storage: self.storage, recording: self.recording)
            updateUIBy(recording: self.recording as! Recordings)
            
        } else if pageType == .recordingCompleted {
            self.stagesOfInformation = 2
            self.sViewCondition.isHidden = true
            self.sViewECGDetails.isHidden = true
            
            self.btnECGAnalysis.layer.cornerRadius = self.btnECGAnalysis.layer.frame.height / 2
            self.viewShareAndAnalysis.isHidden = false
            self.viewShareAndAnalysis.layer.shadowColor = UIColor.black.withAlphaComponent(0.29).cgColor
            self.btnLinkReport.isHidden = true
            
            self.btnReTake.isHidden = true
            self.btnBack.isHidden = true
            
            if recording?.recordingRawData == nil {
                self.presenter?.getRecordingForID(recording: self.recording)
            } else {
                updateUIBy(recording: self.recording as! Recordings)
                updateUIByUpdatedCreated(recording: self.recording as! Recordings)
            }
            
        } else if pageType == .sentForAnalysis {
            self.stagesOfInformation = 2
            self.sViewECGDetails.isHidden = true
            
            self.btnReTake.isHidden = true
            self.btnCancel.isHidden = true
            
            self.viewShareAndAnalysis.isHidden = false
            self.btnLinkReport.isHidden = false
            self.constBottomBtnHeight.constant = 0
            
            self.presenter?.getRecordingForID(recording: self.recording)
            
        } else if pageType == .analysisReceived {
            self.stagesOfInformation = 3
            self.viewShareAndAnalysis.isHidden = false
            self.btnLinkReport.isHidden = false
            self.constBottomBtnHeight.constant = 0
            
            self.btnReTake.isHidden = true
            self.btnCancel.isHidden = true
            
            self.presenter?.getRecordingForID(recording: self.recording)
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        self.presenter = RecordingPreviewPresenter(viewController: self)
    }
    override func viewDidDisappear(_ animated: Bool) {
        self.presenter = nil
    }
    @IBAction func btnRetake(_ sender: UIButton) {
        
        UIAlertUtil.alertWith(title: "RE-RECORD", message: "Do you want to get patient’s ECG re-recorded?", OkTitle: "Yes", cancelTitle: "No", viewController: self) { (index) in
            if index == 1 {
                if self.communicationHandler.isConnected() {
                    let stryB = SwinjectStoryboard.create(name: "Landing", bundle: Bundle.main, container: self.initialize.container)
                    let vc = stryB.instantiateViewController(withIdentifier: String.init(describing: PreRecordingConnectionViewController.self)) as! PreRecordingConnectionViewController
                    vc.recording = self.recording
                    vc.isReRecordFlow = true
                    self.navigationController?.pushViewController(vc, animated: true)
                } else {
                    let stryB = SwinjectStoryboard.create(name: "Landing", bundle: Bundle.main, container: self.initialize.container)
                    let vc = stryB.instantiateViewController(withIdentifier: String.init(describing: PairDeviceViewController.self)) as! PairDeviceViewController
                    vc.recording = self.recording
                    vc.isReRecordFlow = true
                    self.navigationController?.pushViewController(vc, animated: true)
                    
                }
            }
        }
    }
    @IBAction func btnShareTapped(_ sender: UIButton) {
        
        if FileManager.default.fileExists(atPath: self.pdfPath ?? ""){
            let controller = UIActivityViewController(activityItems: [URL.init(fileURLWithPath: self.pdfPath ?? "")], applicationActivities: nil)
            self.present(controller, animated: true) {
                print("done")
            }
        }
    }
    @IBAction func btnLinkReportTapped(_ sender: UIButton) {
        let stryB = SwinjectStoryboard.create(name: "Recording", bundle: Bundle.main, container: self.initialize.container)
        let vc = stryB.instantiateViewController(withIdentifier: String.init(describing: ChooseMemberViewController.self)) as! ChooseMemberViewController
        vc.recording = self.recording
        self.navigationController?.pushViewController(vc, animated: true)
//        self.viewAddMember.isHidden = false
//        self.viewDarkBkg.isHidden = false
    }
    @IBAction func genderChanged(_ sender: UISegmentedControl) {
        self.selectedGender = sender.titleForSegment(at: sender.selectedSegmentIndex) ?? "Male"
    }
    @IBAction func btnCloseTapped(_ sender: UIButton) {
        if self.pageType == .withoutPatient {
            UIAlertUtil.alertWithAction(title: "DISCARD ECG", message: "This ECG will not be saved and you will not be able to retrieve it in the future. In order to refer to the ECG later, please link patient profile.", buttonTitles: ["Link Patient","Discard ECG"], viewController: self) { (index) in
                if index == 0 {
                    
                } else if index == 1 {
                    self.viewDarkBkg.isHidden = false
                    self.viewAddMember.isHidden = false
                } else if index == 2 {
                    // Discard Recording
                    self.navigationController?.popViewController(animated: true)
                }
            }
        } else {
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    @IBAction func btnSaveTapped(_ sender: UIButton) {
        if self.txtName.text?.trim().isValidName() == false {
            UIAlertUtil.alertWith(title: "Alert", message: "Please enter valid First Name", viewController: self) { (_) in }
            return
        }
        if let arrayNames = self.txtName.text?.split(separator: " "), arrayNames.isEmpty != true {
            self.patient?.patientFirstName = String(arrayNames[0])
            if arrayNames.count > 1 {
                let lastNameString = arrayNames[1...].joined(separator: " ")
                self.patient?.patientLastName = lastNameString
            }
        }
        let age = Int(self.txtAge.text ?? "")
        let birthDate = Calendar.current.date(byAdding: .year, value: (0 - (age ?? 0)), to: Date())

        let formatter = DateFormatter.init()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        let dateString = formatter.string(from: birthDate!)
        self.patient?.patientDateOfBirth = dateString
        
        self.patient?.patientGender = self.selectedGender
        self.patient?.phoneNumber = self.txtPhoneNo.text
        self.presenter?.linkFamilyMember(patient: self.patient, recordingId: self.recording?.id ?? 0)
    }
    @IBAction func btncloseAddmemberView(_ sender: UIView) {
        self.viewAddMember.isHidden = true
        self.viewDarkBkg.isHidden = true
    }
    @IBAction func btnECGAnalysisTapped(_ sender: UIButton) {
        UIAlertUtil.alertWith(title: "GET ECG ANALYSIS", message: "The ECG will be shared with Wellnest’s board of trained physicians and cardiologists for review. You will receive a report within 20 minutes.", OkTitle: "Ok", cancelTitle: "Cancel", viewController: self) { (index) in
            if index == 1 {
                DispatchQueue.main.async {
                    UILoader.startAnimating()
                }
                self.presenter?.sendForFeedback(recording: self.recording)
            }
        }
    }
    func filterAndDisplayData() {
        if let data = self.recording?.recordingRawData {
            self.currentLoadedStages += 1
            let recordingData = data.parseData()
            var filteredData = Array.init(repeating: [Double](), count: 12)
            for i in 2..<recordingData[0].count {
                for index in 0..<recordingData.count {
                    let array = Array(recordingData[index][(i-2)...i])
                    let median = array.median()
                    filteredData[index].append(median)
                }
            }
            DispatchQueue.main.async {
                for chart in self.viewCharts {
                    if recordingData[chart.tag].count >= 2500 {
                        let (_,avgFilter,_) = ThresholdAlgo.shared.ThresholdingAlgo(y: recordingData[chart.tag], lag: 10, threshold: 3, influence: 0.2)
                        chart.inputWithData(data: Array(avgFilter))
                    } else {
                        chart.noDataText = "NO CHART DATA FOUND"
                    }
                }
                self.view.layoutIfNeeded()
            }
//            if let patient = self.patient as? Patient, let recording = self.recording as? Recordings {
//                self.pdfPath = PDFGenerator().getPDfPath(user: patient, recording: recording, signatureImage: self.imageDoctorSign.image, reportedBy: self.recording?.reportedBy)
//            }
        }
    }
    func updateUIbyUploadingError() {
        UIAlertUtil.alertWith(title: "Error", message: "We were not able to record your ECG. Please re-record.", OkTitle: "Ok", viewController: self) { result in
            self.navigationController?.popViewController(animated: true)
        }
    }
    func updateUIBy(recording: Recordings) {
        self.recording = recording
        
        self.lblPatientName.text = self.patient?.fullName
        self.lblGenderAge.text = "\(self.patient?.patientGender ?? self.recording?.patient?.patientGender ?? "Male") | \(self.patient?.age ?? self.recording?.patient?.age ?? 0) years"
        if pageType == .withoutPatient || pageType == .recordingCompleted {
            self.lblTitle.text = recording.displayDateForLanding
        } else {
            self.lblTitle.text = "ECG Report - \(self.patient?.fullName ?? "")"
        }
        self.lblTestDate.text = recording.displayDatewithTime
        self.lblReasons.text = (recording.reason?.isEmpty == false) ? recording.reason : "No Indication"
        
        if recording.risk?.lowercased() == CommonConfiguration.action_required_not_urgent.lowercased() {
            self.lblCondition.text = CommonConfiguration.action_required_not_urgent
            self.lblCondition.textColor = UIColor.colorActionReqNotUrgent
        } else if recording.risk?.lowercased() == CommonConfiguration.no_action_required.lowercased() {
            self.lblCondition.text = CommonConfiguration.no_action_required
            self.lblCondition.textColor = UIColor.colorNoAction
        } else if recording.risk?.lowercased() == CommonConfiguration.urgent_action_required.lowercased() {
            self.lblCondition.text = CommonConfiguration.urgent_action_required
            self.lblCondition.textColor = UIColor.colorUrgentActionReq
        } else if recording.risk == nil {
            self.lblCondition.text = ""
        }
        
        if pageType == .analysisReceived {
            if let ecgFindings = recording.ecgFindings, ecgFindings != "" {
                self.lblECGFindings.text = ecgFindings
            }else{
                self.lblECGFindings.text = "-"
            }
            if let interpretations = recording.interpretations, interpretations != "" {
                self.lblFindingsInterpretations.text = interpretations
            }else{
                self.lblFindingsInterpretations.text = "-"
            }
            if let recommendations = recording.recommendations, recommendations != "" {
                self.lblRecommendations.text = recommendations
            }else{
                self.lblRecommendations.text = "-"
            }
            if let _ = recording.reportedBy?.firstName {
                self.lblDoctorName.text = recording.reportedBy?.fullName
                self.lblQualification.text = recording.reportedBy?.qualification ?? ""
                self.lblContactNumber.text = "+\(recording.reportedBy?.countryCode ?? 91) " + (recording.reportedBy?.phoneNumber ?? "")
                self.storage?.id = recording.reportedBy?.id
                self.presenter?.getReadSignatureSASToken(storage: self.storage)
            } else {
                self.currentLoadedStages += 1
            }
        }
        self.filterAndDisplayData()
    }
    func getSignature() {
        
        let signatureURL = URL(string: AzureUtil.shared.getSignatureImageURL(id: self.recording?.reportedBy?.id ?? 0, sasToken: self.sasTokenForReadSignature))
        self.imageDoctorSign.sd_setImage(with: signatureURL) { (image, error, cache, url) in
            self.imageDoctorSign.isHidden = true
            if error == nil {
                if image != nil {
                    self.imageDoctorSign.isHidden = false
                    let image = image!.imageWithInsets(insets: UIEdgeInsets(top: 200, left: 0, bottom: 0, right: 0))
                    self.imageDoctorSign.image = image?.resizeImageTo(size: CGSize(width: 250, height: 150))
                    self.currentLoadedStages += 1
                } else {
                    self.currentLoadedStages += 1
                    self.constHeightSignatureView.constant = 0
                }
            } else {
                self.currentLoadedStages += 1
            }
        }
    }
    @IBAction func backButtonTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func calculateReportsTapped(_ sender: UIButton) {
        if let url = URL.init(string: "https://link.springer.com/article/10.3758/s13428-020-01516-y"), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
    func updateUIByUpdatedCreated(recording: Recordings) {
        self.currentLoadedStages += 1
        if pageType == .withoutPatient || pageType == .recordingCompleted {
            self.lblTitle.text = recording.displayDateForLanding
        } else {
            self.lblTitle.text = "ECG Report - \(self.patient?.fullName ?? "")"
        }
        self.recording?.displayDateForLanding = recording.displayDateForLanding
        self.recording?.id = recording.id
        self.recording?.qtc = recording.qtc
        self.recording?.pr = recording.pr
        self.recording?.qrs = recording.qrs
        self.recording?.st = recording.st
        self.recording?.qt = recording.qt
        self.recording?.bpm = recording.bpm
        self.recording?.createdAt = recording.createdAt
        self.lblTestDate.text = recording.displayDatewithTime
        self.lblQTc.text = "\(recording.qtc ?? 0.0) ms"
        self.lblPR.text = "\(recording.pr ?? 0.0) ms"
        self.lblQRS.text = "\(recording.qrs ?? 0.0) ms"
        self.lblST.text = "\(recording.st ?? 0.0) ms"
        self.lblQT.text = "\(recording.qt ?? 0.0) ms"
        self.lblHeartRate.text = String(recording.bpm ?? 0) + " bpm"
//        if let patient = self.patient as? Patient, let recording = self.recording as? Recordings {
//            self.pdfPath = PDFGenerator().getPDfPath(user: patient, recording: recording, signatureImage: self.imageDoctorSign.image, reportedBy: self.recording?.reportedBy)
//        }
        self.view.layoutIfNeeded()
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        for charts in viewCharts {
            charts.moveLabel(offset: scrollView.contentOffset.x)
        }
    }
    func setupAddMemberView() {
        
        segmentGender.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        segmentGender.setTitleTextAttributes([.foregroundColor: UIColor.black], for: .normal)
        self.txtAge.delegate = self
        self.txtPhoneNo.delegate = self
        self.txtName.delegate = self
        
        
        
    }
    func updateUIByLinkMemberSuccess() {
        let storyB = SwinjectStoryboard.create(name: "Recording", bundle: nil, container: self.initialize.container)
        let vc = storyB.instantiateViewController(withIdentifier: String(describing: RecordingPreviewViewController.self)) as! RecordingPreviewViewController
        vc.recording = self.recording
        vc.pageType = .recordingCompleted
        vc.patient = self.patient
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func updateUIBySendForAnalysis() {
        DispatchQueue.main.async {
            UILoader.stopAnimating()
        }
        self.storage?.fileName = "\(self.recording?.fileName ?? "").pdf"
        self.storage?.getUploadTokenForECG(completion: { storage, error in
            if error == nil, let st = storage{
                if let pdfPath = self.pdfPath {
                    if FileManager.default.fileExists(atPath: pdfPath){
                        let pdfDocument = NSData(contentsOfFile: pdfPath)!
                        let pdfData = Data(referencing: pdfDocument)
                        AzureUtil.shared.saveToECGRRecordingContainer(uuid: "\(self.recording?.fileName ?? "").pdf", sasToken: st.sasToken!, recordingData: pdfData, contentType: "application/pdf") { (error) in
                            print("error")
                        }
                    }
                }
            }
        })
        UISuccessLoader.startAnimatingWith(message: "ECG Recording\nSent for Reporting!")
        let deadlineTime = DispatchTime.now() + .milliseconds(3600)
        DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
            let storyboard = SwinjectStoryboard.create(name: "Landing", bundle: Bundle.main, container: self.initialize.container)
            let vc = storyboard.instantiateViewController(withIdentifier: String.init(describing: HomeViewController.self)) as! HomeViewController
            self.navigationController?.setViewControllers([vc], animated: true)
        }
    }
}
extension RecordingPreviewViewController: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if (txtName.text != nil && txtName.text!.trim().count > 0) && (txtAge.text != nil && txtAge.text!.trim().count > 0) {
            self.btnSave.backgroundColor = UIColor.colorGreen
            self.btnSave.isUserInteractionEnabled = true
        } else {
            self.btnSave.backgroundColor = UIColor.colorButton
            self.btnSave.isUserInteractionEnabled = false
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == self.txtPhoneNo || textField == txtAge {
            if let text = textField.text, let textRange = Range(range, in: text) {
                let fullString = text.replacingCharacters(in: textRange, with: string)
                let allowedChars = CharacterSet(charactersIn: "0123456789").inverted
                if fullString.rangeOfCharacter(from: allowedChars) == nil {
                    let maxLength = textField == self.txtPhoneNo ? 13 : 3
                    if fullString.numbersOnly().isLessThan(maxLength: maxLength) {
                        textField.text = fullString
                    }
                }
                return false
            }
        }
        return true
    }
}

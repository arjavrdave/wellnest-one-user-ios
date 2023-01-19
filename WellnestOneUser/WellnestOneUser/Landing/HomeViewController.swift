//
//  HomeViewController.swift
//  Dev
//
//  Created by Nihar Jagad on 17/11/22.
//

import UIKit
import SwinjectStoryboard
import WellnestBLE
class HomeViewController: UIParentViewController {
    var recording: IRecordings?
    var storage: IStorage?
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var txtFSearch: UITextField!
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var btnSearch: UIButton!
    var refreshControl = UIRefreshControl()
    
    private var presenter: HomeViewPresenter?
    private var tableViewData = [Recordings]()
    private var searchedRecordings = [Recordings]()
    private var take:Int = 30
    private var skip:Int = 0
    private var isSearchOpen = false
    private var loadMoreData = false
    private var isLoading = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(refreshIt), name: NSNotification.Name.init("reloadEventsHome"), object: nil)

        self.tableView.register(UINib(nibName: String(describing: RecordingsTableViewCell.self), bundle: Bundle.main), forCellReuseIdentifier: String(describing: RecordingsTableViewCell.self))
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.refreshControl.tintColor = UIColor.lightGray
        let range = ("Pull to refresh" as NSString).range(of: "Pull to refresh")
        let mutableAttributedString = NSMutableAttributedString.init(string: "Pull to refresh")
        mutableAttributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.lightGray, range: range)

        self.refreshControl.attributedTitle = mutableAttributedString
        self.refreshControl.addTarget(self, action: #selector(refreshIt), for: .valueChanged)
        self.tableView.addSubview(refreshControl)
        
        DispatchQueue.main.async {
            UILoader.startAnimating()
        }
        self.presenter = HomeViewPresenter(viewController: self)
        self.presenter?.getSASToken(storage: self.storage)
        self.recording?.take = self.take
        self.recording?.skip = self.skip
        self.presenter?.getRecordings(recording: self.recording)
    }
    override func viewDidAppear(_ animated: Bool) {
        self.presenter = HomeViewPresenter(viewController: self)
    }
    override func viewDidDisappear(_ animated: Bool) {
        self.presenter = nil
        self.btnCancelSearch(UIButton.init()) // Don't comment this. when push to next VC and coming back will call the normal API and that response and functionality is different that normal calling.
    }
    var communicationHandler: CommunicationProtocol = CommunicationModule.getCommunicationHandler()
    @IBAction func btnSettingTapped(_ sender: UIButton) {
        let storyboard = SwinjectStoryboard.create(name: "Profile", bundle: Bundle.main, container: self.initialize.container)
        let vc = storyboard.instantiateViewController(withIdentifier: String.init(describing: ProfileSettingViewController.self)) as! ProfileSettingViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func btnNewRecordingTapped(_ sender: UIButton) {
        if(self.communicationHandler.isConnected()){
            let storyB = SwinjectStoryboard.create(name: "Landing", bundle: Bundle.main, container: self.initialize.container)
            let vc = storyB.instantiateViewController(withIdentifier: String.init(describing: PreRecordAssesViewController.self)) as! PreRecordAssesViewController
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            let storyboard = SwinjectStoryboard.create(name: "Landing", bundle: Bundle.main, container: self.initialize.container)
            let vc = storyboard.instantiateViewController(withIdentifier: String.init(describing: PairDeviceViewController.self)) as! PairDeviceViewController
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    @IBAction func btnSearchTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        self.isSearchOpen = sender.isSelected
        if sender.isSelected {
            self.txtFSearch.becomeFirstResponder()
            self.txtFSearch.isHidden = false
//            self.constSearchLeading.isActive = true
//            self.constSearchWidth.isActive = false
        } else {
            self.view.endEditing(true)
            self.btnCancelSearch(UIButton.init())
            self.txtFSearch.isHidden = true
//            self.constSearchLeading.isActive = false
//            self.constSearchWidth.isActive = true
        }
    }
    @IBAction func txtFSearchDidChange(_ sender: UITextField) {
        self.btnCancel.isHidden = (sender.text ?? "").count == 0
        self.recording?.searchPatientName = (sender.text ?? "")
        self.recording?.skip = 0
        self.recording?.take = 30
        self.isSearchOpen = true
        if !self.isLoading {
            self.presenter?.searchRecording(recording: self.recording)
            self.isLoading = true
        }
    }
    func updateUIby(recordings: [Recordings]) {
        self.loadMoreData = recordings.count >= 30
        DispatchQueue.main.async {
            UILoader.stopAnimating()
            self.refreshControl.endRefreshing()
        }
        if self.skip == 0 {
            self.tableViewData = recordings
        } else {
            self.tableViewData.append(contentsOf: recordings)
        }
        
        self.isLoading = false
        self.skip += 30
        self.take += 30
        self.tableView.isHidden = self.tableViewData.count == 0
        self.btnSearch.isHidden = self.tableViewData.count == 0
        self.tableView.reloadData()
        
    }
    func updateUIBy(searchedRecordings: [Recordings]) {
        DispatchQueue.main.async {
            UILoader.stopAnimating()
        }

        self.isLoading = false
        self.searchedRecordings = searchedRecordings
        self.tableView.isHidden = searchedRecordings.count == 0
        self.tableView.reloadData()
    }
    func callMoreData() {
        if !isSearchOpen && loadMoreData && !isLoading {
            self.isLoading = true
            self.recording?.take = self.take
            self.recording?.skip = self.skip
            self.presenter?.getRecordings(recording: self.recording)
        }
    }
    @objc func refreshIt() {
        DispatchQueue.main.async {
            self.refreshControl.beginRefreshing()
        }
        self.skip = 0
        self.take = 30
        self.recording?.skip = self.skip
        self.recording?.take = self.take
        self.presenter?.getRecordings(recording: self.recording)
    }
    @IBAction func btnCancelSearch(_ sender: UIButton) {
        self.txtFSearch.text = ""
        self.recording?.searchPatientName = ""
        self.recording?.skip = self.skip
        self.recording?.take = self.take
        self.btnCancel.isHidden = true
        self.isSearchOpen = false
        self.isLoading = false
        self.tableView.isHidden = self.tableViewData.count == 0
        self.view.resignFirstResponder()
        self.tableView.reloadData()
    }
}
extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isSearchOpen ? self.searchedRecordings.count : self.tableViewData.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == tableViewData.count - 1 {
            callMoreData()
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: RecordingsTableViewCell.self)) as! RecordingsTableViewCell
        cell.selectionStyle = .none
        let tableData = isSearchOpen ? searchedRecordings : tableViewData
        if tableData.count > 0 {
            cell.setupCell(recording: tableData[indexPath.row])
        } else {
            self.tableView.reloadData()
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedRecording = isSearchOpen ? searchedRecordings[indexPath.row] : tableViewData[indexPath.row]
        let storyB = SwinjectStoryboard.create(name: "Recording", bundle: Bundle.main, container: Initializers.shared.container)
        let vc = storyB.instantiateViewController(withIdentifier: String(describing: RecordingPreviewViewController.self)) as! RecordingPreviewViewController
        vc.recording = selectedRecording
        vc.patient = selectedRecording.patient
        if (selectedRecording.reviewStatus?.lowercased() == "feedbackgiven") {
            vc.pageType = .analysisReceived
        } else if selectedRecording.forwarded == true {
            vc.pageType = .sentForAnalysis
        } else {
            vc.pageType = .recordingCompleted
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}


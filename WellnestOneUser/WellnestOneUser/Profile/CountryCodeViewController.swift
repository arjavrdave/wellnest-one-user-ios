//
//  CountryCodeViewController.swift
//  Wellnest Technician
//
//  Created by Mayank Verma on 10/02/21.
//  Copyright © 2021 Wellnest Inc. All rights reserved.
//

import UIKit
import SDWebImage
protocol ProtoCountryCode {
    func countryCodeSelected(countryCode: String, code: String, countryName: String)
}

class CountryCodeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var txtFSearch: UITextField!
    @IBOutlet weak var imageCountryCurrent: UIImageView!
    @IBOutlet weak var btnCurrentLocation: UIButton!
    @IBOutlet weak var lblCountryCurrentName: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    var delegate : ProtoCountryCode?
    
    var countryCodeJSON = [[String:String]]()
    var searchedJSON = [[String : String]]()
    
    var tableViewTitles = [String]()
    var searchedTiles = [String]()
    var sortedTitles = [String]()
    
    var tableViewData = [String: [[String : String]]]()
    var sortedData = [String: [[String : String]]]()
    var searchedData = [String: [[String : String]]]()
    
    var selectedCountryName = "India"
    var selectedCountryIdentifier = "IN"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.txtFSearch.delegate = self
        
        self.lblCountryCurrentName.text = self.selectedCountryName
        self.imageCountryCurrent.layer.cornerRadius = self.imageCountryCurrent.frame.height / 2
        self.imageCountryCurrent.sd_setImage(with: URL.init(string: "https://flagcdn.com/h80/\(self.selectedCountryIdentifier.lowercased()).png"), completed: nil)
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorStyle = .none
        
        if let path = Bundle.main.path(forResource: "countryCodes", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                if let jsonResult = jsonResult as? [Dictionary<String, String>] {
                    self.countryCodeJSON = jsonResult
                    (self.sortedData, self.sortedTitles) = self.setupDatabase(dataRaw: self.countryCodeJSON)
                    self.tableViewData = self.sortedData
                    self.tableViewTitles = self.sortedTitles
                    self.tableView.reloadData()
                }
            } catch {
               
            }
        }
        self.tableView.sectionIndexColor = UIColor.colorFrom(hexString: "333333")
    }
    
    @IBAction func btnBackTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnCountryCodeTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func txtFEditingChanged(_ sender: UITextField) {
        let searchedText = sender.text?.trim().lowercased() ?? ""
        if searchedText.count > 0 {
            self.searchedJSON = self.countryCodeJSON.filter{($0["name"]?.lowercased().range(of: searchedText) != nil)}
            (self.searchedData, self.searchedTiles) = self.setupDatabase(dataRaw: self.searchedJSON)
            self.tableViewData = self.searchedData
            self.tableViewTitles = self.searchedTiles
            self.tableView.reloadData()
        } else {
            self.tableViewData = self.sortedData
            self.tableViewTitles = self.sortedTitles
            self.tableView.reloadData()
        }
    }
    @IBAction func btnCancelSearchTapped(_ sender: UIButton) {
        self.txtFSearch.text = ""
        self.tableViewData = self.sortedData
        self.tableViewTitles = self.sortedTitles
        self.tableView.reloadData()
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return self.tableViewTitles
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.tableViewTitles.count > 0 {
            let key = self.tableViewTitles[section]
            return self.tableViewData[key]?.count ?? 0
        }
        return 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.tableViewTitles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String.init(describing: CountryCodeTableViewCell.self)) as! CountryCodeTableViewCell
        let key = self.tableViewTitles[indexPath.section]
        if let list = self.tableViewData[key] {
            let code = list[indexPath.row]["code"] ?? ""
            let name = list[indexPath.row]["name"] ?? ""
            cell.setUpCell(countryCode: code, countryName: name)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let key = self.tableViewTitles[indexPath.section]
        if let list = self.tableViewData[key] {
            let code = list[indexPath.row]["dial_code"] ?? ""
            let codeCnt = list[indexPath.row]["code"] ?? ""
            let name = list[indexPath.row]["name"] ?? ""
            self.delegate?.countryCodeSelected(countryCode: code, code: codeCnt, countryName: name)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func setupDatabase(dataRaw : [[String : String]]) -> ([String: [[String : String]]], [String]) {
        var sortedTitles = [String]()
        var sorted = [String: [[String : String]]]()
        var indexTitle = [String]()
        for object in dataRaw {
            let key = String(object["name"]?.prefix(1) ?? "")
            indexTitle.append(key)
            if var values = sorted[key] {
                values.append(object)
                sorted[key] = values
            } else {
                sorted[key] = [object]
            }
        }
        sortedTitles = [String](sorted.keys)
        sortedTitles = sortedTitles.sorted(by: { $0 < $1 })
        return (sorted, sortedTitles)
    } 
}

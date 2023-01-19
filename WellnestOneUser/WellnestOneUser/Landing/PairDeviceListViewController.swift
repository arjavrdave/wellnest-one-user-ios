//
//  PairDeviceListViewController.swift
//  WellnestOneUser
//
//  Created by Nihar Jagad on 22/11/22.
//

import UIKit
import CoreBluetooth
import WellnestBLE
import SwinjectStoryboard
class PairDeviceListViewController: UIParentViewController {
    
    var recording: IRecordings?
    var isReRecordFlow: Bool = false
    
    @IBOutlet weak var tableView: UITableView!
    
    var peripherals = [WellnestPeripheral]()
    var communicationHandler: CommunicationProtocol = CommunicationModule.getCommunicationHandler()
    var selectedPeripheral : WellnestPeripheral?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.communicationHandler.peripheralDelegate = self;
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorStyle = .none
        self.communicationHandler.startScan()
    }
    @IBAction func btnCancelTapped(_ sender: UIButton) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func btnBackTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}

//MARK: PeripheralDelegate
extension PairDeviceListViewController: PeripheralDelegate {
    func didDiscoverPeripherals(peripherals: [WellnestPeripheral]) {
        print ("Found Peripherals")
        self.peripherals = peripherals
        self.tableView.reloadData()
    }
    
    func authentication(peripheral: WellnestPeripheral?, error: String?) {
        DispatchQueue.main.async {
            UILoader.stopAnimating()
        self.tableView.reloadData()
        UILoader.stopAnimating()
        }
        if let err = error {
            print (err)
        } else {
            DispatchQueue.main.async {
                
                if let jsonClass = peripheral?.convertEnocodeToJSON() {
                    print(jsonClass)
                    UserDefaults.standard.set(jsonClass, forKey: "peripheral")
                }

                UIAlertUtil.alertWith(title: "Success", message: "Wellnest ECG Device connected successfully.", viewController: self) { (_) in
                    let storyB = SwinjectStoryboard.create(name: "Landing", bundle: Bundle.main, container: self.initialize.container)
                    let vc = storyB.instantiateViewController(withIdentifier: String.init(describing: PreRecordAssesViewController.self)) as! PreRecordAssesViewController
                    vc.recording = self.recording
                    vc.isReRecordFlow = self.isReRecordFlow
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
    }
    func didDisconnect(peripheral: WellnestPeripheral?, error: NSError?) {
        UILoader.stopAnimating()
        if error?.domain != "TurnedOff" {
            self.showError(error: error)
        }
    }
}
//MARK: TableViewDelegate
extension PairDeviceListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.peripherals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String.init(describing: BluetoothPairTableViewCell.self)) as! BluetoothPairTableViewCell
        cell.lblBluetoothName?.text = self.peripherals[indexPath.row].name
        cell.peripheral = self.peripherals[indexPath.row]
        cell.delegate = self
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedPeripheral = self.peripherals[indexPath.row]
    }
}

//MARK: DeviceSelectProtocol
extension PairDeviceListViewController: DeviceSelectProtocol {
    func didSelectPeripheral(peripheral: WellnestPeripheral?) {
        DispatchQueue.main.async {
            UILoader.startAnimating()
        }
        if let p = peripheral {
            self.communicationHandler.connect(peripheral: p)
        } else {
            UIAlertUtil.alertWith(title: "Alert", message: "Please select Wellnest 12L® from discovered list.", viewController: self) { (_) in }
        }
    }
}

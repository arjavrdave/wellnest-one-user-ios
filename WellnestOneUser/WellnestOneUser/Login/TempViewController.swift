//
//  TempViewController.swift
//  WellnestOneUser
//
//  Created by Nihar Jagad on 08/11/22.
//

import UIKit
import SwinjectStoryboard
class TempViewController: UIParentViewController, UIScrollViewDelegate {
    @IBOutlet var viewCharts: [ViewWithGraph]!
    @IBOutlet weak var hScrollView: UIScrollView!
    var recordingRawData: Data?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.filterAndDisplayData()
        self.hScrollView.delegate = self
        self.hScrollView.decelerationRate = .fast
    }
    @IBAction func tappedLogout(_ sender: UIButton) {
        UserDefaults.standard.setBearerToken(token: nil)
        let storyboard = SwinjectStoryboard.create(name: "Login", bundle: Bundle.main, container: self.initialize.container)
        let vc = storyboard.instantiateViewController(withIdentifier: String.init(describing: GetStartedViewController.self)) as! GetStartedViewController
        self.navigationController?.setViewControllers([vc], animated: true)
    }
    func filterAndDisplayData() {
        if let data = recordingRawData {
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
                UILoader.stopAnimating()
            }
        }
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        for charts in viewCharts {
            charts.moveLabel(offset: scrollView.contentOffset.x)
        }
    }
}

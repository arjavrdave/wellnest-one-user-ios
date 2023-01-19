//
//  VitalChartDataProvider.swift
//  iOSInfoChart
//
//  Created by Heo on 2021/03/30.
//

import Foundation
import CoreGraphics
import UIKit

/**
실시간 차트의 설정값 및 정보를 위한 프로토콜
 
 - Author: Heo
 */
public protocol VitalChartDataProvider {

    var oneSecondDataCount: Int { get }

    var visibleSecondRange: Int { get }

    var totalRangeCount: Int { get }
    
    var refreshGraphInterval: Double { get }
    
    var vitalMaxValue: Double { get }

    var vitalMinValue: Double { get }
    
    var realTimeData: [Double] { get set }
    
    var lineColor: UIColor { get set }
    
    var lineWidth: CGFloat { get set }

    var isEnabledValueCircleIndicator: Bool { get set }
    
    var valueCircleIndicatorRadius: Double { get set }

    var valueCircleIndicatorColor: UIColor { get set }
    
    var transformer: Transformer? { get set }
    
    func dequeueRealTimeData(value: Double)
}

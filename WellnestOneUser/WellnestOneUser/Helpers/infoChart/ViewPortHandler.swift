//
//  ViewPortHandler.swift
//  iOSInfoChart
//
//  Created by Heo on 2021/03/29.
//

import Foundation
import CoreGraphics

/**
 차트 View의 위치, 크기 정보를 담는 클래스
 
 - Author: Heo
 */
open class ViewPortHandler: NSObject {
    
    open private(set) var contentRect = CGRect()
    
    open private(set) var chartWidth = CGFloat()
    open private(set) var chartHeight = CGFloat()
    
    open func setChartDimens(width: CGFloat, height: CGFloat) {
        chartHeight = height
        chartWidth = width
         
        contentRect = CGRect(x: 0,
                             y: 0,
                             width: chartWidth,
                             height: chartHeight)
    }

    open func setOffset(left: CGFloat, top: CGFloat, right: CGFloat, bottom: CGFloat) {
        contentRect = CGRect(x: left,
                             y: top,
                             width: chartWidth + right,
                             height: chartHeight + bottom)
    }
    
    open var offsetLeft: CGFloat {
        return contentRect.origin.x
    }
    
    open var offsetRight: CGFloat {
        return (contentRect.size.width + contentRect.origin.x) - chartWidth
    }
    
    open var offsetTop: CGFloat {
        return contentRect.origin.y
    }
    
    open var offsetBottom: CGFloat {
        return (contentRect.size.height + contentRect.origin.y) - chartHeight
    }
    
    open var contentWidth: CGFloat {
        return contentRect.size.width
    }
    
    open var contentHeight: CGFloat {
        return contentRect.size.height
    }
}

//
//  Transformer.swift
//  iOSInfoChart
//
//  Created by Heo on 2021/03/29.
//

import Foundation
import CoreGraphics

/**
 좌표 변환계
 
 - Author: Heo
 */
open class Transformer: NSObject {
    
    internal var offsetMatrix = CGAffineTransform.identity

    internal var valueMatrix = CGAffineTransform.identity

    internal var viewPortHandler: ViewPortHandler

    public init(viewPortHandler: ViewPortHandler)
    {
        self.viewPortHandler = viewPortHandler
    }
    
    open func initValueMatrix(chartXMin: Double, deltaX: CGFloat, deltaY: CGFloat, chartYMin: Double)
    {
        let scaleX = (viewPortHandler.chartWidth / deltaX)
        let scaleY = (viewPortHandler.chartHeight / deltaY)

        valueMatrix = CGAffineTransform.identity
            .scaledBy(x: scaleX, y: -scaleY)
            .translatedBy(x: CGFloat(-chartXMin), y: CGFloat(-chartYMin))
    }
    
    open func initOffsetMatrix() {
        offsetMatrix = CGAffineTransform(translationX: viewPortHandler.offsetLeft, y: viewPortHandler.chartHeight - viewPortHandler.offsetBottom)
    }
    
    open var valueToPixelMatrix: CGAffineTransform {
        return valueMatrix.concatenating(offsetMatrix)
    }
    
}

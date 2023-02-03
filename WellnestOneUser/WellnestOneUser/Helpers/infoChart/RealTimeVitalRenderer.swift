//
//  RealTimeVitalRenderer.swift
//  iOSInfoChart
//
//  Created by Heo on 2021/03/30.
//

import Foundation
import CoreGraphics

/**
 실시간 데이터를 렌더링하는 객체
 
 - Author: Heo
 */
open class RealTimeVitalRenderer {
    
    /**
     차트 데이터 프로바이더
     */
    open var dataProvider: VitalChartDataProvider?
    
    /**
     차트 draw Pointer (index)
     */
    open var drawPointer: Int = 0
    
    /**
     차트 remove Pointer (index)
     */
    open var removePointer: Int = 0
    
    /**
     서로 다른 좌표계에서 x,y 값을 변환
     */
    open var trans: Transformer
    
    /**
     Alpha 그라데이션 비율
     - 지워지는 영역에서 그라데이션이 차지하는 비율
     */
    public let gradient_ratio = Double(0.2)
    
    /**
     전체 중 지워지는 부분의 개수
     */
    open var removeRangeCount: Int = 0
    
    
    public init(dataProvider: VitalChartDataProvider) {
        self.dataProvider = dataProvider
        self.trans = dataProvider.transformer!
        
        updateSetting()
    }
    
    /**
     렌더링 설정값 없데이트
     - 차트의 스펙이 변경될 경우 호출
     */
    open func updateSetting() {
        
        guard let dataProvider = dataProvider else { return }
        
        drawPointer = 0
        removePointer = dataProvider.totalRangeCount - Int((Double(dataProvider.totalRangeCount) * (1.0 - dataProvider.refreshGraphInterval)))
    }
    
    /**
     배열 포인터 이동
     - 데이터가 들어오기 전에 호출
     - drawPointer와 removePointer 이동
     */
    open func readyForUpdateData() {
        guard let dataProvider = dataProvider else { return }
        
        drawPointer += 1
        removePointer += 1
        
        if drawPointer >= dataProvider.totalRangeCount {
            drawPointer = 0
        }
        if removePointer >= dataProvider.totalRangeCount {
            removePointer = 0
        }
    }
    
    /**
     실시간 데이터 렌더링
     - Parameter context: draw()를 통해 UIGraphicsGetCurrentContext()를 받아서 사용
    
     - Core Graphics를 통해 차트 렌더링
     */
    open func drawLinear(context: CGContext) {
        
        guard let dataProvider = dataProvider else { return }
        
        context.saveGState()
        defer { context.restoreGState() }
        
        context.setLineWidth(dataProvider.lineWidth)
        
        let valueToPixelMatrix = trans.valueToPixelMatrix
        
        let lineColor = dataProvider.lineColor.cgColor
        var alphaCount: Int = 0
        var alphaValue: CGFloat = 0
        
        var firstY: Double
        var secondY: Double
        
        removeRangeCount = (drawPointer < removePointer) ? removePointer - drawPointer : removePointer
        
        for x in stride(from: 1, to: dataProvider.totalRangeCount, by: 1) {
            firstY = dataProvider.realTimeData[x == 0 ? 0 : x - 1]
            secondY = dataProvider.realTimeData[x]
            
            // emptyData의 경우 continue
            if (firstY == -9999 || secondY == -9999){
                continue
            }

            let path = CGMutablePath()
            
            // 선의 시작점
            let startPoint =
                CGPoint(x: CGFloat(x == 0 ? 0 : x - 1),
                        y: CGFloat(firstY))
                .applying(valueToPixelMatrix)
            path.move(to: startPoint)
            
            // 선의 종료점
            let endPoint =
                CGPoint(
                    x: CGFloat(x),
                    y: CGFloat(secondY))
                .applying(valueToPixelMatrix)
            path.addLine(to: endPoint)
            
            context.addPath(path)
            
            // 그라데이션 처리
            if (x >= removePointer) && (alphaCount < removeRangeCount) {
                alphaValue = calculateAlphaRatio(totalCount: removeRangeCount, count: alphaCount)
                context.setAlpha(alphaValue)
                alphaCount += 1
            } else {
                context.setAlpha(1)
            }

            // 차트 stroke
            context.setStrokeColor(lineColor)
            context.strokePath()
        }
        
        /// draw Circle Indicator
        if dataProvider.isEnabledValueCircleIndicator {
            
            var rect = CGRect()
            
            let circlePoint =
                CGPoint(x: CGFloat(drawPointer),
                        y: CGFloat(dataProvider.realTimeData[drawPointer]))
                .applying(valueToPixelMatrix)
            
            let circleRadius = dataProvider.valueCircleIndicatorRadius
            let circleDiameter = circleRadius * 2.0
            
            rect.origin.x = circlePoint.x - CGFloat(circleRadius)
            rect.origin.y = circlePoint.y - CGFloat(circleRadius)
            rect.size.width = CGFloat(circleDiameter)
            rect.size.height = CGFloat(circleDiameter)
            
            context.setAlpha(1)
            context.setFillColor(dataProvider.valueCircleIndicatorColor.cgColor)
            context.fillEllipse(in: rect)
        }
    }
    
    /**
     지워지는 그라데이션 부분의 Alpha 값 계산
     - Parameter totalCount: 지워지는 전체 Count
     - Parameter count: 그려지는 부분 Count
     - Returns: 전체 부분에서 그려지는 부분의 Alpha 값
     
     - ex) 지워질 그라데이션 전체가 100이고 현재 그려지고 있는 부분이 30이라면, 이 부분의 비율인 30%를 alpha값으로  치환하여 리턴
     */
    private func calculateAlphaRatio(totalCount: Int, count: Int) -> CGFloat {
        let ratio = Double(count) / Double(totalCount)
        return CGFloat(ratio)
    }
    
}

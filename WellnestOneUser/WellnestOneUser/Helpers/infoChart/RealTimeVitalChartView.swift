//
//  RealTimeVitalChartView.swift
//  iOSInfoChart
//
//  Created by Heo on 2021/03/30.
//

import Foundation
import CoreGraphics
import UIKit

/**
 ECG 및 생체신호 실시간 차트를 그려주는 클래스
 
 - Author: Heo
 */
open class RealTimeVitalChartView: UIView, VitalChartDataProvider {
    
    /**
     빈 데이터 값. Null의 의미를 가
     - 차트 렌더링 시 현재 출력되는 데이터가 없음을 알려줄 때 사용
     */
    public let EMPTY_DATA = Double(-9999)
    
    /**
     실시간 차트 스펙
     */
    public var spec: Spec = Spec()
    
    /**
     실시간 데이터, 렌더링 시 출력되는 데이터를 담고 있음.
     - 배열의 index를 x 값으로 사용, 배열의 value를 y 값으로 사용
     */
    public var realTimeData: [Double] = [Double]()
    
    /**
     실시간 데이터 렌더링 객체
     */
    public var realTimeVitalRenderer: RealTimeVitalRenderer?
    
    /**
     ViewPortHandler
     */
    public var viewPortHandler: ViewPortHandler = ViewPortHandler()
    
    /**
     서로 다른 좌표계에서 x,y 값을 변환
     ```
     private func settingTransformer()
     ```
     - viewPortHandler 값 설정 후 settingTransformer()를 호출하여 transformer 값 변경
     */
    public var transformer: Transformer?

    /**
     차트 선 색상
     */
    public var lineColor: UIColor = UIColor()
    
    /**
     차트 선 두께
     */
    public var lineWidth: CGFloat = CGFloat()
    
    /**
     현재 값 인디케이터 표시 활성 여부
     - 기본값은 true(활성화)
     */
    public var isEnabledValueCircleIndicator: Bool = true
    
    /**
     현재 값 인디케이터 크기
     */
    public var valueCircleIndicatorRadius: Double = 1
    
    /**
     현재 값 인디케이터 색상
     */
    public var valueCircleIndicatorColor: UIColor = UIColor()
    
    /**
     실시간 데이터 핸들러
     */
    public var dataHandler: RealTimeDataHandler!
    
    /**
     스토리보드에서 호출할 초기화 메소드
     */
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.initialize()
    }
    
    /**
     프로그래밍 방식으로 호출할 초기화 메소드
     */
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initialize()
    }

    /**
     차트 선의 색상 및 두께 등 렌더링 정보 초기화와 Transformer, 렌더링 객체, 데이터 핸들러를 할당.
     */
    private func initialize() {
        lineColor = UIColor.red
        lineWidth = CGFloat(1.5)
        
        isEnabledValueCircleIndicator = true
        valueCircleIndicatorColor = UIColor.red
        valueCircleIndicatorRadius = 3
        
        viewPortHandler.setChartDimens(width: bounds.size.width, height: bounds.size.height)
        transformer = Transformer(viewPortHandler: viewPortHandler)
        realTimeVitalRenderer = RealTimeVitalRenderer(dataProvider: self)
        dataHandler = RealTimeDataHandler(dataProvider: self)
        
        setRealTimeSpec(spec: spec)
        
        settingTransformer()
    }
    
    /**
     변경된 차트 사이즈에 맞게 Transformer 업데이트
     */
    public func updateChartSize() {
        viewPortHandler.setChartDimens(width: bounds.size.width, height: bounds.size.height)
        settingTransformer()
    }
    
    open override func draw(_ rect: CGRect) {
        
        guard let renderer = realTimeVitalRenderer else { return }
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        renderer.drawLinear(context: context)
    }
    
    /**
     실시간 차트 스펙 설정
     - Parameter spec: 설정될 차트 스펙 객체
     */
    open func setRealTimeSpec(spec: Spec) {
        
        guard let realTimeVitalRenderer = realTimeVitalRenderer else { return }
        
        self.spec = spec
        realTimeVitalRenderer.updateSetting()
        dataHandler.updateSetting()
        let dataCount = spec.oneSecondDataCount * spec.visibleSecondRange
        realTimeData = [Double](repeating: EMPTY_DATA, count: dataCount)
        resetRealTimeData()
    }

    /**
     실시간 데이터를 렌더링에 사용되는 배열에 추가
     - Parameter value: 추가될 실시간 데이터
     
     Queue에서 dequeue된 데이터를 렌더링할 때 사용
     ```
     func setNeedsDisplay()
     ```
     view의 setNeedsDisplay() 메소드를 호출하여 View 업데이트 요청함
     */
    public func addRealTimeData(value: Double) {
        
        guard let realTimeVitalRenderer = realTimeVitalRenderer else { return }
        
        realTimeVitalRenderer.readyForUpdateData()
        
        realTimeData[realTimeVitalRenderer.drawPointer] = value
        realTimeData[realTimeVitalRenderer.removePointer] = EMPTY_DATA
        
        setNeedsDisplay()
    }
    
    /**
     좌표변환계 설정
     */
    private func settingTransformer() {
        guard let transformer = transformer else { return }
        
        transformer.initValueMatrix(chartXMin: 0,
                                    deltaX: CGFloat(spec.oneSecondDataCount * spec.visibleSecondRange),
                                    deltaY: CGFloat(spec.vitalMaxValue - spec.vitalMinValue),
                                    chartYMin: spec.vitalMinValue)
        transformer.initOffsetMatrix()
    }
    
    /**
     그려진 실시간 데이터 삭제
     */
    private func resetRealTimeData() {
        for i in 0..<realTimeData.count {
            realTimeData[i] = EMPTY_DATA
        }
    }
    
    /**
     차트 리셋
     
     - 그려진 데이터 초기화
     - 아직 출력되지 않은 Queue의 남은 데이터 초기화
     - 데이터 핸들러 스케쥴러 정지
     */
    public func reset() {
        resetRealTimeData()
        dataHandler.stop()
        dataHandler.reset()
        dataHandler.updateSetting()
        realTimeVitalRenderer?.updateSetting()
    }
    
    // MARK: - VitalChartDataProvider

    public func dequeueRealTimeData(value: Double) {
        addRealTimeData(value: value)
    }
    
    public var oneSecondDataCount: Int {
        spec.oneSecondDataCount
    }
    
    public var visibleSecondRange: Int {
        spec.visibleSecondRange
    }
        
    /**
     보여질 전체 데이터 개수
     */
    public var totalRangeCount: Int {
        spec.oneSecondDataCount * spec.visibleSecondRange
    }
    
    public var refreshGraphInterval: Double {
        spec.refreshGraphInterval
    }
    
    public var vitalMaxValue: Double {
        spec.vitalMaxValue
    }
    
    public var vitalMinValue: Double {
        spec.vitalMinValue
    }
}

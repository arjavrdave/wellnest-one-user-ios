//
//  Spec.swift
//  iOSInfoChart
//
//  Created by Heo on 2021/03/29.
//

import Foundation

/**
실시간 차트 설정 값
 
 - Author: Heo
 */
public class Spec {
    
    private var _oneSecondDataCount: Int = 500
    
    private var _visibleSecondRange: Int = 5
    
    private var _refreshGraphInterval: Double = Double(0.1)
    
    private var _vitalMaxValue: Double = Double(1.5)
    
    private var _vitalMinValue: Double = Double(-0.5)
    
    public init() {
    }
    
    public init(oneSecondDataCount: Int, visibleSecondRange: Int, refreshGraphInterval: Double, vitalMaxValue: Double, vitalMinValue: Double) {
        
        self.oneSecondDataCount = oneSecondDataCount
        self.visibleSecondRange = visibleSecondRange
        self.refreshGraphInterval = refreshGraphInterval
        self.vitalMaxValue = vitalMaxValue
        self.vitalMinValue = vitalMinValue
    }
    
    /**
    1초 동안 들어오는 데이터 개수
     - 조건 : newValue >= 1
     - 기본값 : 500[ea]
     */
    open var oneSecondDataCount: Int {
        get {
            return _oneSecondDataCount
        }
        set {
            let condition = newValue >= 1
            let message = "oneSecondDataCount: 1초 동안 들어올 데이터의 갯수는 최소 1개 이상이어야 합니다."
            assert(condition, message)
            _oneSecondDataCount = newValue
        }
    }

    /**
     보여질 X축 범위 (초 단위)
     - 조건 : newValue >= 2
     - 기본값 : 5[sec]
     */
    open var visibleSecondRange: Int {
        get {
            return _visibleSecondRange
        }
        set {
            let condition = newValue >= 2
            let message = "visibleSecondRange: 보여질 범위는 최소 2초 이상이어야 합니다."
            assert(condition , message)
            _visibleSecondRange = newValue
        }
    }
    
    /**
     새로고침 되는 그래프와 이전 그래프와의 간격
     - 조건 : 0.0 < newValue < 1.0
     - 기본값 : 0.1 (10%)
     */
    open var refreshGraphInterval: Double {
        get {
            return _refreshGraphInterval
        }
        set {
            let condition = 0.0 < newValue && newValue < 1.0
            let message = "refreshGraphInterval: 이전 그래프와의 간격은 퍼센트로 나타내어야 하며, 0.0 초과, 1.0 미만이어야 합니다."
            assert(condition , message)
            _refreshGraphInterval = newValue
        }
    }
    
    /**
     바이탈 최대 값
     - 조건 : newValue > vitalMinValue
     - 기본값 : 1.5
     */
    open var vitalMaxValue: Double {
        get {
            return _vitalMaxValue
        }
        set {
            let condition = newValue > vitalMinValue
            let message = "vitalMaxValue: 최대값은 최소값보다 커야합니다."
            assert(condition , message)
            _vitalMaxValue = newValue
        }
    }
    
    /**
     바이탈 최소 값
     - 조건 : vitalMaxValue > newValue
     - 기본값 : - 0.5
     */
    open var vitalMinValue: Double {
        get {
            return _vitalMinValue
        }
        set {
            let condition = vitalMaxValue > newValue
            let message = "vitalMaxValue: 최대값은 최소값보다 커야합니다."
            assert(condition , message)
            _vitalMinValue = newValue
        }
    }
}

//
//  RealTimeDataHandler.swift
//  iOSInfoChart
//
//  Created by Heo on 2021/04/05.
//

import Foundation

/**
 실시간 데이터를 관리하는 핸들러
 
 - 균일하지 못하거나 무작위로 들어오는 데이터를 Queue에 담아 일정 시간 간격으로 출력
 - 위상이 지연되거나 겹치는 현상을 없애고 의도된 대로 균일하게 출력할 수 있도록 구체화한 객체
 
 - Author: Heo
 */
open class RealTimeDataHandler {

    /**
     메인 Queue
     */
    open var mainQueue = Queue<Double>()

    /**
     차트 데이터 프로바이더
     */
    open var dataProvider: VitalChartDataProvider?

    /**
     기본 값
     - Queue에 데이터가 없을 경우 출력되는 값
     */
    var defaultValue: Double = 0
    
    /**
     마지막 값
     - 마지막으로 Dequeue된 값
     */
    var lastValue: Double = 0
    
    /**
     출력될 값
     - 출력될 값을 담는 임시 변수
     */
    var dequeueValue: Double = 0

    /**
     타이머(스케쥴러)
     */
    var timer: DispatchSourceTimer?
    
    
    public init(dataProvider: VitalChartDataProvider) {
        self.dataProvider = dataProvider
        updateSetting()
    }

    /**
    핸들러 설정값 업데이트
     - 차트의 스펙이 변경될 경우 호출
     */
    public func updateSetting() {
        guard let dataProvider = dataProvider else { return }
        self.defaultValue = ((dataProvider.vitalMaxValue - dataProvider.vitalMinValue) / 2 + dataProvider.vitalMinValue)
    }

    /**
     메인 큐 Enqueue
     - Parameter value: 실시간 데이터
     
     - 실시간 데이터를 메인 큐로 Enqueue하면서 스케쥴러 활성화
     - enqueue후에 dequeue가 되도록 sync로 동작
     */
    public func enqueue(value: Double) {
        DispatchQueue(label: "iOSInfoChart.app.enqueue").sync {
            self.run()
            self.mainQueue.enqueue(value)
        }
    }

    /**
     메인 큐 Dequeue
     
     - dequeueValue를 차트뷰로 전달
     - enqueue후에 dequeue가 되도록 sync로 동작
     */
    public func dequeue() {
        DispatchQueue(label: "iOSInfoChart.app.dequeue").sync {
            self.lastValue = dequeueValue
            //self.dequeueValue = self.mainQueue.dequeue() ?? self.defaultValue
            self.dequeueValue = self.mainQueue.dequeue() ?? self.lastValue
            self.dataProvider!.dequeueRealTimeData(value: self.dequeueValue)
        }
    }
    
    
    /**
     스케쥴러 실행
     
     - ex) 1초에 500개의 데이터를 그리는 경우, 0.002초 간격으로 데이터를 내보내는 스케쥴러 생성
     - 타이머가 활성화되어있을 경우 아무 동작 없음
     */
    public func run() {
        if timer == nil {
            let dataInterval = 1 / Double(dataProvider!.oneSecondDataCount)
            
            timer = DispatchSource.makeTimerSource(flags: [],
                                                   queue: DispatchQueue.global(qos: .userInteractive))
            timer?.schedule(deadline: .now(),
                            repeating: dataInterval)
            timer?.setEventHandler {
                self.dataDequeueTask()
            }
            timer?.activate()
        }
    }
    
    // 로그
//    var nowTime: Date?
//    var prevTime: Date?
//    var totalOverDelayTime = TimeInterval(0)
    
    /**
     Queue의 데이터를 dequeue()하는 Task
     */
    fileprivate func dataDequeueTask() {
        
        DispatchQueue.main.async {
            self.dequeue()
        }
        
        // 로그
//        let dataInterval = 1 / Double(dataProvider!.oneSecondDataCount)
//        if prevTime != nil {
//            nowTime = Date()
//            let delayTime = nowTime!.timeIntervalSince(prevTime!)
//            totalOverDelayTime += delayTime - dataInterval
//            prevTime = nowTime
//
//            print("delayTime = \(delayTime)")
//            print("delayTime = \(delayTime) //  totalOverDelayTime = \(totalOverDelayTime)")
//        } else {
//            prevTime = Date()
//        }
    }
    
    /**
     스케쥴러 정지
     */
    public func stop() {
        timer?.cancel()
        timer = nil
    }
    
    /**
      Queue 내부 데이터 리셋
     */
    public func reset() {
        mainQueue.clear()

        // 로그
//        totalOverDelayTime = TimeInterval(0)
//        prevTime = nil
    }
}

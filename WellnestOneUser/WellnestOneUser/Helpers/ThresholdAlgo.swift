//
//  ThreshHoldAlgo.swift
//  WellnestOneUser
//
//  Created by Nihar Jagad on 23/11/22.
//

import Foundation
class ThresholdAlgo {
    static let shared = ThresholdAlgo()
    
    func ThresholdingAlgo(y: [Double],lag: Int,threshold: Double,influence: Double) -> ([Int],[Double],[Double]) {
        
        // Create arrays
        var signals   = Array(repeating: 0, count: y.count)
        var filteredY = Array(repeating: 0.0, count: y.count)
        var avgFilter = Array(repeating: 0.0, count: y.count)
        var stdFilter = Array(repeating: 0.0, count: y.count)
        
        // Initialise variables
        for i in 0...lag-1 {
            signals[i] = 0
            filteredY[i] = y[i]
        }
        
        // Start filter
        avgFilter[lag-1] = arithmeticMean(array: subArray(array: y, s: 0, e: lag-1))
        stdFilter[lag-1] = standardDeviation(array: subArray(array: y, s: 0, e: lag-1))
        
        for i in lag...y.count-1 {
            if abs(y[i] - avgFilter[i-1]) > threshold*stdFilter[i-1] {
                if y[i] > avgFilter[i-1] {
                    signals[i] = 1      // Positive signal
                } else {
                    // Negative signals are turned off for this application
                    //signals[i] = -1       // Negative signal
                }
                filteredY[i] = influence*y[i] + (1-influence)*filteredY[i-1]
            } else {
                signals[i] = 0          // No signal
                filteredY[i] = y[i]
            }
            // Adjust the filters
            avgFilter[i] = arithmeticMean(array: subArray(array: filteredY, s: i-lag, e: i))
            stdFilter[i] = standardDeviation(array: subArray(array: filteredY, s: i-lag, e: i))
        }
        
        return (signals,avgFilter,stdFilter)
    }
    
    // Function to calculate the arithmetic mean
    func arithmeticMean(array: [Double]) -> Double {
        var total: Double = 0
        for number in array {
            total += number
        }
        return total / Double(array.count)
    }
    // Function to calculate the standard deviation
    func standardDeviation(array: [Double]) -> Double
    {
        let length = Double(array.count)
        let avg = array.reduce(0, {$0 + $1}) / length
        let sumOfSquaredAvgDiff = array.map { pow($0 - avg, 2.0)}.reduce(0, {$0 + $1})
        return sqrt(sumOfSquaredAvgDiff / length)
    }
    // Function to extract some range from an array
    func subArray<T>(array: [T], s: Int, e: Int) -> [T] {
        if e > array.count {
            return []
        }
        return Array(array[s..<min(e, array.count)])
    }
}

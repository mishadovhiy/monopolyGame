//
//  BetModel.swift
//  MonopolyGame
//
//  Created by Mykhailo Dovhyi on 21.04.2025.
//

import Foundation

extension GameViewModel {
    struct BetModel {
        var playerPalance:Int = 0
        var bet:[(PlayerStepModel, Int)] = [] {
            didSet {
                if (self.betValue * 100) <= Float(bet.last?.1 ?? 0) {
                    self.betValue = Float((bet.last?.1 ?? 0) + 1) / 100
                }
            }
        }
        var betProperty:Step? {
            didSet {
                betValue = 0.01
            }
        }
        var betValue:Float = 0 {
            didSet {
                if betValue < betSliderRange.lowerBound {
                    betValue = betSliderRange.lowerBound
                }
                if betValue > betSliderRange.upperBound {
                    betValue = betSliderRange.upperBound
                }
            }
        }
        
        var betSliderRange:ClosedRange<Float> {
            let last = Float(bet.last?.1 ?? 1)
            var from = last
            if from > 0 {
                from += 1
            }
            let toValue:Int
            if betProperty?.buyPrice ?? 1 >= playerPalance {
                toValue = betProperty?.buyPrice ?? 1
            } else {
                toValue = playerPalance
            }
            var to = (Float(toValue))
            if from >= to {
                to = from + 1
            }
            if from <= 100 {
                from = 150
                to = from + 300
            }
            if to <= 100 {
                to = 2000
            }
            if from < last {
                return ((last / 100)...((500 + last) / 100))

            } else {
                return ((last / 100)...((500 + from) / 100))

            }
            //        0...10
        }
    }

}

//
//  Step.swift
//  MonopolyGame
//
//  Created by Mykhailo Dovhyi on 03.04.2025.
//

import SwiftUI

enum Step:String, CaseIterable {
    case go
    case chest1
    case tax1
    case brawn1, brawn2
    case transport1
    case blue1, blue2
    case chance1, blue3
    case jail1
    case pink1
    case singlePoperty1
    case pink2, pink3
    case transport2
    case orange1
    case chest2
    case orange2, orange3
    case parking
    case chance2
    case red1, red2, red3
    case transport3
    case yellow1, yellow2
    case win1
    case yellow3
    case jail2
    case green1, green2
    case chest3
    case green3
    case transport4
    case chance3
    case purpure1
    case tax2
    case purpure2
    
    static let numberOfItemsInSection:Int = 10
    static func items(_ section:Int) -> [Step] {
        let range = (0..<(numberOfItemsInSection))
        let array = Array(Step.allCases)
        if array.count - 1 >= range.upperBound {
            if section >= 2 {
                return Array(array[range])

            } else {
                return Array(array[range]).reversed()
            }
        }
        return []
    }
    
    var buyPrice:Int? {
        if let color, let number = rawValue.number,
           let priceStep = color.priceStep,
            let priceStarter = color.priceStarter
        {
            let step = number * priceStep
            return priceStarter + step
        }
        return nil
    }
    
    var prize:Int {
        if rawValue.contains("win") {
            return 100
        }
        if rawValue.contains("tax") {
            return -100
        }
        return 0
    }
    
    var color:ColorType? {
        ColorType.allCases.first(where: {
            self.rawValue.lowercased().contains($0.rawValue.lowercased())
        })
    }
    
    enum ColorType:String, CaseIterable {
        case none
        case brawn, blue, pink, orange, red, yellow, green, purpure
        var color:Color {
            switch self {
            case .none:
                    .white
            case .brawn:
                    .brown
            case .blue:
                    .blue
            case .pink:
                    .pink
            case .orange:
                    .orange
            case .red:
                    .red
            case .yellow:
                    .yellow
            case .green:
                    .green
            case .purpure:
                    .purple
            }
        }
        var priceStarter:Int? {
            switch self {
            case .brawn:60
            case .blue:100
            case .pink:140
            case .orange:160
            case .red:220
            case .yellow:260
            case .green:300
            case .purpure:350
            default:nil
            }
        }
        var priceStep:Int? {
            switch self {
            case .brawn: 10
            case .blue, .pink: 20
            case .orange:30
            case .red:35
            case .yellow: 40
            case .green:35
            case .purpure:50
            default:nil
            }
        }
    }
}

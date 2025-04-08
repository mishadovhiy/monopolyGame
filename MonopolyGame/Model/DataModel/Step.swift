//
//  Step.swift
//  MonopolyGame
//
//  Created by Mykhailo Dovhyi on 03.04.2025.
//

import SwiftUI

struct PlayerStepModel:Codable {
    var playerPosition:Step
    private var boughtDictionary:[String:Upgrade] = .testData3
    //[brawn1:none] //test brawn1, then:brawn2 (brawn1 should be false)
    //[brawn2:brawn1]
    init(playerPosition: Step) {
        self.playerPosition = playerPosition
    }
    var bought:[Step:Upgrade] {
        get {
            let dict = self.boughtDictionary.map { (key, value) in
                (Step(rawValue: key) ?? .blue1, value)
            }
            return Dictionary(uniqueKeysWithValues: dict)
        }
        set {
            let array = newValue.map { (key, value) in
                (key.rawValue, value)
            }
            self.boughtDictionary = Dictionary(uniqueKeysWithValues: array)
        }
    }
    func canUpdatePropery(_ property:Step) -> Bool {
        let color = property.color
        let all = Step.allCases.filter({$0.color == color})
        let bought = bought.keys.filter({$0.color == color})
        if bought.isEmpty {
            print("canbuy1")

            return true
        }
        var canBuy:[Bool] = []
        bought.forEach { key in
            let i = self.bought[key]?.index ?? 0
            print(i)
            if i >= (self.bought[property]?.index ?? 0) {
                print("canbuy")
                canBuy.append(true)
            } else {
                canBuy.append(false)
            }
        }
        print("bought: ", bought.count, " / ", all.count)
        if !bought.contains(property) {
            return true
        }
        if all.count == bought.count {
            return !canBuy.contains(false)
        }
        return false
    }
    
    enum Upgrade:String, Codable, CaseIterable {
        case bought, smallest, small, bellowMiddle, middle, higherMiddle, bellowLarge, large, largest
        
        var index:Int {
            Upgrade.allCases.firstIndex(of: self) ?? 0
        }
        
        var nextValue:Upgrade? {
            Upgrade.allCases.first(where: {(index + 1) == $0.index})
        }
    }
}

enum Step:String, Codable, CaseIterable {
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
    
    var index:Int {
        Step.allCases.firstIndex(of: self) ?? 0
    }
    
    static func +=(lh:Step, rh:Int) -> Step {
        Step.allCases.first(where: {
            rh == $0.index
        }) ?? .go
    }
    
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


// MARK: - Test
extension [String:PlayerStepModel.Upgrade] {
    static var testData1:Self {
        [
            Step.brawn1.rawValue:.bought,//can upgrade brawn1
            Step.brawn2.rawValue:.smallest//cannot upgared brawn2
        ]
    }
    static var testData2:Self {
        [
//            Step.brawn1.rawValue:.bought,//can buy brawn1
            Step.brawn2.rawValue:.bought//cannot upgared brawn2
        ]
    }
    
    static var testData3:Self {
        [
//            Step.brawn1.rawValue:.bought,//can buy brawn1
            Step.blue1.rawValue:.bought//cannot upgared brawn2
        ]
    }
}

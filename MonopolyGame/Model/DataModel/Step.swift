//
//  Step.swift
//  MonopolyGame
//
//  Created by Mykhailo Dovhyi on 03.04.2025.
//

import SwiftUI

enum Step:String, Codable, CaseIterable {
    case go
    case chest1
    case tax1
    case brawn1, brawn2
    case transportGrey1
    case blue1, blue2
    case chance1, blue3
    case jail1
    case pink1
    case singlePopertyClear1
    case pink2, pink3
    case transportGrey2
    case orange1
    case chest2
    case orange2, orange3
    case parking
    case chance2
    case red1, red2, red3
    #warning("implement: buy when color == nil")
    case transportGrey3
    case yellow1, yellow2
    case win1
    case yellow3
    #warning("implement: go to chail 1")
    case jail2
    case green1, green2
    case chest3
    case green3
    case transportGrey4
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
        let s = section * numberOfItemsInSection
        let range = (s..<(numberOfItemsInSection + s))
        let array = Array(Step.allCases)
        if array.count  >= range.upperBound {
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
    
    var image:ImageResource? {
        return .propery
    }
    
    var isChance:Bool {
        rawValue.contains("chance")
    }
    var isChest:Bool {
        rawValue.contains("chest")
    }
    
    var title:String {
        switch self {
        case .go:
            "GO"
        case .chest1:
            rawValue
        case .tax1:
            rawValue
        case .brawn1:
            "Mediterranean Ave"
        case .brawn2:
            "Baltic Ave"
        case .transportGrey1:
            "Reading Railroad"
        case .blue1:
            "Oriental Ave"
        case .blue2:
            "Vermont Ave"
        case .chance1:
            rawValue
        case .blue3:
            "Connecticut Ave"
        case .jail1:
            rawValue
        case .pink1:
            "St. Charles Pal"
        case .singlePopertyClear1:
            "Electric Company"
        case .pink2:
            "States Ave"
        case .pink3:
            "Virginia Ave"
        case .transportGrey2:
            "Pennsylvania Railroad"
        case .orange1:
            "St. James Ave"
        case .chest2:
            rawValue
        case .orange2:
            "Tennessee Ave"
        case .orange3:
            "New York Ave"
        case .parking:
            rawValue
        case .chance2:
            rawValue
        case .red1:
            "Kentucky Ave"
        case .red2:
            "Indiana Ave"
        case .red3:
            "Illinois Ave"
        case .transportGrey3:
            "B&O Railroad"
        case .yellow1:
            "Atlantic Ave"
        case .yellow2:
            "Ventnor Ave"
        case .win1:
            rawValue
        case .yellow3:
            "Marvin Gardens"
        case .jail2:
            rawValue
        case .green1:
            "Pacific Ave"
        case .green2:
            "North Carolina Avenue"
        case .chest3:
            rawValue
        case .green3:
            "Pennsylvania Ave"
        case .transportGrey4:
            "Short Line Railroad"
        case .chance3:
            rawValue
        case .purpure1:
            "Park Pal"
        case .tax2:
            rawValue
        case .purpure2:
            "Boardwalk"
        }
    }
    
    var backgroundImage:ImageResource? {
        switch self {
        case .jail1:.jail
        case .jail2:.gavel
        case .parking:.parking
        case .singlePopertyClear1:.idea
        case .transportGrey1, .transportGrey2, .transportGrey3, .transportGrey4:.train
        case .tax1:.water
        case .tax2:.water
        case .go:.start
        case .chance1, .chance2, .chance3: .question
        case .chest1, .chest2, .chest3: .chest
        case .win1:.star
        default:nil
        }
    }
    
    enum FontSize {
        case small, medium, large
        var fontSize:CGFloat {
            switch self {
            case .small:
                5
            case .medium:
                15
            case .large:
                24
            }
        }
    }
    
    func attributedTitle(_ size:FontSize) -> AttributedString {
        let suffs = ["Ave", "Pal"]
        var title = self.title
        var suffix:String = ""
        suffs.forEach({
            if title.contains($0) {
                suffix = $0
                title = title.replacingOccurrences(of: $0, with: "")
            }
        })
        var result = AttributedString(title, attributes: .init([
            .font:UIFont.systemFont(ofSize: size.fontSize)
        ]))
        result.append(AttributedString(suffix, attributes: .init([
            .font:UIFont.systemFont(ofSize: size.fontSize, weight:.bold)
        ])))
        return result
    }

    private var rent:Int? {
        guard let buyPrice else {
            return nil
        }
        return buyPrice / 8
    }
    
    var morgage:Int? {
        (buyPrice ?? 0) / 2
    }
    
    func rentTotal(_ type:PlayerStepModel.Upgrade) -> Int? {
        Int((type.multiplier * 15) * CGFloat(self.rent ?? 0))
    }

    func upgradePrice(_ type:PlayerStepModel.Upgrade) -> Int {
        if self.color == .grey {
            return 0
        } else {
            return Int((type.multiplier * 2) * CGFloat(self.buyPrice ?? 0))
        }
    }
    
    enum ColorType:String, CaseIterable {
        case none
        case brawn, blue, pink, orange, red, yellow, green, purpure, grey, clear
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
            case .grey:
                    .lightsecondaryBackground
            case .clear:
                    .lightContainer
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
            case .green:320
            case .purpure:400
            case .grey:200
            case .clear:350
            case .none:nil
            }
        }
        var priceStep:Int? {
            switch self {
            case .brawn: 10
            case .blue, .pink: 20
            case .orange:30
            case .red:35
            case .yellow: 50
            case .green:55
            case .purpure:80
            case .grey: 0
            case .clear:50
            case .none:nil
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

extension PlayerStepModel.BoughtUpgrades {
    var totalPrice:(propertyCount: Int, price:Int) {
        let price = self.reduce(0) { partialResult, dict in
            let upgrades = PlayerStepModel.Upgrade.allCases.filter({dict.value.index >= $0.index}).reduce(0) { partialResult, upg in
                partialResult + dict.key.upgradePrice(upg)
            }
            return partialResult + ((dict.key.buyPrice ?? 0) + upgrades)
        }
        return (self.count, price)
    }
}

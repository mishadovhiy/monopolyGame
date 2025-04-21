//
//  PlayerStepModel.swift
//  MonopolyGame
//
//  Created by Mykhailo Dovhyi on 17.04.2025.
//

import Foundation

struct PlayerStepModel:Codable {
    var edited = false
    var id:UUID = .init()
    var specialCards:[BoardCard.PlayerSpecialCard] = []
    var playerPosition:Step {
        didSet {
            edited = true
        }
    }
    var inJail = false
    private var boughtDictionary:[String:Upgrade] = [:]
    {
        didSet {
            edited = true
        }
    }
    //[brawn1:none] //test brawn1, then:brawn2 (brawn1 should be false)
    //[brawn2:brawn1]
    init(playerPosition: Step = .go) {
        self.playerPosition = playerPosition
    }
    var morgageProperties:[Step] = []
    {
        didSet {
            edited = true
        }
    }
    var balance:Int = 1000
    {
        didSet {
            edited = true
        }
    }
    typealias BoughtUpgrades = [Step:Upgrade]
    var bought:BoughtUpgrades {
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
    
    mutating func buyIfCan(_ step:Step, price:Int? = nil) {
        if canBuy(step, price: price) {
            balance -= (price ?? (step.buyPrice ?? 0))
            bought.updateValue(.bought, forKey: step)
        } else {
            print("fatalerrorcannotbuy ")
        }
        print(bought, " htyrgtefd ")
    }
    
    func canBuy(_ step:Step, price:Int? = nil) -> Bool {
        (balance >= (price ?? (step.buyPrice ?? 0))) && bought[step] == nil
    }
    
    mutating func upgradePropertyIfCan(_ property:Step) {
        if canUpdateProperty(property) {
            if let next = self.bought[property]?.nextValue {
                if property.upgradePrice(next) <= self.balance {
                    self.bought.updateValue(next, forKey: property)
                    self.balance -= property.upgradePrice(next)
                }
            }
        }
    }
    
    func canUpdateProperty(_ property:Step, balance:Int? = nil) -> Bool {
        if let next = bought[property]?.nextValue,
           property.upgradePrice(next) == 0 {
            return false
        }
        if canUpdateProperyContains(property) {
            if let next = self.bought[property]?.nextValue {
                if property.upgradePrice(next) <= (balance ?? self.balance) {
                    return true
                }
                print("not enought balance ", property.rawValue)
                return false
            } else {
                print("maximum reached ", property.rawValue)
                return false
            }
        }
        return false
    }
    
    private func canUpdateProperyContains(_ property:Step) -> Bool {
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
        
        var previousValue:Upgrade? {
            Upgrade.allCases.first(where: {(index - 1) == $0.index})
        }
        
        var multiplier:CGFloat {
            0.2 + CGFloat(CGFloat(index) / 10)
        }
    }
}

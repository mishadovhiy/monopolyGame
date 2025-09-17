//
//  RobotManager.swift
//  MonopolyGame
//
//  Created by Mykhailo Dovhyi on 17.09.2025.
//

import Foundation

class RobotManager: ObservableObject {
    
    @Published var messages: MultiplierManager.ActionUnparcer?
    private let coreMLModel: CoreMLManager = .init()
    private var enemyMorgagedBalance = false
    private var delayedAction: [DelayedAction] = [] {
        didSet {
            print(delayedAction, " yh5tgerfwdas ")
            if delayedAction.isEmpty {
                self.messages = .init(value: "", key: .robotCompletedPredictions)
            }
        }
    }
        
    func action(action: MultiplierManager.ActionUnparcer) {
        switch action.key {
        case .robotIncreesBalancePrediction:
            delayedAction.append(.increesBalance)
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(randomDelayList.randomElement()!), execute: { [weak self] in
                self?.increeseBalance(action: action)
            })
            
        case .roboBuyOrAuctionPrediction:
            delayedAction.append(.buyOrAuction)
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(randomDelayList.randomElement()!), execute: { [weak self] in
                self?.buyOrAuctionPrediction(action: action)
            })
        case .robotUpgradePropertiesPrediction:
            delayedAction.append(.upgradeProperty)
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(randomDelayList.randomElement()!), execute: { [weak self] in
                self?.canUpgradeProperties(action)
            })
            
        case .auctionBetValue:
            self.placeBet(action: action)
            
        default: break
        }
    }
    
    func increeseBalance(action: MultiplierManager.ActionUnparcer) {
        var data: PlayerStepModel = .configure(action.data)!
        if data.balance <= 250 && !enemyMorgagedBalance {
            enemyMorgagedBalance = true
            sellOrMorgagePrediction(minMorgage: 250, enemyPosition: &data)
        } else {
            self.delayedAction.removeAll(where: {
                $0 == .increesBalance
            })
            enemyMorgagedBalance = false
        }
        if data.balance <= 0 {
            self.sellOrMorgagePrediction(enemyPosition: &data)
        }
        enemyMorgagedBalance = false
    }
    
    private func sellOrMorgagePrediction(minMorgage:Int = 0, enemyPosition: inout PlayerStepModel) {
        if enemyPosition.balance >= 0 && minMorgage == 0 {
            self.delayedAction.removeAll(where: {
                $0 == .increesBalance
            })
            return
        }
        enemyPosition.bought.forEach { (key: Step, value: PlayerStepModel.Upgrade) in
            if enemyPosition.balance < minMorgage {
                if let price = key.morgage,
                   value == .bought,
                   !enemyPosition.morgageProperties.contains(key) {
                    if minMorgage == 0 {
                        enemyPosition.morgageProperties.append(key)
                        enemyPosition.balance += price
                    } else if enemyPosition.canUpdateProperty(key, balance: minMorgage != 0 ? minMorgage : nil) {
                        enemyPosition.morgageProperties.append(key)
                        enemyPosition.balance += price
                    }
                    
                }
            }
        }
        var canRepeat = false
        if enemyPosition.balance < 0 {
            enemyPosition.bought.forEach { (key: Step, value: PlayerStepModel.Upgrade) in
                if enemyPosition.balance < 0 && !enemyPosition.morgageProperties.contains(key) {
                    if let price = key.buyPrice,
                       let prev = value.previousValue,
                       value != .bought {
                        enemyPosition.balance += (price / 2)
                        enemyPosition.bought.updateValue(prev, forKey: key)
                        canRepeat = true
                    }
                    if value == .bought {
                        canRepeat = true
                    }
                }
            }
        }
        if minMorgage == 0 {
            if enemyPosition.balance < 0 && !canRepeat {
                self.messages = .init(value: "", key: .robotLostGame)
            } else if enemyPosition.balance <= 0 && canRepeat {
                self.sellOrMorgagePrediction(enemyPosition: &enemyPosition)
            } else {
                sendRobotUpdate(enemyPosition)
            }
        } else {
            sendRobotUpdate(enemyPosition)
        }
        self.delayedAction.removeAll(where: {
            $0 == .increesBalance
        })
    }
    
    private func sendRobotUpdate(_ enemyPosition: PlayerStepModel) {
        self.messages = .init(value: "\(enemyPosition.balance)", key: .playerBalance)
        self.messages = .init(value: "", key: .playerMorgage, data: enemyPosition.morgageProperties.decode)
        self.messages = .init(value: "", key: .boughtPlayerProperties, data: enemyPosition.bought.decode)
    }
    
    private func setBetDeclined() {
        self.messages = .init(value: "", key: .auctionBetValue)
    }
    
    private func canUpgradeProperties(_ action: MultiplierManager.ActionUnparcer) {
        let players: [PlayerStepModel] = .configure(action.data)!
        var enemy = players.first!
        let player = players.last!
        
        let upgrades = enemy.bought.filter {
            enemy.canUpdateProperty($0.key)
        }.sorted(by: {$0.key.upgradePrice($0.value) >= $1.key.upgradePrice($1.value)})
        let maxUpgradeCountPerMove = 4
        var upgradedCount = 0
        var upgraded = false
        upgrades.forEach { (key: Step, value: PlayerStepModel.Upgrade) in
            if let next = value.nextValue,
               enemy.balance >= key.upgradePrice(next),
               maxUpgradeCountPerMove >= upgradedCount
            {
                let mlResponse = coreMLModel.predictAction(.init(type: .upgradeSkip(.configure(player, enemy, step: key)), base: .configure(enemy, player)))
                switch mlResponse {
                case .upgradeSkip(let skip):
                    if skip == .upgrade {
                        upgradedCount += 1
                        enemy.upgradePropertyIfCan(key)
                        upgraded = true
                        print("enemy upgrading property")
                    }
                default:break
                }
            }
        }
        DispatchQueue.main.async {
            if upgraded {
                self.sendRobotUpdate(enemy)
                self.delayedAction.removeAll(where: {
                    $0 == .upgradeProperty
                })
            } else {
                self.delayedAction.removeAll(where: {
                    $0 == .upgradeProperty
                })
            }
        }
    }
    
    private func buyOrAuctionPrediction(action: MultiplierManager.ActionUnparcer) {
        let players: [PlayerStepModel] = .configure(action.data)!
        var enemy = players.first!
        let player = players.last!
        let property: Step = .init(rawValue: action.value)!
        if enemy.canBuy(property) {
            let request = coreMLModel.predictAction(.init(type: .buyAuction(.configure(property)), base: .configure(enemy, player)))
            switch request {
            case .buyAuction(let results):
                if results == .upgrade {
                    enemy.buyIfCan(property)
                    self.sendRobotUpdate(enemy)
                    self.delayedAction.removeAll(where: {
                        $0 == .buyOrAuction
                    })
                } else {
                    self.messages = .init(value: property.rawValue, key: .auctionBetValue, additionalValue: "100")
                    self.delayedAction.removeAll(where: {
                        $0 == .buyOrAuction
                    })
                }
            default:
                self.messages = .init(value: property.rawValue, key: .auctionBetValue, additionalValue: "100")
                self.delayedAction.removeAll(where: {
                    $0 == .buyOrAuction
                })
            }
        } else {
            self.messages = .init(value: property.rawValue, key: .auctionBetValue, additionalValue: "100")
            self.delayedAction.removeAll(where: {
                $0 == .buyOrAuction
            })
        }
    }
    
    private func placeBet(action: MultiplierManager.ActionUnparcer?) {
        let players: [PlayerStepModel] = .configure(action?.data)!
        let enemy = players.first!
        let player = players.last!
        let property: Step = .init(rawValue: action?.value ?? "")!
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds((250..<3000).randomElement() ?? 0), execute: {
            let last = Int(action?.additionalValue ?? "") ?? 0
            
            let differenceBalance = enemy.balance - last
            if differenceBalance <= 2 {
                self.setBetDeclined()
                return
            }
            var difference = last - (property.buyPrice ?? 0)
            if difference <= 2 {
                difference = differenceBalance
                if [false, false, false, false, false, true, false, false, true].randomElement() ?? false {
                    self.setBetDeclined()
                    return
                }
            }
            if difference <= 2 {
                self.setBetDeclined()
                return
            }
            let newBet = last + Int.random(in: 1..<difference)
            if newBet <= enemy.balance {
                let results = self.coreMLModel.predictAction(.init(type: .continiueBetting(.init(opponentBet: Double(last), playerBet: Double(newBet))), base: .configure(enemy, player)))
                switch results {
                case .continiueBetting(let response):
                    if response == .true {
                        self.messages = .init(value: property.rawValue, key: .auctionBetValue, additionalValue: "\(newBet)")
                    } else {
                        self.setBetDeclined()
                    }
                default:
                    self.setBetDeclined()
                }
            } else {
                self.setBetDeclined()
            }
            
        })
    }
    
    private var randomDelayList: [Int] = [300, 350, 500, 400, 450, 1000, 1300, 1200, 800, 700, 4000, 3000, 500, 900, 1500, 1500, 1800, 1900]

}

extension RobotManager {
    fileprivate enum DelayedAction: CaseIterable {
        case buyOrAuction
        case upgradeProperty
        case increesBalance
    }
}

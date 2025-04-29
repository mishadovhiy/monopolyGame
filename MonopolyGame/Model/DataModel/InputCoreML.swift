//
//  InputCoreML.swift
//  MonopolyGame
//
//  Created by Mykhailo Dovhyi on 29.04.2025.
//

import Foundation

extension CoreMLManager {
    enum Output {
        
        case upgradeSkip(UpgradeSkip)
        case buyAuction(BuyAuction)
        case continiueBetting(ContiniueBetting)
        
        enum ContiniueBetting:String {
            case skip,`true`
        }
        
        enum BuyAuction:String {
            case upgrade, skip
        }
        
        enum UpgradeSkip:String {
            case upgrade, skip
        }
    }
    
    struct Input:Codable {
        var type:MLProject
        var base:BaseInput
        /// string value should be same as .mlmodel project name
        enum MLProject:Codable {
            case upgradeSkip(UpgradeSkip)
            case buyAuction(BuyAction)
            case continiueBetting(ContiniueBetting)
            var data:ProjectProtocol {
                switch self {
                case .upgradeSkip(let data):
                    data
                case .buyAuction(let data):
                    data
                case .continiueBetting(let data):
                    data
                }
            }
        }
        /// same properties in all ML projects
        struct BaseInput: Codable {
            var playerBalance: Double
            var playerProperties: Double
            var playerHouses: Double
            var opponentBalance: Double
            var opponentProperties: Double
            var freeProperties: Double
            
            static func configure(_ enemy:PlayerStepModel, _ player:PlayerStepModel) -> Self {
                let enemyBought = Double(enemy.bought.count)
                let playerBought = player.bought
                let freeProperties = Step.allCases.filter({$0.buyPrice != 0}).count - (playerBought.count + Int(enemyBought))
                return .init(playerBalance: Double(enemy.balance), playerProperties: enemyBought, playerHouses: Double(enemy.bought.filter({$0.value.index >= 1}).count), opponentBalance: Double(player.balance), opponentProperties: Double(playerBought.count), freeProperties: Double(freeProperties))
            }
        }
        
        var mlDictionary:[String:Any]? {
            var dictionary = self.base.dictionary
            self.type.data.dictionary?.forEach { (key: String, value: Any) in
                dictionary?.updateValue(value, forKey: key)
            }
            return dictionary
        }
    }

}


extension CoreMLManager.Input.MLProject {
    struct BuyAction:ProjectProtocol {
        var properyPrice:Double
        
        static func configure(_ step: Step) -> Self {
            .init(properyPrice: Double(step.buyPrice ?? 0))
        }
    }
    
    struct UpgradeSkip:ProjectProtocol {
        var upgradePrice:Double
        var colorPropertiesBoughtCount:Double
        
        static func configure(_ player:PlayerStepModel, _ enemy:PlayerStepModel, step:Step) -> Self {
            let bought = enemy.bought.filter({$0.key.color == step.color}).count
            return self.init(upgradePrice: Double(step.buyPrice ?? 0), colorPropertiesBoughtCount: Double(bought))
        }
    }
    
    struct ContiniueBetting:ProjectProtocol {
        var opponentBet:Double
        var playerBet:Double
    }
    
    protocol ProjectProtocol:Codable {
        
    }
}

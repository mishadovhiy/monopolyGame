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
            case skip, upgrade
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
            var player_balance: Double
            var player_properties: Double
            var player_houses: Double
            var opponent_balance: Double
            var opponent_properties: Double
            var free_properties: Double
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
    }
    
    struct UpgradeSkip:ProjectProtocol {
        var upgradePrice:Double
        var colorPropertiesBoughtCount:Double
    }
    
    struct ContiniueBetting:ProjectProtocol {
        var opponentBet:Double
        var playerBet:Double
    }
    
    protocol ProjectProtocol:Codable {
        
    }
}

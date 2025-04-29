//
//  CoreMLManager.swift
//  MonopolyGame
//
//  Created by Mykhailo Dovhyi on 29.04.2025.
//

import CoreML

struct CoreMLManager {
    private func model(_ input:Input) -> MLModel? {
        switch input.type {
        case .upgradeSkip(_):
            return try? UpgradeSkipModel(configuration: MLModelConfiguration()).model
            
        case .buyAuction(_):
            return try? BuyAuctionModel(configuration: MLModelConfiguration()).model
            
        case .continiueBetting(_):
            return try? ContiniueBettingModel(configuration: MLModelConfiguration()).model
        }
    }
    
    func predictAction(_ inputData:Input) -> Output? {
        do {
            let input = try MLDictionaryFeatureProvider(dictionary: inputData.mlDictionary ?? [:])
            let prediction = try self.model(inputData)?.prediction(from: input)
            
            if let action = prediction?.featureValue(for: "action")?.stringValue, !action.isEmpty {
                print("Recommended action: \(action)")
                switch inputData.type {
                case .upgradeSkip(let upgradeSkip):
                    return .upgradeSkip(.init(rawValue: action)!)
                case .buyAuction(let buyAction):
                    return .buyAuction(.init(rawValue: action)!)

                case .continiueBetting(let continiueBetting):
                    return .continiueBetting(.init(rawValue: action)!)

                }
            } else {
                return nil
            }
            
        } catch {
            print("Prediction error: \(error)")
            return nil
        }
    }
}

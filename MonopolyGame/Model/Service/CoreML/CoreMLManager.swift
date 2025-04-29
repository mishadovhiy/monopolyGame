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
        case .upgradeSkip(let upgradeSkip):
            try? buyPrediction(configuration: MLModelConfiguration()).model
        case .buyAuction(let buyAction):
            try? buyPrediction(configuration: MLModelConfiguration()).model
        case .continiueBetting(let continiueBetting):
            try? buyPrediction(configuration: MLModelConfiguration()).model
        }
    }
    
    func predictAction(_ inputData:Input) -> Output? {
        do {
            let model = try buyPrediction(configuration: MLModelConfiguration())
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

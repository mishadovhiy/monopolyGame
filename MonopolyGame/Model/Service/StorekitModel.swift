//
//  StorekitModel.swift
//  MonopolyGame
//
//  Created by Mykhailo Dovhyi on 14.04.2025.
//

import StoreKit

struct StorekitModel {
    func requestReview() {
        if let windowScene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene
        {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }

    static func needAdd(db: inout AppData.DataBase) -> Bool {
        let max = min(db.playDateCount, 25)
        let divider = 25//max > //10 ? (10 - (max - 10)) : 25
        if db.adScore >= Int(Double(max / divider) + 3) {
            db.adScore = 0
            return true
        } else {
            db.adScore += Int(1 + Double(max / 100))
            return false
        }
    }
}

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
}

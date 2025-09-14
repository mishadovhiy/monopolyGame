//
//  Trade.swift
//  MonopolyGame
//
//  Created by Mykhailo Dovhyi on 21.04.2025.
//

import Foundation

extension GameViewModel {
    struct Trade: Codable {
        var myPlayerProperties:[Step] = []
        var enemyProperties:[Step] = []
        var tradeAmount:Float = 0
        var isPresenting:Bool = false {
            didSet {
                tradeAmount = 0
            }
        }
        var tradingByEnemy:Bool = false
        var okEnabled:Bool {
            (tradeAmount != 0 || !myPlayerProperties.isEmpty) && !enemyProperties.isEmpty
        }
        var tradeResponse:Bool? = nil
    }
}

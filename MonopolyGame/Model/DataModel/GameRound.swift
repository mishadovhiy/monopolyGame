//
//  GameRound.swift
//  MonopolyGame
//
//  Created by Mykhailo Dovhyi on 29.04.2025.
//

import Foundation

struct GameRound:Codable {
    var playerRound:Int = 0
    var enemyRound:Int = 0
    var difficulty:Difficulty = .easy

    enum Difficulty:String, Codable {
        case easy
        case medium
        case hard
    }

}

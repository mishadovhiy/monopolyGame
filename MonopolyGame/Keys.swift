//
//  Keys.swift
//  MonopolyGame
//
//  Created by Mykhailo Dovhyi on 14.04.2025.
//

import Foundation

enum Keys:String {
    case appStoreID = "6744718214"
    case gameCenterLeaderboardID = "levelCompletionFusion"
    static var shareAppURL:String = "https://apps.apple.com/app/id\(Keys.appStoreID.rawValue)"
}

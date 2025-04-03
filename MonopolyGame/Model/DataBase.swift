//
//  DataBase.swift
//  MonopolyGame
//
//  Created by Mykhailo Dovhyi on 03.04.2025.
//

import Foundation

struct DataBase:Codable {
    struct Game:Codable {
        var player:Player = .init()
        var robot:Player = .init()
        
        struct Player:Codable {
            var balance:Int = 1000
            
        }
        
    }
}

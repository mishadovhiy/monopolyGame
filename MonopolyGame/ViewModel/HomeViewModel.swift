//
//  HomeViewModel.swift
//  MonopolyGame
//
//  Created by Mykhailo Dovhyi on 13.04.2025.
//

import Foundation

struct HomeViewModel {
    
    mutating func popToRootView() {
        if navigationPresenting.sound {
            navigationPresenting.sound = false
            return
        }
        if navigationPresenting.gameSettings {
            navigationPresenting.gameSettings = false
            return
        }
        navigationPresenting = .init()
    }
    
    var isNavigationPushed:Bool {
        let dict = navigationPresenting.dict
        return dict?.values.contains(true) ?? false
    }
    
    func gameCenterPressed() {
        
    }
    
    func chooseProfileImagePressed() {
        
    }
    
    var isGamePresenting:Bool = false
    var navigationPresenting:NavigationPresenting = .init()
    struct NavigationPresenting:Codable {
        var menu = false
        var sound = false
        var gameSettings = false
        var about = false
        var rate = false
        var share = false
        var leaderBoard = false
        var gameCenter = false
        var profileProtoPicker = false
        var profile = false
        
        var clearGameConfirmation = false
        
        var dict:[String:Bool]? {
            return dictionary as? [String:Bool]
        }
    }
}

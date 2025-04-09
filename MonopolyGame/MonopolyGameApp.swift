//
//  MonopolyGameApp.swift
//  MonopolyGame
//
//  Created by Mykhailo Dovhyi on 03.04.2025.
//

import SwiftUI

@main
struct MonopolyGameApp: App {
    var body: some Scene {
        WindowGroup {
            GameView()
//            PropertyListView(list: Step.allCases.filter({$0.buyPrice != nil}))

        }
    }
}

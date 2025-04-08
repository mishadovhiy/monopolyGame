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
                .onAppear {
                    let model = PlayerStepModel(playerPosition:.blue1)
                    print(model.canUpdatePropery(.brawn1))
                }
        }
    }
}

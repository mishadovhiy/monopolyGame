//
//  SettingsView.swift
//  MonopolyGame
//
//  Created by Mykhailo Dovhyi on 13.04.2025.
//

import SwiftUI

struct GameSettingsView: View {
    @EnvironmentObject var db:AppData
    @Binding var viewModel:HomeViewModel
    
    var body: some View {
        VStack {
            VStack {
                Text("Difficulty")
                Slider(value: $db.db.settings.game.difficulty)
            }
            VStack {
                Text("Balance")
                HStack {
                    HStack {
                        Button("-100") {
                            db.db.settings.game.balance -= 100
                        }
                        Button("-10") {
                            db.db.settings.game.balance -= 10
                        }
                    }
                    .frame(maxWidth: .infinity)
                    Text("\(db.db.settings.game.balance)")
                    HStack {
                        Button("+10") {
                            db.db.settings.game.balance += 10
                        }
                        Button("+100") {
                            db.db.settings.game.balance += 100
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            VStack {
                Button("Clear progress") {
                    viewModel.navigationPresenting.clearGameConfirmation = true
                }
            }
        }
        .background {
            ClearBackgroundView()
        }
        .confirmationDialog("Clear current game", isPresented: $viewModel.navigationPresenting.clearGameConfirmation, actions: {
            Button("Clear current game") {
                db.db.gameProgress = .init()
            }
        }, message: {
            VStack {
                Text("Are you sure, you want to clear progress of your current game? \nThe history of your completed levels will not be cleared")
            }
        })
    }
}

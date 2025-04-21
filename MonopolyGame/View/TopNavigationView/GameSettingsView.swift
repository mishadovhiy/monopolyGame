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
        VStack(spacing:10) {
            VStack(alignment:.leading) {
                Text("Difficulty")
                    .foregroundColor(.secondaryText)
                Slider(value: $db.db.settings.game.difficulty)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            Divider()
            VStack(alignment:.leading, spacing:5) {
                Text("Balance")
                    .foregroundColor(.secondaryText)
                HStack {
                    HStack(spacing:10) {
                        Button("-100") {
                            db.audioManager?.play(.menu)
                            db.db.settings.game.balance -= 100
                        }
                        .padding(.vertical, 2)
                        .padding(.horizontal, 8)
                        .background(.lightsecondaryBackground)
                        .cornerRadius(4)
                        Button("-10") {
                            db.audioManager?.play(.menu)
                            db.db.settings.game.balance -= 10
                        }
                        .padding(.vertical, 2)
                        .padding(.horizontal, 8)
                        .background(.lightsecondaryBackground)
                        .cornerRadius(4)
                    }
                    .frame(maxWidth: .infinity)
                    Text("\(db.db.settings.game.balance)")
                    HStack(spacing:10) {
                        Button("+10") {
                            db.audioManager?.play(.menu)
                            db.db.settings.game.balance += 10
                        }
                        .padding(.vertical, 2)
                        .padding(.horizontal, 8)
                        .background(.lightsecondaryBackground)
                        .cornerRadius(4)
                        Button("+100") {
                            db.audioManager?.play(.menu)
                            db.db.settings.game.balance += 100
                        }
                        .padding(.vertical, 2)
                        .padding(.horizontal, 8)
                        .background(.lightsecondaryBackground)
                        .cornerRadius(4)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            Divider()
            Toggle(isOn: $db.db.settings.game.usingDice) {
                Text("Is using dice 3D Images")
            }
            VStack {
                Button("Clear progress") {
                    db.audioManager?.play(.menu)
                    viewModel.navigationPresenting.clearGameConfirmation = true
                }
                .frame(maxWidth:.infinity)
                .tint(.red)
                .padding(.vertical, 10)
                .background(.red.opacity(0.15))
                .cornerRadius(4)
            }
            Spacer()
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
        .background(.secondaryBackground)

    }
}

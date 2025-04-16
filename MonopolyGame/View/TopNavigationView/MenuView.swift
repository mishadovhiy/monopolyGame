//
//  MenuView.swift
//  MonopolyGame
//
//  Created by Mykhailo Dovhyi on 13.04.2025.
//

import SwiftUI

struct MenuView: View {
    @Binding var viewModel:HomeViewModel
    var body: some View {
        VStack {
            HStack {
                Button("close game") {
                    withAnimation {
                        viewModel.isGamePresenting = false
                        viewModel.popToRootView()
                    }
                }
                Spacer()
            }
            .frame(maxHeight: viewModel.isGamePresenting ? 40 : 0)
            .clipped()
            .animation(.bouncy, value: viewModel.isGamePresenting)
            VStack {
                HStack {
                    NavigationLink(destination: SoundSettingsView(viewModel: $viewModel), isActive: .init(get: {
                        viewModel.navigationPresenting.sound
                    }, set: { new in
                        withAnimation(.bouncy) {
                            viewModel.navigationPresenting.sound = new
                        }
                    })) {
                        Text("Sound")
                    }
                    NavigationLink(destination: GameSettingsView( viewModel: $viewModel), isActive: .init(get: {
                        viewModel.navigationPresenting.gameSettings
                    }, set: { new in
                        withAnimation {
                            viewModel.navigationPresenting.gameSettings = new
                        }
                    })) {
                        Text("Game Settings")
                    }
                    .frame(maxHeight: viewModel.isGamePresenting ? 0 : .infinity)
                    .animation(.bouncy, value: viewModel.isGamePresenting)
                }
                HStack {
                    NavigationLink(destination: AboutView(), isActive: $viewModel.navigationPresenting.about) {
                        Text("About")
                    }
                    Button {
                        StorekitModel().requestReview()
                    } label: {
                        Text("Rate")
                    }
                    Button {
                        viewModel.navigationPresenting.share = true
                    } label: {
                        Text("Share App")
                    }

                }
            }
        }
        .background {
            ClearBackgroundView()
        }
    }
}


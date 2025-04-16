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
                            .padding(.horizontal, 15)
                            .padding(.vertical, 5)
                            .background(.lightsecondaryBackground)
                            .cornerRadius(4)

                    }
                    NavigationLink(destination: GameSettingsView( viewModel: $viewModel), isActive: .init(get: {
                        viewModel.navigationPresenting.gameSettings
                    }, set: { new in
                        withAnimation {
                            viewModel.navigationPresenting.gameSettings = new
                        }
                    })) {
                        Text("Game Settings")
                            .padding(.horizontal, 15)
                            .padding(.vertical, 5)
                            .background(.lightsecondaryBackground)
                            .cornerRadius(4)

                    }
                    .frame(maxHeight: viewModel.isGamePresenting ? 0 : .infinity)
                    .animation(.bouncy, value: viewModel.isGamePresenting)
                    .clipped()
                    Button("close game") {
                        withAnimation {
                            viewModel.isGamePresenting = false
                            viewModel.popToRootView()
                        }
                    }
                    .padding(.horizontal, 15)
                    .padding(.vertical, 5)
                    .background(.lightsecondaryBackground)
                    .cornerRadius(4)
                    .frame(maxWidth: viewModel.isGamePresenting ? 80 : 0)
                    .clipped()
                    .animation(.smooth, value: viewModel.isGamePresenting)
                    Spacer()
                }
                HStack {
                    NavigationLink(destination: AboutView(), isActive: $viewModel.navigationPresenting.about) {
                        Text("About")
                            .padding(.horizontal, 15)
                            .padding(.vertical, 5)
                            .background(.lightsecondaryBackground)
                            .cornerRadius(4)

                    }
                    Button {
                        StorekitModel().requestReview()
                    } label: {
                        Text("Rate")
                            .padding(.horizontal, 15)
                            .padding(.vertical, 5)
                            .background(.lightsecondaryBackground)
                            .cornerRadius(4)
                    }
                    Button {
                        viewModel.navigationPresenting.share = true
                    } label: {
                        Text("Share App")
                            .padding(.horizontal, 15)
                            .padding(.vertical, 5)
                            .background(.lightsecondaryBackground)
                            .cornerRadius(4)

                    }
Spacer()
                }
            }
            Spacer()
        }
        .background {
            ClearBackgroundView()
        }
    }
}


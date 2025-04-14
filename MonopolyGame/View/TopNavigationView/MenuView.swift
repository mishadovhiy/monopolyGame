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
            NavigationLink(destination: SoundSettingsView(viewModel: $viewModel), isActive: $viewModel.navigationPresenting.sound) {
                Text("Sound")
            }
        }
        .navigationBarHidden(true)
        .background {
            ClearBackgroundView()
        }
    }
}


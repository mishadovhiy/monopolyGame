//
//  TopNavigationView.swift
//  MonopolyGame
//
//  Created by Mykhailo Dovhyi on 13.04.2025.
//

import SwiftUI

struct TopNavigationView: View {
    @Binding var viewModel:HomeViewModel
    var body: some View {
        HStack {
            VStack {
                Button(viewModel.isGamePresenting ? "Resume game" : "back") {
                    withAnimation {
                        viewModel.popToRootView()
                    }
                }
                .frame(maxWidth: viewModel.isNavigationPushed ? 30 : 0)
                .clipped()
                .animation(.bouncy, value: viewModel.isNavigationPushed)
                Spacer()
            }
            
            NavigationView {
                HStack {
                    Spacer()
                    NavigationLink(destination: MenuView(viewModel: $viewModel), isActive: $viewModel.navigationPresenting.menu) {
                        Text("Menu")
                    }
                    NavigationLink("", destination: LeaderboardView(viewModel: $viewModel), isActive: $viewModel.navigationPresenting.leaderBoard)
                }
                .padding(.horizontal, 15)
                .padding(.vertical, 5)
                .background {
                    ClearBackgroundView()
                }
                .navigationBarHidden(true)
            }
            .navigationBarHidden(true)
            .navigationViewStyle(StackNavigationViewStyle())
            .background {
                ClearBackgroundView()
            }
        }
        .frame(maxHeight: viewModel.isNavigationPushed ? .infinity : 85)

        .background(.red)
        .cornerRadius(12)
        .padding(.top, viewModel.isGamePresenting ? 5 : 0)
        .animation(.smooth, value: viewModel.isGamePresenting)
    }
}

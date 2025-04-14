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
            NavigationView {
//                VStack(content: {
                    HStack {
                        NavigationLink(destination: ProfileView(viewModel: $viewModel), isActive: $viewModel.navigationPresenting.profile) {
                            Text("Profile")
                        }
                        Spacer()
                        NavigationLink(destination: MenuView(viewModel: $viewModel), isActive: $viewModel.navigationPresenting.menu) {
                            Text("Menu")
                        }
                        NavigationLink("", destination: LeaderboardView(viewModel: $viewModel), isActive: $viewModel.navigationPresenting.leaderBoard)
                    }

//                })
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
        .overlay(content: {
            VStack {
                HStack {
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
                Spacer()
            }
        })
        .background(.red)
        .cornerRadius(12)
        .padding(.top, viewModel.isGamePresenting ? 5 : 0)
        .animation(.smooth, value: viewModel.isGamePresenting)
        .sheet(isPresented: $viewModel.navigationPresenting.share, content: {ShareSheet(items: [Keys.shareAppURL])})
    }
}

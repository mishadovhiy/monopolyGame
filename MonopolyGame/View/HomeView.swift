//
//  HomeView.swift
//  MonopolyGame
//
//  Created by Mykhailo Dovhyi on 13.04.2025.
//

import SwiftUI

struct HomeView: View {
    @State var viewModel:HomeViewModel = .init()
    var body: some View {
        NavigationView(content: {
            VStack {
                Spacer()
                    .frame(maxHeight: .infinity)
                Button("Play") {
                    viewModel.isGamePresenting = true
                }
                VStack {
                    Spacer()
                        .frame(maxHeight: .infinity)

                    HStack {
                        Spacer()
                        Button("Leaderboard") {
                            withAnimation {
                                viewModel.navigationPresenting.leaderBoard = true
                            }
                        }
                        Spacer()
                    }
                    Spacer()
                        .frame(maxHeight: .infinity)

                }
                .frame(maxHeight: .infinity)
                NavigationLink("", destination: GameView(), isActive: $viewModel.isGamePresenting)
                    .hidden()
                
            }
            
            .navigationViewStyle(StackNavigationViewStyle())
            .background {
                ClearBackgroundView()
            }
        })
        .navigationBarHidden(true)
        .navigationViewStyle(StackNavigationViewStyle())
        .background(.primaryBackground)
        .background {
            ClearBackgroundView()
        }
        .overlay {
            VStack {
                TopNavigationView(viewModel: $viewModel)
                Spacer()
                    .frame(maxHeight: .infinity)
            }
        }
    }
}

#Preview {
    HomeView()
}

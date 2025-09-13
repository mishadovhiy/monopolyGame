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
            GeometryReader(content: { proxy in
                VStack(spacing:30) {
                    Spacer()
                        .frame(maxHeight: .infinity)
                    VStack {
                        Button {
                            viewModel.popToRootView(force: true)
                            viewModel.isGamePresenting = true
                        } label: {
                            Text("Play")
                                .font(.system(size: 32, weight:.black))
                                .padding(.horizontal, 80)
                                .padding(.vertical, 15)
                        }
                        .tint(.white)
                        .background(.green.opacity(0.7))
                        .cornerRadius(50)
                        .shadow(radius: 5)
                        VStack {
                            HStack {
                                Spacer()
                                Button("Leaderboard") {
                                    withAnimation {
                                        viewModel.popToRootView(force: true)
                                        viewModel.navigationPresenting.leaderBoard = true
                                    }
                                }
                                .font(.system(size: 18, weight:.bold))
                                .tint(.light)
                                .padding(10)
                                Spacer()
                            }
                            Spacer()
                                .frame(maxHeight: .infinity)

                        }
                        .frame(maxHeight: .infinity)
                    }
                    NavigationLink("", destination: GameView(isPresenting: $viewModel.isGamePresenting, enemyConnectionType: .bluetooth), isActive: $viewModel.isGamePresenting)
                        .hidden()
                }
                
                .navigationViewStyle(StackNavigationViewStyle())
                .background {
                    if !viewModel.isGamePresenting {
                        SuccessSceneView(viewSize: proxy.size)
                            .ignoresSafeArea(.all)
                    }
                }
                .background(content: {
                    VStack {
                        VStack {
                            Spacer()
                                .frame(maxHeight:.infinity)
                            VStack {
                                Image(.launch)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 185)
                                Spacer()
                                    .frame(maxHeight:.infinity)
                            }
                            Spacer().frame(maxHeight:.infinity)
                        }
                        .frame(maxHeight:.infinity)
                        Spacer()
                            .frame(maxHeight:.infinity)
                    }
                })

            })
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

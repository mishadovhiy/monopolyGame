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
            Button(viewModel.isGamePresenting ? "Resume game" : "back") {
                viewModel.popToRootView()
            }
            .frame(maxWidth: viewModel.isNavigationPushed ? 50 : 0)
            .clipped()
            .animation(.bouncy, value: viewModel.isNavigationPushed)
            
            NavigationView {
                HStack {
                    Spacer()
                    NavigationLink(destination: MenuView(viewModel: $viewModel), isActive: $viewModel.navigationPresenting.menu) {
                        Text("Settings")
                    }

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

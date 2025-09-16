//
//  HomeView.swift
//  MonopolyGame
//
//  Created by Mykhailo Dovhyi on 13.04.2025.
//

import SwiftUI
import UIKit

struct HomeView: View {
    @State var viewModel:HomeViewModel = .init()
    
    var body: some View {
        NavigationView(content: {
            GeometryReader(content: { proxy in
                VStack(spacing:30) {
                    Spacer()
                        .frame(maxHeight: .infinity)
                    VStack(spacing: 20) {
                        playButton
                        leaderBoardButtonView
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
                    backgroundIcon
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
    
    
    @State var animate: Bool = false
    @ViewBuilder
    var playButton: some View {
        Button {
            viewModel.popToRootView(force: true)
            viewModel.isGamePresenting = true
        } label: {
            ZStack(alignment: .center) {

                Text("Play")
                    .font(.system(size: 36, weight: .black))
                    .kerning(5)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.red)
                    .padding(.leading, -3)
                    .shadow(radius: 10)
                HStack(content: {
                    Spacer()
                        .frame(maxWidth: animate ? .infinity : .zero)
                    Color.black.frame(width: 30)
                        .blur(radius: 20)
                    Spacer()
                        .frame(maxWidth: !animate ? .infinity : .zero)
                })
                .animation(.smooth(duration: 3).repeatForever(), value: animate)

                .padding(.horizontal, -20)
                .background(.yellow)
                .frame(height: 50)
                .frame(maxWidth: 180)
                .mask {
                    Text("Play")
                        .font(.system(size: 32, weight: .regular))
                        .kerning(10)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(.vertical, 3)
        }
        .tint(.white)
        .background(.green.opacity(0.85))
        .cornerRadius(50)
        .overlay(content: {
            RoundedRectangle(cornerRadius: 50)
                .stroke(.red, lineWidth: 2)
                .shadow(radius: 10)
        })
        .shadow(radius: 15)
        .onAppear {
                animate.toggle()
        }
    }

    
    var leaderBoardButtonView: some View {
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
    
    var backgroundIcon: some View {
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
    }
}

#Preview {
    HomeView()
}


struct UILabelView: UIViewRepresentable {
    let text: NSAttributedString
    func makeUIView(context: Context) -> UILabel {
        let label = UILabel()
        label.attributedText = text
        label.tintColor = .orange
        label.textColor = .orange
        label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        label.setContentHuggingPriority(.defaultHigh, for: .vertical)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        

        return label
    }
    
    func updateUIView(_ uiView: UILabel, context: Context) {
        uiView.attributedText = text
    }
}

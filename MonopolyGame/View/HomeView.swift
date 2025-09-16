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
                    VStack(spacing: 10) {
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
            Text("Play")
                .font(.system(size: 32, weight: .bold))
                .kerning(2)
                .multilineTextAlignment(.center)
                .blendMode(.destinationOut)
                .padding(.horizontal, 50)
                .padding(.vertical, 8)
        }
        .tint(.white)
        .background(content: {
            ZStack {
                Color(.green).opacity(0.85)

                HStack {
                    Spacer().frame(maxWidth: animate ? .infinity : .zero)
                    Color(.white)
                        .frame(width: 10)
                        .blur(radius: 10)
                    
                    Spacer().frame(maxWidth: !animate ? .infinity : .zero)
                }
                .padding(.horizontal, -15)
            }
            .animation(.smooth(duration: 1.5).repeatForever(autoreverses: false), value: animate)
        })
        .compositingGroup()
        .cornerRadius(50)
        .shadow(radius: 15)
        .onAppear {
                animate.toggle()
        }
    }

    
    var leaderBoardButtonView: some View {
        VStack {
            HStack {
                Spacer()
                Button(action: {
                    withAnimation {
                        viewModel.popToRootView(force: true)
                        viewModel.navigationPresenting.leaderBoard = true
                    }
                }, label: {
                    ZStack(content: {
                        BlurView()
                        Color.white.opacity(0.5)
                        VStack {
                            Spacer().frame(maxHeight: animate ? .infinity : .zero)
                            Color(.white)
                                .frame(height: 5)
                                .blur(radius: 5)
                            
                            Spacer().frame(maxHeight: !animate ? .infinity : .zero)
                        }
                        .padding(.vertical, -15)
                        .animation(.easeInOut(duration: 3.5).repeatForever(), value: animate)

                    })
                        .frame(height: 45)
                        .mask {
                            Text("Leaderboard")
                                .kerning(2)

                        }

                })
                .font(.system(size: 28, weight: .bold))
                .shadow(radius: 10)
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

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
    @EnvironmentObject var db: AppData

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
                    NavigationLink("", destination: GameView(isPresenting: $viewModel.isGamePresenting, enemyConnectionType: viewModel.selectedGameConnectionType ?? .AiRobot), isActive: $viewModel.isGamePresenting)
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
    
    var connectionTypePicker: some View {
        HStack(spacing: viewModel.gameConnectionPresenting ? 10 : 0) {
            ForEach(MultiplierManager.ConnectionType.allCases, id: \.rawValue) { type in
                Button {
                    db.audioManager?.play(.menuPlay)
                    viewModel.popToRootView(force: true)
                    withAnimation {
                        viewModel.selectedGameConnectionType = type
                    }
                } label: {
                    HStack(content: {
                        Image(.init(name: type.iconName, bundle: .main))
                            .resizable()
                            .scaledToFit()
                            .frame(width: 15)
                        Text(type.rawValue.addSpaceBeforeCapitalizedLetters.capitalized)
                            .font(.system(size: 12))
                            .opacity(viewModel.gameConnectionPresenting ? 1 : 0)
                    })
                    .padding(.horizontal, viewModel.gameConnectionPresenting ? 15 : -50)
                        .padding(.vertical, 7)
                        .foregroundColor(.black)
                        .background(.light)
                        .cornerRadius(4)
                    
                        .shadow(radius: 6)
                }

            }
        }
        .frame(maxHeight: viewModel.gameConnectionPresenting ? 35 : 0)
        .clipped()
        .animation(.bouncy, value: viewModel.gameConnectionPresenting)
    }
    
    @ViewBuilder
    var playButton: some View {
        VStack(spacing: viewModel.gameConnectionPresenting ? 10 : -15) {
            connectionTypePicker
            Button {
                db.audioManager?.play(!viewModel.gameConnectionPresenting ? .menuRegular : .menu)
                viewModel.popToRootView(force: true)
                withAnimation {
                    viewModel.gameConnectionPresenting.toggle()
                }
            } label: {
                VStack(spacing: 0, content: {
                    CloseIconPath()
                        .trim(to: viewModel.gameConnectionPresenting ? 1 : 0)
                        .stroke(.black, lineWidth: 2)
                        .blendMode(.destinationOut)

                        .frame(width: viewModel.gameConnectionPresenting ? 40 : 0, height: viewModel.gameConnectionPresenting ?  40 : 0)
                        .animation(.smooth, value: viewModel.gameConnectionPresenting)
                        
                    Text("Play")
                        
                        .font(.system(size: 32, weight: .bold))
                        .kerning(2)
                        .frame(height: viewModel.gameConnectionPresenting ? 0 : 35)
                        .multilineTextAlignment(.center)
                        .blendMode(.destinationOut)
                        .clipped()
                        .animation(.smooth, value: viewModel.gameConnectionPresenting)


                })
                .padding(.horizontal, 50)
                .padding(.vertical, 8)
            }
            .tint(.white)
            .background(content: {
                ZStack {
                    Color(.green).opacity(0.85)
                    animatedBackground(isHorizontal: true)
                }
            })
            .compositingGroup()
            .cornerRadius(50)
            .shadow(radius: 15)
            .onAppear {
                viewModel.animate.toggle()
            }
            .zIndex(2)
        }
        .animation(.bouncy, value: viewModel.gameConnectionPresenting)
    }
    
    @ViewBuilder
    func animatedBackground(isHorizontal: Bool) -> some View {
        if !isHorizontal {
            VStack {
                Spacer().frame(maxHeight: viewModel.animate ? .infinity : .zero)
                Color(.white)
                    .frame(height: 5)
                    .blur(radius: 5)
                
                Spacer().frame(maxHeight: !viewModel.animate ? .infinity : .zero)
            }
            .padding(.vertical, -15)
            .animation(.easeInOut(duration: 3.5).repeatForever(), value: viewModel.animate)
        } else {
            HStack {
                Spacer().frame(maxWidth: viewModel.animate ? .infinity : .zero)
                Color(.white)
                    .frame(width: 10)
                    .blur(radius: 10)
                
                Spacer().frame(maxWidth: !viewModel.animate ? .infinity : .zero)
            }
            .padding(.horizontal, -15)
            .animation(.smooth(duration: 1.5).repeatForever(autoreverses: false), value: viewModel.animate)
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
                        animatedBackground(isHorizontal: false)

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

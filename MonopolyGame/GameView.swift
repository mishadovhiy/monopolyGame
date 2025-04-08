//
//  ContentView.swift
//  MonopolyGame
//
//  Created by Mykhailo Dovhyi on 03.04.2025.
//

import SwiftUI

class GameViewModel:ObservableObject {
    @Published var diceDestination = Step.allCases.count - 1
    @Published var playerPosition:PlayerStepModel = .init(playerPosition: .go)
    @Published var enemyPosition:PlayerStepModel = .init(playerPosition: .go)
}
struct GameView: View {
    @StateObject var viewModel:GameViewModel = .init()
    
    var body: some View {
        VStack(spacing:0) {
            VStack(spacing:0) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(.black)
                    .frame(height: 40)
                    .overlay(content: {
                        HStack(spacing:0) {
                            items(2)
                        }
                        .overlay {
                            if (2 * Step.numberOfItemsInSection..<3 * Step.numberOfItemsInSection).contains(viewModel.playerPosition.playerPosition.index) {
                                HStack {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(.pink)
                                        .aspectRatio(1, contentMode: .fit)
                                        .offset(x:CGFloat((20 - viewModel.playerPosition.playerPosition.index) * -Int(32)))
                                    Spacer()
                                }
                                .animation(.bouncy, value: viewModel.playerPosition.playerPosition.index)

                                .opacity(0.5)
                            }
                            
                        }
                    })
                    .padding(.trailing, 40)
                Spacer()
                RoundedRectangle(cornerRadius: 12)
                    .fill(.black)
                    .frame(height: 40)
                    .overlay {
                        HStack(spacing:0) {
                            items(0)
                        }
                        .overlay {
                            if (0 * Step.numberOfItemsInSection..<1 * Step.numberOfItemsInSection).contains(viewModel.playerPosition.playerPosition.index) {
                                HStack {
                                    Spacer()
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(.pink)
                                        .aspectRatio(1, contentMode: .fit)
                                        .offset(x:CGFloat((0 - viewModel.playerPosition.playerPosition.index) * Int(32)))

                                }
                                .animation(.bouncy, value: viewModel.playerPosition.playerPosition.index)

                                .opacity(0.5)
                            }
                        }
                    }
                    .padding(.leading, 40)

            }
            .overlay(content: {
                HStack(spacing:0) {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.black)
                        .frame(width: 40)
                        .overlay(content: {
                            VStack(spacing:0) {
                                items(1)
                            }
                            .overlay {
                                if (1 * Step.numberOfItemsInSection..<2 * Step.numberOfItemsInSection).contains(viewModel.playerPosition.playerPosition.index) {
                                    VStack {
                                        Spacer()
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(.pink)
                                            .aspectRatio(1, contentMode: .fit)
                                            .offset(y:CGFloat((10 - viewModel.playerPosition.playerPosition.index) * Int(32)))

                                    }
                                    .animation(.bouncy, value: viewModel.playerPosition.playerPosition.index)

                                    .opacity(0.5)
                                }
                            }
                        })
                        .padding(.top, 40)
                    Spacer()
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.black)
                        .frame(width: 40)
                        .overlay(content: {
                            VStack(spacing:0) {
                                items(3)
                            }
                            .overlay {
                                if (3 * Step.numberOfItemsInSection..<4 * Step.numberOfItemsInSection).contains(viewModel.playerPosition.playerPosition.index) {
                                    VStack {
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(.pink)
                                            .aspectRatio(1, contentMode: .fit)
                                            .offset(y:CGFloat((30 - viewModel.playerPosition.playerPosition.index) * -Int(32)))
                                        Spacer()

                                    }
                                    .animation(.bouncy, value: viewModel.playerPosition.playerPosition.index)
                                    .opacity(0.5)
                                }
                            }
                        })
                        .padding(.bottom, 40)
                }
            })
            .aspectRatio(1, contentMode: .fit)
            Spacer()
        }
        .padding()
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
                self.move()
            })
        }
    }
    
    func move() {
        withAnimation {
            viewModel.playerPosition.playerPosition = Step.allCases.first(where: {
                (viewModel.playerPosition.playerPosition.index + 1) == $0.index
            }) ?? .go
        }
        if viewModel.playerPosition.playerPosition.index < viewModel.diceDestination {
            print("movemovemove")
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500), execute: {
                self.move()
            })
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
                self.viewModel.playerPosition.playerPosition = .go
                self.move()
            })
        }
    }
    @State var itemSize:CGSize = .zero
    func items(_ section: Int) -> some View {
        let current = (section) * Step.numberOfItemsInSection
        return ForEach(Step.items(section), id:\.rawValue) { i in
            ZStack  {
                RoundedRectangle(cornerRadius: 5)
                    .fill(i.color?.color ?? .gray)
                    .frame(width: 32, height: 32)
                Text(" \(((Step.allCases.firstIndex(of: i) ?? 0) + 1) + current)")
                    .font(.system(size: 10))

            }
                
        }
    }
}


#Preview {
    GameView()
}


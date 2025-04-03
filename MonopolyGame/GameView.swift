//
//  ContentView.swift
//  MonopolyGame
//
//  Created by Mykhailo Dovhyi on 03.04.2025.
//

import SwiftUI

struct GameView: View {
    @State var diceDestination = Step.allCases.count - 1
    @State var playerPosition:Int = 0
    @State var enemyPosition:Int = 0
    
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
                            if (2 * Step.numberOfItemsInSection..<3 * Step.numberOfItemsInSection).contains(playerPosition) {
                                HStack {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(.pink)
                                        .aspectRatio(1, contentMode: .fit)
                                        .offset(x:CGFloat((20 - playerPosition) * -Int(32)))
                                    Spacer()
                                }
                                .animation(.bouncy, value: playerPosition)

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
                            if (0 * Step.numberOfItemsInSection..<1 * Step.numberOfItemsInSection).contains(playerPosition) {
                                HStack {
                                    Spacer()
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(.pink)
                                        .aspectRatio(1, contentMode: .fit)
                                        .offset(x:CGFloat((0 - playerPosition) * Int(32)))

                                }
                                .animation(.bouncy, value: playerPosition)

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
                                if (1 * Step.numberOfItemsInSection..<2 * Step.numberOfItemsInSection).contains(playerPosition) {
                                    VStack {
                                        Spacer()
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(.pink)
                                            .aspectRatio(1, contentMode: .fit)
                                            .offset(y:CGFloat((10 - playerPosition) * Int(32)))

                                    }
                                    .animation(.bouncy, value: playerPosition)

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
                                if (3 * Step.numberOfItemsInSection..<4 * Step.numberOfItemsInSection).contains(playerPosition) {
                                    VStack {
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(.pink)
                                            .aspectRatio(1, contentMode: .fit)
                                            .offset(y:CGFloat((30 - playerPosition) * -Int(32)))
                                        Spacer()

                                    }
                                    .animation(.bouncy, value: playerPosition)
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
            playerPosition += 1
        }
        if playerPosition < diceDestination {
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500), execute: {
                self.move()
            })
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
                self.playerPosition = 0
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

class GameViewModel {
    
}


#Preview {
    GameView()
}


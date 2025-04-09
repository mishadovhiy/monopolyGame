//
//  ContentView.swift
//  MonopolyGame
//
//  Created by Mykhailo Dovhyi on 03.04.2025.
//

import SwiftUI

struct GameView: View {
    @StateObject var viewModel:GameViewModel = .init()
    
    var bettingView: some View {
        VStack {
            HStack {
                PropertyView(step: viewModel.betProperty ?? .blue1)
                    .frame(maxWidth: .infinity,
                           maxHeight: .infinity)
                ScrollView(.vertical) {
                    VStack {
                        ForEach(viewModel.bet, id:\.1) { bet in
                            HStack {
                                Text(viewModel.myPlayerPosition.id == bet.0.id ? "You" : "robot")
                                Text("\(bet.1)")
                            }
                        }
                    }
                }.frame(maxWidth: .infinity,
                        maxHeight: .infinity)
            }
            VStack {
                HStack {
                    Slider(value: $viewModel.betValue, in: (Float(viewModel.bet.last?.1 ?? 0)...Float(viewModel.betProperty?.buyPrice ?? 0)))
                        .frame(height: 20)
                    Text("\(Int(viewModel.betValue * 100))")
                }
                HStack {
                    Button("Decline") {
                        print(viewModel.bet.last?.1, " robotWin ")
                        self.viewModel.setBetWone()
                    }
                    Spacer()
                    Button("Bet") {
                        viewModel.bet.append((viewModel.myPlayerPosition, Int(viewModel.betValue * 100)))
                        viewModel.robotBet()
                    }
                }
                .disabled(viewModel.bet.last?.0.id == viewModel.myPlayerPosition.id)
                .frame(height:40)
            }
        }
        .background(.white)
        .padding(20)
        .opacity(viewModel.betProperty != nil ? 1 : 0)
    }
    
    var body: some View {
        VStack(spacing:0) {
            VStack(spacing:0) {
                vBoard(2)
                Spacer()
                vBoard(0)
                
            }
            .overlay(content: {
                HStack(spacing:0) {
                    hBoard(1)
                    Spacer()
                    hBoard(3)
                }
            })
            .aspectRatio(1, contentMode: .fit)
            .overlay {
                bettingView
            }
            Spacer()
        }
        .padding()
        .onAppear {
            viewModel.startMove()
            self.move()
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
                self.viewModel.messagePressed = .init(title: "Buy", pressed: {
                    
                })
                self.viewModel.message = .property(.blue1)
            })
            viewModel.betProperty = .blue1
        }
        .overlay {
            PopupView(dataType: $viewModel.message, buttonData: $viewModel.messagePressed, secondaryButton: $viewModel.messagePressedSecondary)
        }
    }
    
    func move() {
        withAnimation {
            viewModel.playerPosition.playerPosition = Step.allCases.first(where: {
                (viewModel.playerPosition.playerPosition.index + 1) == $0.index
            }) ?? .go
        }
        print(viewModel.diceDestination, " newDestination ")
        print(viewModel.playerPosition.playerPosition.index, " playerposition ")

        viewModel.diceDestination -= 1
        if viewModel.diceDestination >= 1 {
            print("movemovemove")
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500), execute: {
                self.move()
            })
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
                viewModel.startMove()
                self.move()
            })
        }
    }
    
    func vBoard(_ section:Int) -> some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(.black)
            .frame(height: 40)
            .overlay(content: {
                HStack(spacing:0) {
                    items(section)
                }
                .overlay {
                    ZStack {
                        self.playerOverlay(at:section, player: 0)
                        self.playerOverlay(at:section, player: 1)
                    }
                    
                }
            })
            .padding((section != 0 ? .trailing : .leading), 40)
    }
    
    func hBoard(_ section:Int) -> some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(.black)
            .frame(width: 40)
            .overlay(content: {
                VStack(spacing:0) {
                    items(section)
                }
                .overlay {
                    ZStack {
                        self.playerOverlay(at:section, player: 0)
                        self.playerOverlay(at:section, player: 1)
                    }
                    
                    
                }
            })
            .padding((section == 1 ? .top : .bottom), 40)
    }
    

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
    
    
    func playerOverlay(at:Int, player:Int) -> some View {
        VStack {
            switch at {
            case 3:
                if (3 * Step.numberOfItemsInSection..<4 * Step.numberOfItemsInSection).contains(viewModel.playersArray[player].playerPosition.index) {
                    VStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(player == 0 ? .pink : .blue)
                            .aspectRatio(1, contentMode: .fit)
                            .offset(y:CGFloat((30 - viewModel.playersArray[player].playerPosition.index) * -Int(32)))
                        Spacer()
                        
                    }
                    .animation(.bouncy, value: viewModel.playersArray[player].playerPosition.index)
                    .opacity(0.5)
                }
            case 0:
                if (0 * Step.numberOfItemsInSection..<1 * Step.numberOfItemsInSection).contains(viewModel.playersArray[player].playerPosition.index) {
                    HStack {
                        Spacer()
                        RoundedRectangle(cornerRadius: 12)
                            .fill(player == 0 ? .pink : .blue)
                            .aspectRatio(1, contentMode: .fit)
                            .offset(x:CGFloat((0 - viewModel.playersArray[player].playerPosition.index) * Int(32)))
                        
                    }
                    .animation(.bouncy, value: viewModel.playersArray[player].playerPosition.index)
                    
                    .opacity(0.5)
                }
            case 1:
                if (1 * Step.numberOfItemsInSection..<2 * Step.numberOfItemsInSection).contains(viewModel.playersArray[player].playerPosition.index) {
                    VStack {
                        Spacer()
                        RoundedRectangle(cornerRadius: 12)
                            .fill(player == 0 ? .pink : .blue)
                            .aspectRatio(1, contentMode: .fit)
                            .offset(y:CGFloat((10 - viewModel.playersArray[player].playerPosition.index) * Int(32)))
                        
                    }
                    .animation(.bouncy, value: viewModel.playersArray[player].playerPosition.index)
                    
                    .opacity(0.5)
                }
            case 2:
                if (2 * Step.numberOfItemsInSection..<3 * Step.numberOfItemsInSection).contains(viewModel.playersArray[player].playerPosition.index) {
                    HStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(player == 0 ? .pink : .blue)
                            .aspectRatio(1, contentMode: .fit)
                            .offset(x:CGFloat((20 - viewModel.playersArray[player].playerPosition.index) * -Int(32)))
                        Spacer()
                    }
                    .animation(.bouncy, value: viewModel.playersArray[player].playerPosition.index)
                    
                    .opacity(0.5)
                }
            default:Text("?")
            }
        }
    }
    
}


#Preview {
    GameView()
}


//
//  ContentView.swift
//  MonopolyGame
//
//  Created by Mykhailo Dovhyi on 03.04.2025.
//

import SwiftUI

struct GameView: View {
    @StateObject var viewModel:GameViewModel = .init()
    
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
            Spacer()
        }
        .padding()
        .onAppear {
            viewModel.startMove()
        }
        .onChange(of: viewModel.diceDestination) { newValue in
            self.move()
        }
    }
    
    func move() {
        withAnimation {
            viewModel.playerPosition.playerPosition = Step.allCases.first(where: {
                (viewModel.playerPosition.playerPosition.index + 1) == $0.index
            }) ?? .go
        }
//        viewModel.diceDestination -= 1
        if viewModel.playerPosition.playerPosition.index >= viewModel.diceDestination {
            print("movemovemove")
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500), execute: {
                self.move()
            })
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
                viewModel.startMove()
                //                self.viewModel.playerPosition.playerPosition = .go
                //                self.move()
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


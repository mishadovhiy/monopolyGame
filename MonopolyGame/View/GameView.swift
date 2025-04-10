//
//  ContentView.swift
//  MonopolyGame
//
//  Created by Mykhailo Dovhyi on 03.04.2025.
//

import SwiftUI

struct GameView: View {
    @StateObject var viewModel:GameViewModel = .init()
    @EnvironmentObject var db: AppData
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        VStack(spacing:0) {
            ScrollView(.horizontal, showsIndicators: false) {
                VStack(spacing:0) {
                    vBoard(2)
                    Spacer()
                    vBoard(0)                }
                .padding(.vertical, 35)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .overlay(content: {
                    HStack(spacing:0) {
                        hBoard(1)
                        Spacer()
                        hBoard(3)
                    }
                    .padding(.horizontal, -15)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                })
                
                .frame(width: viewModel.itemWidth * CGFloat(Step.numberOfItemsInSection), height: viewModel.itemWidth * CGFloat(Step.numberOfItemsInSection))
                .padding(.horizontal, 15)
            }
            .overlay {
                
                ZStack {
                    bettingView
                    Button("cancel") {
                        viewModel.boardActionType = nil
                    }
                    .frame(maxHeight: viewModel.boardActionType != nil ? 44 : 0)
                    .clipped()
                    .animation(.smooth, value: viewModel.boardActionType != nil)
                }
            }
            Spacer()
            panelView
                .disabled(!viewModel.canDice)
        }
        .padding()
        .onChange(of: scenePhase) { newValue in
            print(newValue, " rgefds ")
            if newValue == .inactive || newValue == .background {
                if !viewModel.dbUpdated {
                    viewModel.dbUpdated = true
                    db.db.player = viewModel.myPlayerPosition
                    db.db.enemy = viewModel.enemyPosition
                }
            } else if newValue == .active {
                viewModel.dbUpdated = false
            }
        }
        
        .onAppear {
            print(db.db.player.playerPosition, " yrtgerfwdaw")
            self.viewModel.myPlayerPosition = db.db.player
            self.viewModel.enemyPosition = db.db.enemy
            self.viewModel.viewAppeared = true

//            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
//                self.viewModel.messagePressed = .init(title: "Buy", pressed: {
//                    
//                })
//                self.viewModel.message = .property(.blue1)
//            })
//            viewModel.betProperty = .blue1
        }
        .overlay {
            PopupView(dataType: $viewModel.message, buttonData: $viewModel.messagePressed, secondaryButton: $viewModel.messagePressedSecondary)
        }
        .overlay(content: {
            testPBoughtPropertiesView
        })
    }
    
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
                                    .foregroundColor(.white)

                                Text("\(bet.1)")
                                    .foregroundColor(.white)
                            }
                        }
                    }
                }.frame(maxWidth: .infinity,
                        maxHeight: .infinity)
            }
            VStack {
                HStack {
                    Slider(value: $viewModel.betValue, in: viewModel.betSliderRange, step: 0.01)
                        .frame(height: 20)
                    Text("\(Int(viewModel.betValue * 100))")
                        .foregroundColor(.white)
                }
                HStack {
                    Button("Decline") {
                        print(viewModel.bet.last?.1, " robotWin ")
                        self.viewModel.setBetWone()
                    }
                    Spacer()
                    Button("Bet") {
                        print(Int(viewModel.betValue * 100), " tegrfweda ", Int(viewModel.betValue * 100))
                        viewModel.bet.append((viewModel.myPlayerPosition, Int(viewModel.betValue * 100)))
                        viewModel.robotBet()
                    }.disabled(!viewModel.myPlayerPosition.canBuy(viewModel.betProperty ?? .blue1, price: viewModel.bet.last?.1 ?? Int(viewModel.betValue * 100)))
                }
                .disabled(viewModel.bet.last?.0.id == viewModel.myPlayerPosition.id)
                .frame(height:40)
            }
        }
        .background(.black)
        .padding(.horizontal, viewModel.itemWidth / 2)
        .padding(.vertical, viewModel.itemWidth + 30)
        .opacity(viewModel.betProperty != nil ? 1 : 0)
    }
    
    var panelView: some View {
        VStack {
            Button("dice") {
                viewModel.resumeNextPlayer(forceMove: true)
            }
            Spacer().frame(height: 80)
            HStack(spacing:40) {
                ForEach(GameViewModel.BoardActionType.allCases, id:\.rawValue) { type in
                    Button(type.rawValue.capitalized) {
                        viewModel.boardActionType = type
                    }
                }
            }
            HStack {
                VStack {
                    Text("Your Balance")
                    Text("\(viewModel.myPlayerPosition.balance)")
                }
                
                Spacer()
                VStack {
                    Text("Enemy balance")
                    Text("\(viewModel.enemyPosition.balance)")
                }
            }
            Spacer()
        }
    }
    
    var testPBoughtPropertiesView: some View {
        VStack(content:  {
            Spacer().frame(maxHeight: .infinity)
            HStack {
                ScrollView(.vertical) {
                    VStack {
                        ForEach(viewModel.myPlayerPosition.bought.compactMap({$0.key}), id:\.self) { bought in
                            Text(bought.title)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                ScrollView(.vertical) {
                    VStack {
                        ForEach(viewModel.enemyPosition.bought.compactMap({$0.key}), id:\.self) { bought in
                            Text(bought.title)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.top, 100)
            .frame(maxHeight: .infinity)
            
        })
        .disabled(true)
    }

    
    func vBoard(_ section:Int) -> some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(.clear)
            .frame(height: viewModel.itemWidth)
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
//            .padding((section != 0 ? .trailing : .leading), viewModel.itemWidth + 10)

    }
    
    func hBoard(_ section:Int) -> some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(.clear)
            .frame(width: viewModel.itemWidth)
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
//            .padding((section == 1 ? .top : .bottom), viewModel.itemWidth + 10)

    }
    

    func propertyItem(_ step:Step) -> some View {
        let disabled = viewModel.propertyTapDisabled(step)
        return ZStack  {
            RoundedRectangle(cornerRadius: 5)
                .fill(step.color?.color ?? .gray)
                .frame(width: viewModel.itemWidth - 8, height: viewModel.itemWidth - 8)
            Text(" \(step.index)")
                .font(.system(size: 10))
                .opacity(step.buyPrice == nil ? 0.5 : 1)
        }
        .onTapGesture {
            viewModel.propertySelected(step)
        }
        .disabled(disabled)
        .opacity(disabled ? 0.1 : 1)
    }
    
    func items(_ section: Int) -> some View {
//        let current = (section) * Step.numberOfItemsInSection
        return ForEach(Step.items(section), id:\.rawValue) { i in
            propertyItem(i)
            .overlay {
                if let upgrade = viewModel.myPlayerPosition.bought[i] {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Text("\(upgrade.index)")
                                .foregroundColor(.red)
                        }
                    }
                }
                if let upgrade = viewModel.enemyPosition.bought[i] {
                    VStack {
                        HStack {
                            Text("\(upgrade.index)")
                                .foregroundColor(.yellow)
                            Spacer()
                        }
                        Spacer()
                        
                    }
                }
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
                            .offset(y:CGFloat((30 - viewModel.playersArray[player].playerPosition.index) * -Int(viewModel.itemWidth - 8)))
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
                            .offset(x:CGFloat((0 - viewModel.playersArray[player].playerPosition.index) * Int(viewModel.itemWidth - 8)))
                        
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
                            .offset(y:CGFloat((10 - viewModel.playersArray[player].playerPosition.index) * Int(viewModel.itemWidth - 8)))
                        
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
                            .offset(x:CGFloat((20 - viewModel.playersArray[player].playerPosition.index) * -Int(viewModel.itemWidth - 8)))
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


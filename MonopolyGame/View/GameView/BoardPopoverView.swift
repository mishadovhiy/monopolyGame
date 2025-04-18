//
//  BoardPopoverView.swift
//  MonopolyGame
//
//  Created by Mykhailo Dovhyi on 12.04.2025.
//

import SwiftUI

struct BoardPopoverView: View {
    @StateObject var viewModel:GameViewModel
    @Binding var isGamePresenting:Bool
    
    var body: some View {
        ZStack {
            sellToPlayView
            bettingView
            boardActionCancelView
            tradeView
            gameCompleted
        }
    }
    
    var gameCompleted: some View {
        VStack {
            if viewModel.gameCompleted {
                VStack {
                    Text("Game Completed!")
                    Button("OK") {
                        isGamePresenting = false
                    }
                }
                .background {
                    Color(.secondaryBackground)
                        .cornerRadius(12)
                }
            }
        }
        
    }
    
    var sellToPlayView: some View {
        Button("cancel sell") {
            if viewModel.myPlayerPosition.balance > 0 {
                viewModel.updateBalancePresenting = false
            }
        }
        .disabled(!(viewModel.myPlayerPosition.balance > 0))
        .frame(maxHeight: viewModel.updateBalancePresenting ? 44 : 0)
        .clipped()
        .animation(.smooth, value: viewModel.updateBalancePresenting)
    }
    
    var boardActionCancelView: some View {
        Button("cancel") {
            viewModel.activePanelType = nil
        }
        .frame(maxHeight: viewModel.activePanelType != nil ? 44 : 0)
        .clipped()
        .animation(.smooth, value: viewModel.activePanelType != nil)
    }
    

    var tradeView: some View {
        VStack {
            Text("Trade")
                .font(.system(size: 18, weight:.semibold))
                .foregroundColor(.light)
                .padding(.top, 10)
                .padding(.bottom, 5)
            HStack {
                PropertyListView(list: Array(viewModel.myPlayerPosition.bought.keys).sorted(by: {$0.rawValue >= $1.rawValue}), selectedProperties: $viewModel.trade.myPlayerProperties)
                PropertyListView(list: Array(viewModel.enemyPosition.bought.keys.sorted(by: {$0.rawValue >= $1.rawValue})), selectedProperties: $viewModel.trade.enemyProperties)

            }
            HStack {
                Button("-100") {
                    viewModel.trade.tradeAmount -= 1
                }
                .padding(.vertical, 2)
                .padding(.horizontal, 7)
                .background(.lightsecondaryBackground)
                .cornerRadius(4)
                Button("-10") {
                    viewModel.trade.tradeAmount -= 0.1
                }
                .padding(.vertical, 2)
                .padding(.horizontal, 7)
                .background(.lightsecondaryBackground)
                .cornerRadius(4)
                Text("\(Int(viewModel.trade.tradeAmount * 100))")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.light)
                    .padding(.horizontal, 20)
                Button("+10") {
                    viewModel.trade.tradeAmount += 0.1
                }
                .padding(.vertical, 2)
                .padding(.horizontal, 7)
                .background(.lightsecondaryBackground)
                .cornerRadius(4)
                Button("+100") {
                    viewModel.trade.tradeAmount += 1
                }
                .padding(.vertical, 2)
                .padding(.horizontal, 7)
                .background(.lightsecondaryBackground)
                .cornerRadius(4)
            }
            .padding(.top, 10)
            HStack(spacing:20) {
                if viewModel.trade.tradingByEnemy {
                    Button("Decline") {
                        viewModel.trade = .init(isPresenting: false)
                    }
                    .padding(.vertical, 3)
                    .padding(.horizontal, 5)
                    .background(.red)
                    .cornerRadius(5)
                    Spacer()
                } else {
                    #warning("todo: set min/max")
                    Slider(value: $viewModel.trade.tradeAmount)
                }
                
                Button("OK") {
                    viewModel.enemyTrade()
                }
                .tint(.black)
                .padding(.vertical, 3)
                .padding(.horizontal, 5)
                .background(.light)
                .cornerRadius(5)
                .disabled(!viewModel.trade.okEnabled)
            }
            .padding(.bottom, 5)
            .padding(.horizontal, 5)
        }
        .overlay(content: {
            VStack(content:  {
                HStack(content:  {
                    Spacer()
                    Button("close") {
                        viewModel.activePanelType = nil
                    }
                    .tint(.light)
                    .padding(5)
                    .background(.lightsecondaryBackground)
                    .cornerRadius(4)
                })
                Spacer()
                
            })
        })
        .animation(.bouncy, value: viewModel.activePanelType == .trade)
        .background(.secondaryBackground)
        .cornerRadius(6)
        .shadow(radius: 10)
        .padding(.top, 80)
        .padding(.bottom, 20)
        .padding(.horizontal, 10)
        .opacity(viewModel.activePanelType == .trade ? 1 : 0)

    }
    
    var bettingView: some View {
        VStack {
            HStack {
                PropertyView(step: viewModel.bet.betProperty ?? .blue1)
                    .frame(maxWidth: .infinity,
                           maxHeight: .infinity)
                ScrollView(.vertical) {
                    VStack {
                        ForEach(viewModel.bet.bet, id:\.1) { bet in
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
                    Slider(value: $viewModel.bet.betValue, in: viewModel.bet.betSliderRange, step: 0.01)
                        .frame(height: 20)
                    Text("\(Int(viewModel.bet.betValue * 100))")
                        .foregroundColor(.white)
                }
                HStack {
                    Button("Decline") {
                        print(viewModel.bet.bet.last?.1, " robotWin ")
                        self.viewModel.setBetWone()
                    }
                    Spacer()
                    Button("Bet") {
                        print(Int(viewModel.bet.betValue * 100), " tegrfweda ", Int(viewModel.bet.betValue * 100))
                        viewModel.bet.bet.append((viewModel.myPlayerPosition, Int(viewModel.bet.betValue * 100)))
                        viewModel.robotBet()
                    }.disabled(!viewModel.myPlayerPosition.canBuy(viewModel.bet.betProperty ?? .blue1, price: viewModel.bet.bet.last?.1 ?? Int(viewModel.bet.betValue * 100)))
                }
                .disabled(viewModel.bet.bet.last?.0.id == viewModel.myPlayerPosition.id)
                .frame(height:40)
            }
        }
        .background(.black)
        .padding(.horizontal, viewModel.itemWidth / 2)
        .padding(.vertical, viewModel.itemWidth + 30)
        .opacity(viewModel.bet.betProperty != nil ? 1 : 0)
    }
}


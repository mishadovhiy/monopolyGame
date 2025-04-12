//
//  BoardPopoverView.swift
//  MonopolyGame
//
//  Created by Mykhailo Dovhyi on 12.04.2025.
//

import SwiftUI

struct BoardPopoverView: View {
    @StateObject var viewModel:GameViewModel
    
    var body: some View {
        ZStack {
            bettingView
            boardActionCancelView
            tradeView
        }
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
            HStack {
                PropertyListView(list: Array(viewModel.myPlayerPosition.bought.keys).sorted(by: {$0.rawValue >= $1.rawValue}), selectedProperties: $viewModel.trade.myPlayerProperties)
                PropertyListView(list: Array(viewModel.enemyPosition.bought.keys.sorted(by: {$0.rawValue >= $1.rawValue})), selectedProperties: $viewModel.trade.enemyProperties)

            }
            HStack {
                if viewModel.trade.tradingByEnemy {
                    Button("Decline") {
                        viewModel.trade = .init(isPresenting: false)
                    }
                    Spacer()
                } else {
                    Slider(value: $viewModel.trade.tradeAmount)
                }
                Text("\(Int(viewModel.trade.tradeAmount * 100))")
                Button("OK") {
                    viewModel.enemyTrade()
                }
                .disabled(!viewModel.trade.okEnabled)
            }
        }
        .overlay(content: {
            VStack(content:  {
                HStack(content:  {
                    Spacer()
                    Button("close") {
                        viewModel.activePanelType = nil
                    }
                })
                Spacer()
                
            })
        })
        .opacity(viewModel.activePanelType == .trade ? 1 : 0)
        .animation(.bouncy, value: viewModel.activePanelType == .trade)
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


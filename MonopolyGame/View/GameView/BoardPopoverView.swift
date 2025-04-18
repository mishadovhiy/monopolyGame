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
    let gameLost:()->()
    var body: some View {
        ZStack {
            #warning("test")
            sellToPlayView
            bettingView
            boardActionCancelView
            tradeView
            gameCompleted
        }
    }
    
    #warning("not tested")
    var gameCompleted: some View {
        messageOverlayView(.init(title: "Game Completed!"), buttons: [
            (.init(title: "OK", pressed: {
                isGamePresenting = false
            }), false)
        ])
        .opacity(viewModel.gameCompleted ? 1 : 0)
    }
    
    func messageOverlayView(_ message:MessageContent, titleColor:ColorResource = .light,
                            buttons:[(button: ButtonData, disabled:Bool)]) -> some View {
        VStack(spacing: 25) {
            VStack {
                Text(message.title.capitalized)
                    .font(.system(size: 24, weight: .black))
                    .foregroundColor(Color(titleColor))
                Text(message.description)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.light)
            }
            HStack {
                ForEach(buttons, id:\.0.title) { buttonData in
                    Button(buttonData.0.title) {
                        if let action = buttonData.button.pressed {
                            action()
                        } else {
                            viewModel.activePanelType = nil
                        }
                    }
                    .padding(.vertical, 2)
                    .padding(.horizontal, 10)
                    .background(Color(buttonData.0.backgroundColor ?? .lightsecondaryBackground))
                    .cornerRadius(4)
                    .disabled(buttonData.1)
                    .clipped()
                }
            }
        }
        .padding(15)
        .background(.secondaryBackground)
        .cornerRadius(4)
        .shadow(radius: 10)
    }
    
    var sellToPlayView: some View {
        messageOverlayView(.init(title: "Negative Balance", description: "To continue playing, please, select properties to sell or morgage"), titleColor: .red, buttons: [
            (.init(title: "Declare bancropcy", backgroundColor: .red, pressed: {
                gameLost()
            }), false),
            (.init(title: "Close", backgroundColor: .lightsecondaryBackground, pressed: {
                
                if viewModel.myPlayerPosition.balance > 0 {
                    viewModel.updateBalancePresenting = false
                }
            }), !(viewModel.myPlayerPosition.balance > 0))
        ])
        .opacity(viewModel.updateBalancePresenting ? 1 : 0)
        .animation(.bouncy, value: viewModel.updateBalancePresenting)
    }
    
    var boardActionCancelView: some View {
        messageOverlayView(.init(title: viewModel.activePanelType?.rawValue ?? "-", description:viewModel.activePanelType?.description ?? ""), buttons: [
            (.init(title: "Cancel"),false)
        ])
        .opacity(viewModel.activePanelType != nil ? 1 : 0)
        .animation(.smooth, value: viewModel.activePanelType != nil)
    }
    
    var tradeSliderValueView: some View {
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
    }

    
    var tradeActionButtons: some View {
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
            tradeSliderValueView
            tradeActionButtons
        }
        .overlay(content: {
            VStack(content:  {
                HStack(content:  {
                    Spacer()
                    #warning("close button reusable")
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
            Text("Auction")
                .font(.system(size: 18, weight:.semibold))
                .foregroundColor(.light)
                .padding(.top, 10)
                .padding(.bottom, 5)
            HStack {
                PropertyView(step: viewModel.bet.betProperty ?? .blue1)
                    .frame(maxWidth: .infinity,
                           maxHeight: .infinity)
                ScrollView(.vertical) {
                    VStack {
                        if viewModel.bet.bet.isEmpty {
                            VStack {
                                Spacer().frame(maxHeight: .infinity)
                                Text("Start betting")
                                    .font(.system(size: 18, weight: .semibold))
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(.secondaryText)
                            }
                            .frame(height: 140)
                            
                        }
                        ForEach(viewModel.bet.bet, id:\.1) { bet in
                            HStack(alignment:.bottom) {
                                Text(viewModel.myPlayerPosition.id == bet.0.id ? "You" : "robot")
                                    .foregroundColor(.secondaryText)
                                    .font(.system(size: 13))
                                Text("\(bet.1)")
                                    .foregroundColor(.white)
                                    .font(.system(size: 16, weight:.semibold))

                            }
                            .padding(.horizontal, 5)
                            .padding(.vertical, 2)
                            .frame(maxWidth:.infinity, alignment: .trailing)
                            Divider()
                        }
                    }
                }.frame(maxWidth: .infinity,
                        maxHeight: .infinity)
            }
            VStack {
                HStack(spacing:30) {
                    Button("Decline") {
                        print(viewModel.bet.bet.last?.1, " robotWin ")
                        self.viewModel.setBetWone()
                    }
                    .tint(.red)
                    HStack {
                        Slider(value: $viewModel.bet.betValue, in: viewModel.bet.betSliderRange, step: 0.01)
                            .frame(height: 20)
                        Text("\(Int(viewModel.bet.betValue * 100))")
                            .foregroundColor(.white)
                    }
                    Button("Bet") {
                        print(Int(viewModel.bet.betValue * 100), " tegrfweda ", Int(viewModel.bet.betValue * 100))
                        viewModel.bet.bet.append((viewModel.myPlayerPosition, Int(viewModel.bet.betValue * 100)))
                        viewModel.robotBet()
                    }.disabled(!viewModel.myPlayerPosition.canBuy(viewModel.bet.betProperty ?? .blue1, price: viewModel.bet.bet.last?.1 ?? Int(viewModel.bet.betValue * 100)))
                }
                .disabled(viewModel.bet.bet.last?.0.id == viewModel.myPlayerPosition.id)
                .frame(height:40)
                .padding(.horizontal, 5)
            }
        }
        .background(.secondaryBackground)
        .cornerRadius(5)
        .padding(.horizontal, viewModel.itemWidth / 2)
        .padding(.vertical, viewModel.itemWidth + 30)
        .shadow(radius: 10)
        .opacity(viewModel.bet.betProperty != nil ? 1 : 0)
    }
}


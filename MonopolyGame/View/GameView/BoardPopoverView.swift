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
    @EnvironmentObject var db: AppData
    let gameLost:()->()
    var body: some View {
        ZStack {
            sellToPlayView
            auctionView
            boardActionCancelView
            tradeView
            gameCompleted
            inJailView
        }
    }
    
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
                        db.audioManager?.play(.menu)
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
    
    var inJailView: some View {
        messageOverlayView(.init(title: "You are in jail"), buttons: [
            (.init(title: "skip move", pressed: {
                viewModel.jailDisabled = false
                viewModel.performNextPlayer()
            }), false),
            (.init(title: "use card", pressed: {
                var removed = false
                viewModel.myPlayerPosition.specialCards.removeAll { card in
                    card == .outOfJail && !removed
                }
                viewModel.jailDisabled = false
                
            }), false),
            (.init(title: "pay 100", pressed: {
                var removed = false
                viewModel.myPlayerPosition.balance -= 100
                viewModel.jailDisabled = false
                
            }), false)
        ])
        .opacity(viewModel.jailDisabled ? 1 : 0)
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
                Slider(value: $viewModel.trade.tradeAmount, in: 0...Float((viewModel.myPlayerPosition.balance >= 101 ? viewModel.myPlayerPosition.balance : 100) / 100), step: 0.01)
            }
            
            Button("OK") {
                db.audioManager?.play(.menu)
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
            sliderTextPanel($viewModel.trade.tradeAmount)
            tradeActionButtons
        }
        .overlay(content: {
            VStack(content:  {
                HStack(content:  {
                    Spacer()
                    #warning("close button reusable")
                    Button("Close") {
                        db.audioManager?.play(.menu)
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
    
    func sliderButton(_ value:Binding<Float>, multiplier:Float) -> some View {
        Button("\(Int(multiplier * 100))") {
            db.audioManager?.play(.menu)
            value.wrappedValue += multiplier
        }
        .padding(.vertical, 2)
        .padding(.horizontal, 7)
        .background(.lightsecondaryBackground)
        .cornerRadius(4)
    }
    
    func sliderTextPanel(_ value:Binding<Float>) -> some View {
        let minus:[Float] = [-1, -0.1]
        let plus:[Float] = [0.1, 1]
        return HStack {
            ForEach(minus, id:\.self) { i in
                self.sliderButton(value, multiplier: i)
            }
            Text("\(Int(value.wrappedValue * 100))")
                .font(.system(size: 17, weight: .semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.2)
                .foregroundColor(.light)
                .padding(.horizontal, 20)
            ForEach(plus, id:\.self) { i in
                self.sliderButton(value, multiplier: i)
            }
        }
    }
    
    var auctionBetListView: some View {
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
    }
    
    var auctionButtonsView: some View {
        VStack {
            HStack {
                Spacer()
                sliderTextPanel($viewModel.bet.betValue)
                Spacer()
            }
            HStack(spacing:30) {
                Button("Decline") {
                    print(viewModel.bet.bet.last?.1, " robotWin ")
                    db.audioManager?.play(.menu)
                    self.viewModel.setBetWone()
                }
                .tint(.red)
                    Slider(value: $viewModel.bet.betValue, in: viewModel.bet.betSliderRange, step: 0.01)
                        .frame(height: 20)
                Button("Bet") {
                    db.audioManager?.play(.menu)
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
    
    var auctionView: some View {
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
                    auctionBetListView
                }.frame(maxWidth: .infinity,
                        maxHeight: .infinity)
            }
            auctionButtonsView
        }
        .background(.secondaryBackground)
        .cornerRadius(5)
        .padding(.horizontal, viewModel.itemWidth / 2)
        .padding(.vertical, viewModel.itemWidth + 30)
        .shadow(radius: 10)
        .opacity(viewModel.bet.betProperty != nil ? 1 : 0)
    }
}


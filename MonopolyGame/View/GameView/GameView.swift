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
                
                BoardPopoverView(viewModel: viewModel)
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
        }
        .overlay {
            PopupView(dataType: $viewModel.message, buttonData: $viewModel.messagePressed, secondaryButton: $viewModel.messagePressedSecondary)
        }
    }
    
    var panelView: some View {
        VStack {
            Button("dice") {
                viewModel.resumeNextPlayer(forceMove: true)
            }
            Spacer().frame(height: 80)
            Button("menu") {
                viewModel.message = .custom(.init(title: "Menu"))
                viewModel.messagePressed = .init(title: "Delete", pressed: {
                    db.db = .init()
                    viewModel.myPlayerPosition = .init()
                    viewModel.enemyPosition = .init()
                })
            }
            HStack(spacing:40) {
                ForEach(GameViewModel.PanelType.allCases, id:\.rawValue) { type in
                    Button(type.rawValue.capitalized) {
                        viewModel.activePanelType = type
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
                                .background(.white)
                        }
                    }
                }
                if let upgrade = viewModel.enemyPosition.bought[i] {
                    VStack {
                        HStack {
                            Text("\(upgrade.index)")
                                .foregroundColor(.yellow)
                                .background(.white)
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


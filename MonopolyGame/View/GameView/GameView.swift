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
    @Binding var isPresenting:Bool
    
    var body: some View {
        VStack(spacing:0) {
            VStack( spacing: 0) {
                balancesView
                boardView
                    .overlay {
                        BoardPopoverView(viewModel: viewModel, isGamePresenting: $isPresenting) {
                            db.db.gameProgress = .init()
                            isPresenting = false
                        }
                    }
                    .padding(.top, -60)
                Spacer()
            }
            .background(.primaryBackground)
            panelView
                .disabled(!viewModel.canDice)
        }
        .tint(.light)
        .background(.secondaryBackground)
        .onChange(of: scenePhase) { newValue in
            if newValue == .inactive || newValue == .background {
                if !viewModel.dbUpdated {
                    viewModel.dbUpdated = true
                    viewModel.saveProgress(db: &db.db)
                }
            } else if newValue == .active {
                viewModel.dbUpdated = false
            }
        }
        .onDisappear(perform: {
            viewModel.saveProgress(db: &db.db)
        })
        .onAppear {
            viewModel.enemyLostAction = {
                db.db.gameProgress = .init()
                db.gameCenter.addGameCompletionScore(viewModel.myPlayerPosition)
                db.db.gameCompletions.completionList.append(.init(balance: viewModel.myPlayerPosition.balance, time: .init(), upgrades: viewModel.myPlayerPosition.bought))
            }
            viewModel.fetchGame(db: db.db)
            self.viewModel.viewAppeared = true
        }
        .overlay {
            PopupView(dataType: $viewModel.message, buttonData: $viewModel.messagePressed, secondaryButton: $viewModel.messagePressedSecondary)
        }
        .navigationBarHidden(true)
    }
    
    func chanceView(_ isOnTop:Bool, canOpen:Bool = true) -> some View {
        let data = canOpen ? (isOnTop ? viewModel.chancePresenting : viewModel.chestPresenting) : nil
        let isOpened = data != nil
        return HStack {
            if !isOnTop {
                Spacer()
                    .frame(maxWidth: isOpened ? 0 : .infinity)
                    .animation(.smooth, value: isOpened)
            }
            VStack {
                if !isOnTop {
                    Spacer()
                        .frame(maxHeight: isOpened ? 0 : .infinity)
                        .animation(.smooth, value: isOpened)
                }
                ZStack {
                    
                    if !isOpened {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(.red)
                        
                    } else {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(.light)
                            .overlay(content: {
                                VStack(spacing:10) {
                                    Text(data?.title ?? "")
                                        .font(.system(size: 18, weight:.bold))
                                        .foregroundColor(.primaryBackground)
                                    Text(data?.text ?? "")
                                        .font(.system(size: 12, weight:.medium))
                                        .foregroundColor(.primaryBackground.opacity(0.8))
                                    Spacer()
                                    if data?.canClose ?? false {
                                        HStack {
                                            Spacer()
                                            Button {
                                                if isOnTop {
                                                    viewModel.chanceOkPressed()
                                                } else {
                                                    viewModel.chestOkPressed()
                                                }
                                            } label: {
                                                Text("Close")
                                                    .font(.system(size: 12, weight: .semibold))
                                                
                                            }
                                            .tint(.light)
                                            .padding(.horizontal, 20)
                                            .padding(.vertical, 6)
                                            .background(.secondaryBackground)
                                            .cornerRadius(4)
                                        }

                                    }

                                }
                                .frame(maxWidth: .infinity)
                                .padding(.bottom, 5)
                                .padding(.horizontal, 5)
                                .padding(.top, 10)
                                .rotation3DEffect(Angle(degrees: 180), axis: (x: 0.0, y: 1.0, z: 0.0))
                                
                            })
                    }
                    
                }
                .shadow(radius: 5)
                .rotation3DEffect(
                    isOpened ? Angle(degrees: 180) : .zero,
                    axis: (x: 0.0, y: 1.0, z: 0.0)
                )
                .animation(.default, value: isOpened)
                .onTapGesture {
                    withAnimation(.spring()) {
                        if isOnTop {
                            if viewModel.chancePresenting != nil {
                                viewModel.chancePresenting = nil
                            } else {
                                viewModel.chancePresenting = viewModel.chances.first
                                viewModel.chances.removeFirst()
                            }
                        } else {
                            if viewModel.chestPresenting != nil {
                                viewModel.chestPresenting = nil
                            } else {
                                viewModel.chestPresenting = viewModel.chests.first
                                viewModel.chests.removeFirst()
                            }
                        }
                    }
                }
                if isOnTop {
                    Spacer()
                        .frame(maxHeight: isOpened ? 0 : .infinity)
                        .animation(.smooth, value: isOpened)
                }
                
            }
            if isOnTop {
                Spacer()
                    .frame(maxWidth: isOpened ? 0 : .infinity)
                    .animation(.bouncy, value: isOpened)
            }
            
        }
        .frame(maxHeight: .infinity)
    }
    
    var boardCardsOverley: some View {
        VStack {
            ZStack {
                chanceView(true, canOpen: false)
                    .offset(x:-4, y:-4)
                chanceView(true)
                
            }
            ZStack {
                chanceView(false, canOpen: false)
                    .offset(x:-4, y:-4)
                chanceView(false)
            }
        }
        .padding(.top, 130)
        .padding(.bottom, 110)
        .padding(.leading, 90)
        .padding(.trailing, 150)
    }
    
    var boardView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            VStack(spacing:0) {
                vBoard(2)
                    .padding(.leading, -110)
                Spacer()
                vBoard(0)
                    .padding(.trailing, 10)
                    .padding(.bottom, -20)
            }
            .background(content: {
                Color.lightGreen
                    .padding(.leading, 50)
                    .padding(.top, 20)
                    .padding(.trailing, 130)
                    .clipped()
                
            })
            .padding(.vertical, 65)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay(content: {
                HStack(spacing:0) {
                    hBoard(1)
                        .padding(.top, 70)
                    Spacer()
                    hBoard(3)
                        .padding(.top, -30)
                        .padding(.trailing, 60)
                }
                .padding(.horizontal, 25)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            })
            .frame(width: viewModel.itemWidth * CGFloat(Step.numberOfItemsInSection), height: viewModel.itemWidth * CGFloat(Step.numberOfItemsInSection))
            .overlay(content: {
                boardCardsOverley
            })
            .overlay(content: {
                DiceSceneView()
            })
            .padding(.horizontal, 0)
        }
    }
    
    var balancesView: some View {
        HStack {
            Spacer().frame(width: 60)
            HStack {
                HStack {
                    Spacer().frame(width:65)
                    VStack(alignment:.leading) {
                        Text("Your Balance")
                            .font(.system(size: 12))
                            .foregroundColor(.secondaryText)
                            .frame(alignment: .leading)
                        Text("\(viewModel.myPlayerPosition.balance)")
                            .font(.system(size: 18, weight:.bold))
                            .foregroundColor(.white)
                            .frame(alignment: .leading)
                        
                    }
                    .padding(.top, 13)
                    .padding(.bottom, 15)
                }
                .padding(.trailing, 13)
                .background(viewModel.myPlayerBalanceHiglightingPositive ? .green : (viewModel.myPlayerBalanceHiglightingNegative ? .red : .secondaryBackground))
                .cornerRadius(13)
                .padding(.leading, 5)
//                .onTapGesture {
//                    viewModel.message = .propertyList(viewModel.myPlayerPosition.bought.compactMap({ (key: Step, value: PlayerStepModel.Upgrade) in
//                            .init(owner: "You", ownerUpgrade: value, property: key)
//                    }))
//                }
                Spacer()
                HStack {
                    Image(.robot)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 45, height: 45)
                        .cornerRadius(40)
                    VStack(alignment:.leading) {
                        Text("Enemy balance")
                            .font(.system(size: 12))
                            .foregroundColor(.secondaryText)
                            .frame(alignment: .leading)
                        Text("\(viewModel.enemyPosition.balance)")
                            .font(.system(size: 18, weight:.bold))
                            .foregroundColor(.white)
                            .frame(alignment: .leading)
                    }
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 10)
                .background(viewModel.robotBalanceHiglightingPositive ? .green : (viewModel.robotBalanceHiglightingNegative ? .red : .secondaryBackground))
                .cornerRadius(13)
                
                Spacer()
            }
            .padding(.top, 15)
        }
    }
    
    
    var panelView: some View {
        VStack(spacing:-27) {
            VStack {
                Button("dice") {
                    viewModel.resumeNextPlayer(forceMove: true)
                }
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .background(.primaryBackground)
            .disabled(viewModel.updateBalancePresenting)
            HStack() {
                ForEach(GameViewModel.PanelType.allCases, id:\.rawValue) { type in
                    Button {
                        viewModel.activePanelType = type
                    } label: {
                        VStack {
                            Image(type.rawValue.lowercased())
                                .resizable()
                                .scaledToFit()
                                .frame(height:37)
                            Text(type.rawValue.capitalized)
                                .font(.system(size: 11, weight:.semibold))
                        }
                        .padding(.vertical, 4)
                        .frame(width:56)
                        .background(.lightsecondaryBackground)
                        .cornerRadius(9)
                    }
                    if GameViewModel.PanelType.allCases.last != type {
                        Spacer()
                    }
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity)
            
            .background {
                RoundedRectangle(cornerRadius: .zero)
                    .fill(.clear)
                    .background {
                        Color(.secondaryBackground)
                            .cornerRadius(27)
                            .padding(.bottom, -27)
                    }
                    .clipped()
            }
        }
    }
    
    func vBoard(_ section:Int) -> some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(.clear)
            .frame(height: viewModel.itemWidth)
            .overlay(content: {
                HStack(spacing:0) {
                    items(section, isVerticalStack: true)
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
                    items(section, isVerticalStack: false)
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
    
    func propertyName(_ step:Step, section:Int) -> some View {
        VStack(content: {
            Text(step.attributedTitle(.small))
                .font(.system(size: 10))
                .foregroundColor(.black)
                .overlay {
                    if let occupied = viewModel.occupiedByPlayer(step) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(occupied.id == viewModel.myPlayerPosition.id ? .red : .blue)
                            .frame(width:20, height: 20)
                            .offset(y:[0, 3].contains(section) ? 20 : -20)
                    }
                    
                }
        })
    }
    
    func propertyBackgroundView(_ step:Step, isFirst:Bool, isVerticalStack:Bool, section:Int) -> some View {
        RoundedRectangle(cornerRadius: 5)
            .fill(.lightGreen)
            .overlay(content: {
                RoundedRectangle(cornerRadius: 5)
                    .stroke(Color.red, lineWidth: 2)
            })
            .overlay(content: {
                if isVerticalStack {
                    VStack {
                        if section == 0 {
                            Spacer()
                        }
                        RoundedRectangle(cornerRadius: 5)
                            .fill(step.color?.color ?? .gray)
                            .frame(height: viewModel.itemWidth / 3)
                            .overlay {
                                propertyName(step, section: section)
                                    .opacity(step.buyPrice == nil ? 0.5 : 1)
                            }
//                            .clipped()
                        if section != 0 {
                            Spacer()
                        }
                        
                    }
                } else {
                    HStack {
                        if section == 3 {
                            Spacer()
                        }
                        RoundedRectangle(cornerRadius: 5)
                            .fill(step.color?.color ?? .gray)
                            .frame(width: viewModel.itemWidth / 3)
                            .overlay {
                                propertyName(step, section: section)
                                    .rotationEffect(.degrees(-90))
                                    .frame(width: viewModel.itemWidth)
                                    .opacity(step.buyPrice == nil ? 0.5 : 1)
                            }
//                            .clipped()
                        if section != 3 {
                            Spacer()
                        }
                        
                    }
                }
            })
            .frame(width: (viewModel.itemWidth - 8) - (isVerticalStack ? (isFirst ? 0 : 10) : 0), height: (viewModel.itemWidth - 8) - (!isVerticalStack ? (isFirst ? 0 : 10) : 0))
    }
    
    func propertyText(_ step:Step, _ isVerticalStack:Bool, _ section:Int) -> some View {
        HStack(content: {
            if !isVerticalStack {
                if section == 1 {
                    Spacer()
                }
            }
            VStack {
                if isVerticalStack {
                    if section != 0 {
                        Spacer()
                    }
                }
                Text("\(step.index)")
                    .font(.system(size: 10, weight:.semibold))
                    .multilineTextAlignment(.leading)
                    .foregroundColor(.black)
                if let price = step.buyPrice {
                    Text("$\(price)")
                        .font(.system(size: 9))
                    
                        .multilineTextAlignment(.leading)
                        .foregroundColor(.black.opacity(0.3))
                }
                if isVerticalStack {
                    if section == 0 {
                        Spacer()
                    }
                }
                
            }
            if !isVerticalStack {
                if section != 1 {
                    Spacer()
                }
            }
        })
        .padding(5)
    }
    
    func propertyItem(_ step:Step, isFirst:Bool, isVerticalStack:Bool, section:Int) -> some View {
        let disabled = viewModel.propertyTapDisabled(step)
        return Button(action: {
            viewModel.propertySelected(step)
        }, label: {
            ZStack  {
                propertyBackgroundView(step, isFirst: isFirst, isVerticalStack: isVerticalStack, section: section)
                propertyText(step, isVerticalStack, section)
                //                .frame(maxWidth: viewModel.itemWidth - 20, maxHeight: viewModel.itemWidth - 20)
            }
        })
        .disabled(disabled)
        .opacity(disabled ? 0.1 : 1)
    }
    
    func items(_ section: Int, isVerticalStack:Bool) -> some View {
        //        let current = (section) * Step.numberOfItemsInSection
        let items = Step.items(section)
        return ForEach(items, id:\.rawValue) { i in
            propertyItem(i, isFirst: i == (isVerticalStack && section == 0 ? items.last : (!isVerticalStack && section == 1 ? items.last : items.first)), isVerticalStack:isVerticalStack, section: section)
                .overlay {
                    if let upgrade = viewModel.myPlayerPosition.bought[i] {
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                if upgrade.index == 0 {
                                } else {
                                    Image("upgrades/\(upgrade.index)")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width:30)
                                }
                            }
                        }
                    }
                    if let upgrade = viewModel.enemyPosition.bought[i] {
                        VStack {
                            HStack {
                                if upgrade.index == 0 {
                                } else {
                                    Image("upgrades/\(upgrade.index)")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width:30)
                                }
                                
                                Spacer()
                            }
                            Spacer()
                            
                        }
                    }
                }
            
        }
    }
    
    
    func playerOverlay(at:Int, player:Int) -> some View {
        return VStack {
            switch at {
            case 3:
                
                if (3 * Step.numberOfItemsInSection..<4 * Step.numberOfItemsInSection).contains(viewModel.playersArray[player].playerPosition.index) {
                    VStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(player == 0 ? .pink : .blue)
                            .aspectRatio(1, contentMode: .fit)
                            .offset(y:CGFloat((30 - viewModel.playersArray[player].playerPosition.index) * -Int((viewModel.itemWidth - 8) - 10)))
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
                            .offset(x:CGFloat((0 - viewModel.playersArray[player].playerPosition.index) * Int((viewModel.itemWidth - 8) - 10)))
                        
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
                            .offset(y:CGFloat((10 - viewModel.playersArray[player].playerPosition.index) * Int((viewModel.itemWidth - 8) - 10)))
                        
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
                            .offset(x:CGFloat((20 - viewModel.playersArray[player].playerPosition.index) * -Int((viewModel.itemWidth - 8) - 10)))
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
    GameView(isPresenting: .constant(true))
}


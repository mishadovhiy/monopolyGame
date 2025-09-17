//
//  ContentView.swift
//  MonopolyGame
//
//  Created by Mykhailo Dovhyi on 03.04.2025.
//

import SwiftUI

struct GameView: View {
    @StateObject var viewModel:GameViewModel
    @EnvironmentObject var db: AppData
    @Environment(\.scenePhase) private var scenePhase
    @Binding var isPresenting: Bool
    
    init(
        isPresenting: Binding<Bool>,
        enemyConnectionType: MultiplierManager.ConnectionType
    ) {
        _viewModel = StateObject(wrappedValue: .init(enemyConnectionType: enemyConnectionType))
        self._isPresenting = Binding(projectedValue: isPresenting)
    }
    
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
        .onChange(of: viewModel.diceDestination) { newValue in
            db.audioManager?.play(.menu)
        }
        .onChange(of: viewModel.myPlayerBalanceHiglightingPositive) {  newValue in
            if newValue {
                db.audioManager?.play(.money)
                
            }
        }
        .onChange(of: viewModel.myPlayerBalanceHiglightingNegative) {  newValue in
            if newValue {
                db.audioManager?.play(.money)
                
            }
        }
        .onChange(of: viewModel.updateBalancePresenting) { newValue in
            if newValue {
                db.audioManager?.play(.loose)
            }
        }
        .onAppear {
            viewAppeared()
            //            viewModel.bet.betProperty = .orange3
            
        }
        .overlay {
            PopupView(dataType: $viewModel.message, buttonData: $viewModel.messagePressed, secondaryButton: $viewModel.messagePressedSecondary)
        }
        .overlay(content: {
            if viewModel.adPresenting {
                AdPresenterRepresentable(dismissed:{
                    print("dismissedsdas")
                    viewModel.adPresenting = false
                })
            } else {
                VStack {
                    
                }
                .disabled(true)
            }
        })
        .navigationBarHidden(true)
    }
    
    func viewAppeared() {
        if viewModel.viewAppeared {
            return
        }
        viewModel.viewAppeared = true
        viewModel.enemyLostAction = {
            db.db.gameProgress = .init()
            if db.db.settings.usingGameCenter ?? false {
                db.gameCenter.addGameCompletionScore(viewModel.myPlayerPosition)
            }
            db.db.gameCompletions.completionList.append(.init(balance: viewModel.myPlayerPosition.balance, time: .init(), upgrades: viewModel.myPlayerPosition.bought))
            db.audioManager?.play(.wone)
        }
        viewModel.dbHolder = db.db
        if db.db.settings.usingGameCenter == nil {
            viewModel.message = .custom(MessageContent(title: "Game center score usage",description:"Would you like to upload scores into the Game Center Leadership board? \n\nUpon successful completion levels, we will upload your level score into the Leadership board\nThis will include - your balance for the level, and total property price, that you own"))
            viewModel.messagePressed = .init(title: "OK", pressed: {
                db.db.settings.usingGameCenter = true
            })
            viewModel.messagePressedSecondary = .init(title: "Decline", pressed:{
                db.db.settings.usingGameCenter = false
                
            })
        }
        Task(priority: .low) {
            if StorekitModel.needAdd(db: &db.db) {
                //                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
                //                    viewModel.adPresenting = true
                //                })
            }
        }
        if !db.db.gamePlayed {
            db.db.gamePlayed = true
        }
    }
    
    func chanceCardBackground(_ isOnTop:Bool) -> some View {
        RoundedRectangle(cornerRadius: 6)
            .fill(Color(isOnTop ? .blue : .orange))
            .overlay {
                HStack {
                    Spacer()
                    VStack {
                        Spacer()
                        Image(!isOnTop ? .chest : .question)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 50)
                        Spacer()
                    }
                    
                    Spacer()
                }
            }
    }
    
    func chanceContent(_ data:BoardCard?, isOnTop:Bool) -> some View {
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
                                db.audioManager?.play(.menu)
                                
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
                        chanceCardBackground(isOnTop)
                        
                    } else {
                        chanceContent(data, isOnTop: isOnTop)
                    }
                    
                }
                .shadow(radius: 5)
                .rotation3DEffect(
                    isOpened ? Angle(degrees: 180) : .zero,
                    axis: (x: 0.0, y: 1.0, z: 0.0)
                )
                .animation(.default, value: isOpened)
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
                Color(.lightGreen)
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
            .cornerRadius(10)
            .overlay(content: {
                if !viewModel.usingDice {
                    diceNumberView
                }
                
            })
            .overlay(content: {
                boardCardsOverley
            })
            .overlay(content: {
                diceSceneView
                
            })
            .padding(.horizontal, 0)
        }
    }
    
    @ViewBuilder
    var diceSceneView: some View {
        if viewModel.usingDice {
            DiceSceneView(dicePressed: $viewModel.dicePressed) { diceResult, isEquel in
                if isEquel {
                    viewModel.playerPosition.inJail = false
                }
                if !isEquel && viewModel.playerPosition.inJail {
                    
                } else {
                    viewModel.isEquelDices = isEquel
                }
                viewModel.dicePressed = false
                viewModel.diceDestination = diceResult
                viewModel.move()
            }
        }
    }
    
    var diceNumberView: some View {
        VStack {
            Spacer()
            Text("\(viewModel.diceDestination)")
                .multilineTextAlignment(.center)
                .font(.system(size: 24, weight:.semibold))
                .foregroundColor(.light)
                .padding(.vertical, 3)
                .padding(.horizontal, 15)
                .background(.primaryBackground.opacity(0.2))
                .cornerRadius(4)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .disabled(true)
    }
    
    var balancesView: some View {
        HStack {
            Spacer().frame(width: 60)
            HStack {
                HStack {
                    Spacer().frame(width:65)
                    VStack(alignment:.leading) {
                        Text("Your Balance " + ((self.viewModel.playerPosition.id == self.viewModel.myPlayerPosition.id) ? " + " : ""))
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
                Button(!viewModel.didFinishMoving ? "Dice" : "Done") {
                    db.audioManager?.play(.menu)
                    viewModel.diceDidPress()
                    
                }
                .tint(.primaryBackground)
                .font(.system(size: 14, weight:.semibold))
                .padding(.horizontal, 8)
                .padding(.vertical, 2)
                .background(.light)
                .cornerRadius(4)
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .background(.primaryBackground)
            .opacity(viewModel.updateBalancePresenting || viewModel.playerPosition.id != viewModel.myPlayerPosition.id ? 0 : 1)
            .disabled(viewModel.updateBalancePresenting || viewModel.playerPosition.id != viewModel.myPlayerPosition.id)
            HStack() {
                ForEach(GameViewModel.PanelType.allCases, id:\.rawValue) { type in
                    Button {
                        db.audioManager?.play(.menuRegular)
                        
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
                            .fill(viewModel.myPlayerPosition.bought.keys.contains(step) ? .red : .blue)
                            .frame(width:20, height: 20)
                            .offset(y:[0, 3].contains(section) ? 20 : -20)
                    }
                    
                }
        })
    }
    
    func propertyBackgroundView(_ step:Step, isFirst:Bool, isVerticalStack:Bool, section:Int) -> some View {
        RoundedRectangle(cornerRadius: 0)
            .fill(Color(.lightGreen))
            .overlay(content: {
                ZStack {
                    RoundedRectangle(cornerRadius: 0)
                        .stroke(Color.black, lineWidth: 1)
                    if let image = step.backgroundImage {
                        Image(image)
                            .resizable()
                            .scaledToFit()
                            .opacity(0.4)
                            .shadow(radius: 3)
                            .padding(step == .parking || step == .jail1 ? 0 : 5)
                    }
                }
                
                .clipped()
            })
            .overlay(content: {
                if isVerticalStack {
                    VStack {
                        if section == 0 {
                            Spacer()
                        }
                        if let color = step.color?.color {
                            RoundedRectangle(cornerRadius: 5)
                                .fill(step.color?.color ?? .clear)
                                .opacity(0.8)
                                .frame(height: viewModel.itemWidth / 3)
                                .overlay {
                                    propertyName(step, section: section)
                                        .opacity(step.buyPrice == nil ? 0.5 : 1)
                                }
                            //                            .clipped()
                        }
                        if section != 0 {
                            Spacer()
                        }
                        
                    }
                } else {
                    HStack {
                        if section == 3 {
                            Spacer()
                        }
                        if let color = step.color {
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
                        }
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
                Text("\(step.index + 1)")
                    .font(.system(size: 10, weight:.semibold))
                    .multilineTextAlignment(.leading)
                    .foregroundColor(.primaryBackground)
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
            db.audioManager?.play(.menuRegular)
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
                            .fill(.clear)
                            .aspectRatio(1, contentMode: .fit)
                            .overlay(content: {
                                Image(player == 0 ? .pawn : .pawn1)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width:20)
                                    .offset(x:player == 0 ? -10 : 10)
                                    .shadow(radius: 5)
                                
                            })
                            .offset(y:CGFloat((30 - viewModel.playersArray[player].playerPosition.index) * -Int((viewModel.itemWidth - 8) - 10)))
                        Spacer()
                        
                    }
                    .animation(.bouncy, value: viewModel.playersArray[player].playerPosition.index)
                }
            case 0:
                if (0 * Step.numberOfItemsInSection..<1 * Step.numberOfItemsInSection).contains(viewModel.playersArray[player].playerPosition.index) {
                    HStack {
                        Spacer()
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.clear)
                            .aspectRatio(1, contentMode: .fit)
                            .overlay(content: {
                                Image(player == 0 ? .pawn : .pawn1)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width:20)
                                    .offset(x:player == 0 ? -10 : 10)
                                    .shadow(radius: 5)
                                
                            })
                            .offset(x:CGFloat((0 - viewModel.playersArray[player].playerPosition.index) * Int((viewModel.itemWidth - 8) - 10)))
                        
                    }
                    .animation(.bouncy, value: viewModel.playersArray[player].playerPosition.index)
                    
                }
            case 1:
                if (1 * Step.numberOfItemsInSection..<2 * Step.numberOfItemsInSection).contains(viewModel.playersArray[player].playerPosition.index) {
                    VStack {
                        Spacer()
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.clear)
                            .aspectRatio(1, contentMode: .fit)
                            .overlay(content: {
                                Image(player == 0 ? .pawn : .pawn1)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width:20)
                                    .offset(x:player == 0 ? -10 : 10)
                                    .shadow(radius: 5)
                                
                            })
                            .offset(y:CGFloat((10 - viewModel.playersArray[player].playerPosition.index) * Int((viewModel.itemWidth - 8) - 10)))
                        
                    }
                    .animation(.bouncy, value: viewModel.playersArray[player].playerPosition.index)
                    
                }
            case 2:
                if (2 * Step.numberOfItemsInSection..<3 * Step.numberOfItemsInSection).contains(viewModel.playersArray[player].playerPosition.index) {
                    HStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.clear)
                            .aspectRatio(1, contentMode: .fit)
                            .overlay(content: {
                                Image(player == 0 ? .pawn : .pawn1)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width:20)
                                    .offset(x:player == 0 ? -10 : 10)
                                    .shadow(radius: 5)
                            })
                            .offset(x:CGFloat((20 - viewModel.playersArray[player].playerPosition.index) * -Int((viewModel.itemWidth - 8) - 10)))
                        Spacer()
                    }
                    .animation(.bouncy, value: viewModel.playersArray[player].playerPosition.index)
                    
                }
            default:Text("?")
            }
        }
    }
}

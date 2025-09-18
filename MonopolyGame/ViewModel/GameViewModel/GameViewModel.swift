//
//  GameViewModel.swift
//  MonopolyGame
//
//  Created by Mykhailo Dovhyi on 08.04.2025.
//

import SwiftUI
import Combine

class GameViewModel: ObservableObject {
    
    private var balanceChangeHolder:Int = 0
    var chests:[BoardCard] = .chest.shuffled()
    var chances:[BoardCard] = .chance.shuffled()
    var round:GameRound = .init()
    @Published var adPresenting = false
    @Published var activePanelType:PanelType?
    @Published var diceDestination:Int = 0
    @Published var updateBalancePresenting:Bool = false
    @Published var currentPlayerIndex:Int = 0
    @Published var didFinishMoving:Bool = false
    @Published var moveCompleted:Bool = true

    let multiplierModel: MultiplierManager
    private var cancellables = Set<AnyCancellable>()
    
    init(enemyConnectionType: MultiplierManager.ConnectionType) {
        multiplierModel = .init(type: enemyConnectionType)
        multiplierModel.delegate = self
        
        multiplierModel.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }
    private var canFetchDB = true
    var enemyLostAction:(()->())?
    var isEquelDices = false
    #warning("declare bancopcy - save to db")
    #warning("if morgage - show morgage icon")//!!
    #warning("buy transport")//!!
    //show porperty ouner color on top of property name
    #warning("buy presed - if not enought balance - nothing heppens, need to show auction only")
#warning("implement: special card: lose move")
#warning("player moved to example decreese rent")
    @Published var chestPresenting:BoardCard? = nil {
        willSet {
            if chestPresenting != nil && newValue == nil {
                multiplierModel.action(.init(value: "", key: .bottomCard))
            }
        }
        didSet {
            boardCardDidUpdate(false)
            sendMyPlayerData()

        }
    }
    
    @Published var chancePresenting:BoardCard? = nil {
        willSet {
            if chancePresenting != nil && newValue == nil {
                multiplierModel.action(.init(value: "", key: .topCard))
            }
        }
        didSet {
            boardCardDidUpdate(true)
            sendMyPlayerData()
        }
    }
    @Published var myPlayerPosition: PlayerStepModel = .init(playerPosition: .go) {
        willSet {
            balanceChangeHolder = myPlayerPosition.balance
        }
        didSet {
            checkPlayerBalance(false)
            sendMyPlayerData()
        }
    }
    
    @Published var enemyPosition:PlayerStepModel = .init(playerPosition: .go) {
        willSet {
            balanceChangeHolder = enemyPosition.balance
        }
        didSet {
            checkPlayerBalance(true)
        }
    }
    
    @Published var message:PopupView.PopupType?
    @Published var messagePressed:ButtonData? = nil
    @Published var messagePressedSecondary:ButtonData? = nil
    var viewAppeared = false
    var dbUpdated = false
    @Published var bet:BetModel = .init(betValue: 0)
    @Published var myPlayerBalanceHiglightingPositive = false
    @Published var myPlayerBalanceHiglightingNegative = false
    
    @Published var robotBalanceHiglightingPositive = false
    @Published var robotBalanceHiglightingNegative = false
    
    @Published var trade:Trade = .init() {
        didSet {
            if (trade.tradeAmount * 100) < 0 {
                trade.tradeAmount = 0
            }
            if Int(trade.tradeAmount * 100) > myPlayerPosition.balance {
                trade.tradeAmount = Float(myPlayerPosition.balance / 100)
            }
        }
    }
    @Published var gameCompleted: Bool = false
    @Published var deviceWidth: CGFloat = 0
    @Published var usingDice = false
    @Published var dicePressed: Bool = false
    var itemWidth: CGFloat = 60
    var moovingBack: Bool = false
    @Published var selectingProperty:BoardCard.Action.PropertySelectionAction?
    
    func playerCompletedMoving() {
        self.didFinishMoving = true
        self.moveCompleted = true
        if self.multiplierModel.type != .AiRobot && playerPosition.id != myPlayerPosition.id {
            return
        }
        let property = playerPosition.playerPosition
        payRent(property: property)
        if playerPosition.id == myPlayerPosition.id {
            askPlayerToBuy(property: property)
        } else {
            if self.multiplierModel.type == .AiRobot {
                enemyCompletedMooving(property: property)
            } else {
                
            }
        }
        movingCompletedCheckProperty(property)
    }

    func diceDidPress() {
        if multiplierModel.type.canConnect {
            if !didFinishMoving {
                performDice()
            } else {
                self.performNextPlayer(isToEnemy: true)
            }
        } else {
            if !didFinishMoving {
                performDice()
            } else {
                self.didFinishMoving = false
                self.setNextPlayer()

            }
        }
    }
    
    func performDice() {
        self.moveCompleted = false
        dicePressed = true
    }
    
    private func setNextPlayer(toPlayerID: UUID? = nil, canMove: Bool = true) {
        print(myPlayerPosition.id == self.playerPosition.id, " gterfwedaws ")
        didFinishMoving = false
        if !self.multiplierModel.type.canConnect && self.enemyPosition.id == self.playerPosition.id && self.playerPosition.inJail {
            self.enemyInJail()
        }
        let array = playersArray
        //test bellow when no chance
//        if !self.multiplierModel.type.canConnect && (chestPresenting != nil || chancePresenting != nil) && self.enemyPosition.id == self.playerPosition.id {
//            return
//        }
        if let toPlayerID,
            let targetIndex = array.firstIndex(where: {
            $0.id == toPlayerID
        }) {
            if isEquelDices {
                isEquelDices = false

            } else {
                currentPlayerIndex = targetIndex
            }
        } else {
            if !isEquelDices {
                currentPlayerIndex += 1
            } else {
                isEquelDices = false
            }
            if currentPlayerIndex > array.count - 1 {
                currentPlayerIndex = 0
            }
        }

        if myPlayerPosition.id != self.playerPosition
            .id && !self.multiplierModel.type.canConnect {
            
            performDice()
        }
    }
    
    func performNextPlayer(force: Bool = false, isToEnemy: Bool = false) {
        let _ = playersArray
            self.multiplierModel.action(.init(value: "", key: .okPressed))
        sendMyPlayerData()
        sendEnemyData()

        if !multiplierModel.type.canConnect {
            if self.enemyPosition.id == self.playerPosition.id && self.playerPosition.inJail {
                self.enemyInJail()
            }
        } else {
            self.setNextPlayer(toPlayerID: isToEnemy ? enemyPosition.id : nil)
        }
    }
    
    func saveProgress(db:inout AppData.DataBase) {
        let progressKey: String
        switch multiplierModel.type {
        case .bluetooth:
            progressKey = multiplierModel.connectedDeviceID ?? multiplierModel.type.rawValue
        default:
            progressKey = multiplierModel.type.rawValue
        }
        db.gameProgress.updateValue(.with({
            $0.player = myPlayerPosition
            $0.enemy = enemyPosition
            $0.round = round
        }), forKey: progressKey)
        db.savePlayDate()
    }
    
    /// sets game progress, after multiplayer device connected. parameter sets to nil after progress setted
    var dbHolder: AppData.DataBase? {
        didSet {
            if !multiplierModel.type.canConnect {
                fetchGame()
            }
        }
    }
    
    private var isGameStarted: Bool {
        dbHolder == nil
    }
    
    private func fetchGame() {
        guard let db = dbHolder else {
            return
        }
        self.usingDice = db.settings.game.usingDice

        let progressKey: String
        switch multiplierModel.type {
        case .bluetooth:
            progressKey = multiplierModel.connectedDeviceID ?? multiplierModel.type.rawValue
        default:
            progressKey = multiplierModel.type.rawValue
        }
        let progress = db.gameProgress[progressKey] ?? .init()
        if progress.player.playerPosition == .go && progress.enemy.playerPosition == .go {
            self.myPlayerPosition.balance = db.settings.game.balance
            self.enemyPosition.balance = db.settings.game.balance
        } else {
            self.myPlayerPosition = progress.player
            self.enemyPosition = progress.enemy
        }
        if !multiplierModel.isPrimaryDevice {
            setNextPlayer()
        } else {
            self.enemyPosition.id = .init()
            self.myPlayerPosition.id = .init()
            self.multiplierModel.action(.init(value: "\(myPlayerPosition.id.uuidString)", key: .enemyID))
            self.multiplierModel.action(.init(value: "\(enemyPosition.id.uuidString)", key: .playerID))
            self.multiplierModel.action(.init(value: enemyPosition.playerPosition.rawValue, key: .enemyPosition))

            self.sendEnemyData()
        }
        self.dbHolder = nil
    }
    
    func propertySelected(_ step: Step) {
        if let _ = selectingProperty {
            withAnimation {
                selectingProperty = nil
                chancePresenting = nil
                chestPresenting = nil
            }
            return
        }
        if activePanelType != nil {
            boardActionPropertySelected(step)
        } else {
            let owner = playersArray.first(where: {
                $0.bought.first { (key: Step, value: PlayerStepModel.Upgrade) in
                    key == step
                } != nil
            })
            self.message = .property(.init(owner: myPlayerPosition.bought.keys.contains(step) ? "You" : "Robot", ownerUpgrade: owner?.bought[step], property: step))
        }
    }
    
    func propertyTapDisabled(_ step: Step) -> Bool {
        if selectingProperty != nil {
            if self.playersArray.first(where: {$0.bought[step] != nil}) != nil {
                return false
            } else {
                return true
            }
        }
        guard let activePanelType else {
            return false
        }
        switch activePanelType {
        case .build:
            if self.myPlayerPosition.bought[step] != nil {
                return !myPlayerPosition.canUpdateProperty(step)
            }
            return true
        case .morgage:
            if let upgrade = self.myPlayerPosition.bought[step],
               !self.myPlayerPosition.morgageProperties.contains(step)
            {
                return upgrade != .bought
            }
            return true
        case .redeem:
            return !self.myPlayerPosition.morgageProperties.contains(step)
        case .sell:
            if let upgrade = self.myPlayerPosition.bought[step] {
                return upgrade == .bought || upgrade.previousValue == nil
            }
            return true
        case .trade:
            return true
        }
    }
        
    func boardActionPropertySelected(_ step: Step) {
        switch activePanelType {
        case .trade:
            break
        case .build:
            if self.myPlayerPosition.canUpdateProperty(step)
            {
                self.myPlayerPosition.upgradePropertyIfCan(step)
            }
        case .sell:
            if let upgrade = self.myPlayerPosition.bought[step],
               let price = step.rentTotal(upgrade),
               let newValue = upgrade.previousValue
            {
                self.myPlayerPosition.balance += price
                self.myPlayerPosition.bought.updateValue(newValue, forKey: step)
            }
            
        case .morgage:
            if let _ = self.myPlayerPosition.bought[step],
               let price = step.morgage,
               !self.myPlayerPosition.morgageProperties.contains(step)
            {
                self.myPlayerPosition.balance += price
                self.myPlayerPosition.morgageProperties.append(step)
            }
        case .redeem:
            if let upgrade = self.myPlayerPosition.bought[step],
               upgrade == .bought,
               self.myPlayerPosition.morgageProperties.contains(step),
               let price = step.morgage
            {
                self.myPlayerPosition.balance -= price
                self.myPlayerPosition.morgageProperties.removeAll(where: {
                    $0 == step
                })
            }
        case nil:
            break
        }
    }
    
    var myPlayerInJail:Bool {
        myPlayerPosition.inJail
    }
    
    var canDice:Bool {
        let array = [moveCompleted,
                     bet.betProperty == nil,
                     activePanelType == nil,
                     !trade.isPresenting,
                     chestPresenting == nil,
                     chancePresenting == nil,
                     message == nil,
                     (myPlayerInJail && myPlayerPosition.id == playerPosition.id ? false : (myPlayerPosition.id != playerPosition.id ? true : !myPlayerInJail))
        ]
        return !array.contains(false)
    }
    
    var playerPosition:PlayerStepModel {
        get {
            return playersArray[currentPlayerIndex]
        }
        set {
            playersArray[currentPlayerIndex] = newValue
        }
    }
    
    var playersArray:[PlayerStepModel] {
        get {
            [myPlayerPosition, enemyPosition]
        }
        set {
            myPlayerPosition = newValue[playersArray.firstIndex(where: {$0.id == myPlayerPosition.id}) ?? 0]
            enemyPosition = newValue[playersArray.firstIndex(where: {$0.id == enemyPosition.id}) ?? 0]
        }
    }

    func enemyLost() {
        gameCompleted = true
        enemyLostAction?()
    }
    
    func checkPlayerBalance(_ isEnemy:Bool) {
        let player = isEnemy ? enemyPosition : myPlayerPosition
        if player.balance != balanceChangeHolder {
            
            if player.balance > balanceChangeHolder {
                if isEnemy {
                    robotBalanceHiglightingPositive = true
                } else {
                    myPlayerBalanceHiglightingPositive = true
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
                    if isEnemy {
                        self.robotBalanceHiglightingPositive = false
                    } else {
                        self.myPlayerBalanceHiglightingPositive = false
                    }
                    
                })
            } else if player.balance < balanceChangeHolder {
                if isEnemy {
                    robotBalanceHiglightingNegative = true
                } else {
                    myPlayerBalanceHiglightingNegative = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
                    if isEnemy {
                        self.robotBalanceHiglightingNegative = false
                    } else {
                        self.myPlayerBalanceHiglightingNegative = false
                    }
                })
            }
            balanceChangeHolder = 0
        }
    }
    
    func setBetDeclined() {
        if multiplierModel.type.canConnect {
            multiplierModel.action(.init(value: "", key: .auctionBetValue))
        }
        if let property = bet.betProperty {
            if bet.bet.last?.0.id == myPlayerPosition.id {
                myPlayerPosition.buyIfCan(property, price: bet.bet.last?.1 ?? 1)

            } else {
                enemyPosition.buyIfCan(property, price: bet.bet.last?.1 ?? 1)
            }
            bet = .init()
        }
    }
    
    func robotBet() {
        multiplierModel.action(
            .init(value: self.bet.betProperty?.rawValue ?? "",
                  key: .auctionBetValue,
                  additionalValue: "\(self.bet.bet.last?.1 ?? 0)",
                  data: !self.multiplierModel.type.canConnect ? [
                    self.enemyPosition, self.playerPosition
                  ].decode : nil))
    }
    
    private func checkPlayersBalance() {
        if myPlayerPosition.id == self.playerPosition.id {
            if myPlayerPosition.balance <= 0 {
                updateBalancePresenting = true
            }
        } else {
            self.multiplierModel.action(.init(value: "", key: .robotIncreesBalancePrediction, data: enemyPosition.decode))
        }
    }
    
    private func checkEnemyCanUpgradeProperties() {
        self.multiplierModel.action(.init(value: "", key: .robotUpgradePropertiesPrediction, data: [enemyPosition, myPlayerPosition].decode))
    }

    func move() {
        moveCompleted = false
        let moveDisabled = playerPosition.inJail && !isEquelDices
        if !moveDisabled {
            if playerPosition.specialCards.contains(.looseMove) {
                var removed = false
                playerPosition.specialCards.removeAll { card in
                    if card == .looseMove && !removed {
                        removed = true
                        return true
                    } else {
                        return false
                    }
                }
                playerPosition.playerPosition = Step.allCases.first(where: {
                    (playerPosition.playerPosition.index) == $0.index
                }) ?? .go
                diceDestination = 0
            } else {
                withAnimation {
                    playerPosition.playerPosition = Step.allCases.first(where: {
                        (playerPosition.playerPosition.index + (moovingBack ? -1 : 1)) == $0.index
                    }) ?? .go
                }
            }
            
        }
        if playerPosition.playerPosition == .go {
            playerPosition.balance += 200
            if playerPosition.id == enemyPosition.id {
                round.enemyRound += 1
            } else {
                round.playerRound += 1
            }
        }
        diceDestination -= 1
        if diceDestination >= 1 {
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300), execute: {
                self.move()
            })
        } else {
            self.playerCompletedMoving()
            self.checkPlayersBalance()
            moovingBack = false
        }
    }
    
    func askPlayerToBuy(property:Step) {
        if property.buyPrice != nil && myPlayerPosition.bought[property] == nil && occupiedByPlayer(property) == nil {
            self.messagePressed = .init(title: "Buy", pressed: {
                if self.myPlayerPosition.balance < (property.buyPrice ?? 0) {
                    self.bet.playerPalance = self.myPlayerPosition.balance
                    self.bet.betProperty = property
                } else {
                    self.myPlayerPosition.buyIfCan(property)
                }
                
            })
            self.messagePressedSecondary = .init(title: "auction", pressed: {
                self.bet.playerPalance = self.myPlayerPosition.balance
                self.bet.betProperty = property
                print(self.bet, " vyhukjygguh ")
            })
            self.message = .property(.init(property: property))
        }
    }

    func presentTradeProposalResponse(ok: Bool, didPress: Bool = false) {
        trade.tradeResponse = ok
        if trade.tradeResponse ?? false {
            trade.myPlayerProperties.forEach { step in
                self.enemyPosition.bought.updateValue(self.myPlayerPosition.bought[step] ?? .bought, forKey: step)
                self.myPlayerPosition.bought.removeValue(forKey: step)
            }
            trade.enemyProperties.forEach { step in
                self.myPlayerPosition.bought.updateValue(self.enemyPosition.bought[step] ?? .bought, forKey: step)
                self.enemyPosition.bought.removeValue(forKey: step)
            }
        }
        if didPress {
            self.multiplierModel.action(.init(value: "", key: .tradeProposal, data: trade.encode))

        } else {
            self.message = .custom(.init(title: "Robot \(trade.tradeResponse ?? false ? "Accepted" : "Declined") trade proposal", button: .init(title: "OK", pressed: {
                self.trade = .init()
                self.activePanelType = nil
            })))
        }
    }
    
    func acceptTradePressed(trading: Bool? = nil, didPress: Bool) {
        var test = self.enemyPosition
        test.balance = 9999
        trade.myPlayerProperties.forEach { step in
            test.bought.updateValue(.bought, forKey: step)
        }
        let colors = Array(Set(trade.myPlayerProperties.map { $0.color }))
        var canUpdateCount = 0
        colors.forEach { color in
            let properties = test.bought.keys.filter({$0.color == color})
            properties.forEach { step in
                if test.canUpdateProperty(step) {
                    canUpdateCount += 1
                }
            }
        }
        self.presentTradeProposalResponse(ok: trading ?? (canUpdateCount >= colors.count), didPress: didPress)
    }
    
    func occupiedByPlayer(_ property:Step) -> PlayerStepModel? {
        playersArray.first(where: { player in
            player.bought[property] != nil
        })
    }
    
    private func sendMyPlayerData(positionOnly: Bool = false) {
        if !positionOnly {
            multiplierModel.action(.init(value: "\(myPlayerPosition.balance)", key: .playerBalance))
            multiplierModel.action(.init(value: "", key: .playerMorgage, data: myPlayerPosition.morgageProperties.decode))
            multiplierModel.action(.init(value: "", key: .boughtPlayerProperties, data: myPlayerPosition.bought.decode))

        }
        multiplierModel.action(.init(value: myPlayerPosition.playerPosition.rawValue, key: .playerPosition))

    }
    
    private func sendEnemyData() {
        multiplierModel.action(.init(value: "\(enemyPosition.balance)", key: .enemyBalance))
    }
}


//MARK: completed mooving
fileprivate extension GameViewModel {
    
    #warning("after moving completed from bottom cards: next player not called")
    private func enemyCompletedMooving(property:Step) {
        print("enemyCompletedMoovingenemyCompletedMooving")
        if property.buyPrice == nil {
            checkEnemyCanUpgradeProperties()
            return
        }
        if occupiedByPlayer(property) == nil {
            self.multiplierModel.action(.init(value: property.rawValue, key: .roboBuyOrAuctionPrediction, data: [self.enemyPosition, self.myPlayerPosition].decode))
        }
        
        checkEnemyCanUpgradeProperties()
    }
    
    private func payRent(property:Step) {
        if let occupiedBy = occupiedByPlayer(property) {
            if let upgrade = occupiedBy.bought[property],
               occupiedBy.id != playerPosition.id, !occupiedBy.inJail {
                let amount = occupiedBy.morgageProperties.contains(property) ? 0 : (property.rentTotal(upgrade) ?? 0)
                playerPosition.balance -= amount
                playersArray.forEach { model in
                    if model.id == occupiedBy.id {
                        playersArray[playersArray.firstIndex(where: {$0.id == occupiedBy.id}) ?? 0].balance += amount
                    }
                }
            }
            return
        }
    }
    
    private func movingCompletedCheckProperty(_ property:Step) {
        if property.isChest || property.isChance {
            movingCompletedCheckChance(property)
        } else  {
            switch property {
            case .tax1:
                playerPosition.balance -= Int(CGFloat(playerPosition.bought.totalPrice.price + playerPosition.balance) / 10)
            case .tax2:
                playerPosition.balance -= 100
            case .jail1:
                playerPosition.inJail = true
            case .jail2:
                self.playerPosition.playerPosition = .jail1
                self.playerPosition.inJail = true
            case .win1:
                self.playerPosition.balance += 100
            default:break
            }
        }
    }
    
    #warning("move to robot manager")
    private func enemyInJail() {
        print("enemyInJailenemyInJail")
        if playerPosition.specialCards.contains(.outOfJail) {
            playerPosition.inJail = false
            var removed = false
            playerPosition.specialCards.removeAll { card in
                if card == .outOfJail && !removed {
                    removed = true
                    return true
                }
                return false
            }
            performDice()
        } else if playerPosition.balance >= 100 {
            playerPosition.inJail = false
            playerPosition.balance -= 100
            performDice()
        } else {
            performDice()
        }
        
    }
}


// MARK: chestChance
extension GameViewModel {
    private func movingCompletedCheckChance(_ property:Step) {
        if let first = (property.isChest ? chests.first : chances.first) {
            if property.isChest {
                chestPresenting = first
                chests.removeFirst()
            } else {
                chancePresenting = first
                chances.removeFirst()
            }
            
        } else {
            if property.isChest {
                chests = .chest
            } else if property.isChance {
                chances = .chance
            }
            self.movingCompletedCheckChance(property)
        }
    }
    //here
    //after chest/chance - player not setted to next if current player is enemy
    private func chestChanceDidSet() {
        guard let type = chestPresenting ?? chancePresenting else {
            return
        }
        switch type.action {
        case .propertySelection(let propertySelectionAction):
            if !playersArray.flatMap({$0.bought}).filter({$0.value.index >= 0}).isEmpty {
                selectingProperty = propertySelectionAction

                if !multiplierModel.type.canConnect && enemyPosition.id == playerPosition.id {
                    selectingProperty = nil
                    chestPresenting = nil
                    chancePresenting = nil
                    self.performNextPlayer()
                }
            } else {
                selectingProperty = nil
                if chestPresenting != nil {
                    chestPresenting = nil
                    if self.playerPosition.id == enemyPosition.id {
                        self.performNextPlayer()
                    }
                }
                
                if chancePresenting != nil {
                    chancePresenting = nil
                    if self.playerPosition.id == enemyPosition.id {
                        self.performNextPlayer()
                    }
                }
            }
        default:break
        }
    }
    
    private func boardCardDidUpdate(
        _ isTopCardList: Bool)
    {
        let presentingCard = !isTopCardList ? chestPresenting : chancePresenting
    
        print(presentingCard, " tgerfwedwefrg ")
        if presentingCard != nil {
            if !isTopCardList {
                chestChanceDidSet()

            }
            if presentingCard?.action != nil {
                multiplierModel.action(.init(value: presentingCard?.title ?? "", key: isTopCardList ? .topCard : .bottomCard))

            }

        } else {
            
        }
    }
    
    private func chestChanceOkPressed(_ action:BoardCard.Action?) {
        switch action {
        case .goTo(let step):
            self.chestOkPressedGoTo(step)
            self.move()
            
        case .moveIncrement(let int):
            self.moovingBack = int <= 0
            self.diceDestination = int * (int <= 0 ? -1 : 1)
            self.move()
            
        case .specialCard(let playerSpecialCard):
            playerPosition.specialCards.append(playerSpecialCard)
            
        case .balanceIncrement(let balanceIncrement):
            chestOkPressedBalanceIncrement(balanceIncrement)

        default:
            break
        }
    }
    
    func chestOkPressed() {
        let holder = chestPresenting
        chestPresenting = nil
        chestChanceOkPressed(holder?.action)
    }
    
    private func chestOkPressedGoTo(_ step:Step) {
        if step == .jail1 {
            playerPosition.inJail = true
            playerPosition.playerPosition = .jail1
            return
        }
        let destinationIndex:Int
        if step.color == nil {
            let number = "\(step.rawValue.number ?? 0)"
            let rawValue = step.rawValue.replacingOccurrences(of: number, with: "")
            let playerPositionIndex = playerPosition.playerPosition.index
            let property = Step.allCases.first {
                if playerPositionIndex >= $0.index {
                    if $0.rawValue.contains(rawValue) {
                        return true
                    }
                }
                return false
            } ?? Step.allCases.first(where: {
                $0.rawValue.contains(rawValue)
            })
            destinationIndex = property?.index ?? 0
        } else {
            destinationIndex = step.index
        }
        if myPlayerPosition.playerPosition.index >= destinationIndex {
            self.diceDestination = (40 + destinationIndex) - myPlayerPosition.playerPosition.index
        } else {
            self.diceDestination = destinationIndex - myPlayerPosition.playerPosition.index
        }
    }
    
    func chestOkPressedBalanceIncrement(_ balanceIncrement:BoardCard.Action.BalanceIncrement) {
        var i = 1
        switch balanceIncrement.from {
        case .otherPlayers:
            playersArray.forEach { player in
                if player.id != playerPosition.id {
                    let index = playersArray.firstIndex(where: {$0.id == player.id}) ?? 0
                    playersArray[index].balance += (balanceIncrement.amount * -1)
                }
            }
        case .houses:
            i = playerPosition.bought.filter { dict in
                dict.value.index >= 1
            }.count
            
        default:
            break
        }
        playerPosition.balance += (balanceIncrement.amount * i)
    }
    
    
    func chanceOkPressed() {
        let holder = chancePresenting
        chancePresenting = nil
        chestChanceOkPressed(holder?.action)
    }
}

extension GameViewModel: MultiplierManagerDelegate {
    func didReciveAction(_ action: MultiplierManager.ActionUnparcer?) {
        print(action?.key, " gterfwdasf")
        switch action?.key {
        case .none:
            break
        case .some(let type):
            switch type {
            case .robotLostGame:
                self.enemyLost()
                
            case .robotIncreesBalancePrediction, .roboBuyOrAuctionPrediction, .robotUpgradePropertiesPrediction:
                break //send only properties
                
            case .boughtPlayerProperties:
                self.enemyPosition.bought = .configure(action?.data) ?? self.enemyPosition.bought

            case .playerPosition:
                self.enemyPosition.playerPosition = .init(rawValue: action?.value ?? "") ?? .go
                
            case .enemyPosition:
                self.myPlayerPosition.playerPosition = .init(rawValue: action?.value ?? "") ?? .go

            case .playerMorgage:
                self.enemyPosition.morgageProperties = .configure(action?.data) ?? self.enemyPosition.morgageProperties
                
            case .enemyID:
                self.myPlayerPosition.id = .init(uuidString: action?.value ?? "")!

            case .playerID:
                self.enemyPosition.id = .init(uuidString: action?.value ?? "")!
                
            case .playerBalance:
                self.enemyPosition.balance = Int(action?.value ?? "") ?? self.enemyPosition.balance
                
            case .enemyBalance:
                self.myPlayerPosition.balance = Int(action?.value ?? "") ?? self.myPlayerPosition.balance

            case .okPressed:
                self.didFinishMoving = false
                self.setNextPlayer(toPlayerID: self.myPlayerPosition.id)

            case .auctionBetValue:
                if let _: Step = .init(rawValue: action?.value ?? "") {
                    self.bet.betProperty = .init(rawValue: action?.value ?? "") ?? .go
                    self.bet.bet.append((enemyPosition, Int(action?.additionalValue ?? "") ?? 0))
                } else {
                    if self.multiplierModel.type.canConnect {
                        if let property = bet.betProperty {
                            myPlayerPosition.buyIfCan(property, price: bet.bet.last?.1 ?? 1)
                            
                        }
                    } else {
                        //later: test only: setBetDeclined() can be called without checking self.multiplierModel.type.canConnect
                        self.setBetDeclined()
                    }
                    
                    bet = .init()
                }
                
            case .tradeProposal:
                trade = .configure(action?.data) ?? .init()
                trade.isPresenting = true
                trade.tradingByEnemy = true
                activePanelType = .trade
                
            case .tradeResponse:
                let ok = action?.value == "1"
                presentTradeProposalResponse(ok: ok)

            case .topCard:
                if !(action?.value.isEmpty ?? false) {
                    let data: BoardCard = .init(title: action?.value ?? "", text: [BoardCard].chance.first(where: {
                        $0.title == action?.value
                    })?.text ?? "", action: nil)
                    self.chancePresenting = data
                } else {
                    chancePresenting = nil
                }
                
            case .bottomCard:
                if !(action?.value.isEmpty ?? false) {
                    let data: BoardCard = .init(title: action?.value ?? "", text: [BoardCard].chest.first(where: {
                        $0.title == action?.value
                    })?.text ?? "", action: nil)
                    self.chestPresenting = data
                } else {
                    chestPresenting = nil
                }
                
            case .loosePressed:
                enemyLost()
            case .robotCompletedPredictions:
                
                //check presenting boardCard, change player
//                if self.chestPresenting == nil && chancePresenting == nil {
//                    
                    self.setNextPlayer()
//                }
            }
        }
    }
    
    func didConnect() {
        print("connecteddd ", isGameStarted)
        if !isGameStarted {
            self.fetchGame()
        }
    }
    
    func didDisconnect() {
        print("disconnecteddd")
    }
}

extension GameViewModel {
    enum PanelType:String, CaseIterable {
        case build, sell, morgage, redeem, trade
        var description: String {
            "Select properties to \(rawValue)"
        }
    }
}

//
//  GameViewModel.swift
//  MonopolyGame
//
//  Created by Mykhailo Dovhyi on 08.04.2025.
//

import SwiftUI

class GameViewModel:ObservableObject {
    @Published var diceDestination:Int = 0
    private var balanceChangeHolder:Int = 0
    var chests:[BoardCard] = .chest.shuffled()
    var chances:[BoardCard] = .chance.shuffled()
    var round:GameRound = .init()
    var coreMLModel:CoreMLManager = .init()
    
    #warning("declare bancopcy - save to db")
    #warning("if morgage - show morgage icon")//!!
    #warning("buy transport")//!!
    //show porperty ouner color on top of property name
    #warning("buy presed - if not enought balance - nothing heppens, need to show auction only")
#warning("implement: special card: lose move")
#warning("player moved to example decreese rent")
    @Published var chestPresenting:BoardCard? = nil {
        didSet {
            if chestPresenting != nil {
                chestChanceDidSet()
            }
        }
    }
    @Published var chancePresenting:BoardCard? = nil {
        didSet {
            if chancePresenting != nil {
                chestChanceDidSet()
            }
        }
    }
    @Published var myPlayerPosition:PlayerStepModel = .init(playerPosition: .go) {
        willSet {
            balanceChangeHolder = myPlayerPosition.balance
        }
        didSet {
            checkPlayerBalance(false)
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
    
    @Published var gameCompleted:Bool = false
    @Published var deviceWidth:CGFloat = 0
    var itemWidth:CGFloat = 60
    var moovingBack:Bool = false
    var selectingProperty:BoardCard.Action.PropertySelectionAction?
    
    func playerCompletedMoving() {
        self.moveCompleted = true
        let property = playerPosition.playerPosition
        payRent(property: property)
        if playerPosition.id == myPlayerPosition.id {
            askPlayerToBuy(property: property)
        } else {
            enemyCompletedMooving(property: property)
        }
        movingCompletedCheckProperty(property)
    }
    @Published var usingDice = false
    @Published var dicePressed:Bool = false
    
    func performDice() {
        if !usingDice {
            diceDestination = (2..<12).randomElement() ?? 0
            isEquelDices = diceDestination % 2 == 0
        } else {
            dicePressed = true
        }
    }
    
    func performNextPlayer() {
        let array = playersArray
        if !isEquelDices {
            currentPlayerIndex += 1
        } else {
            isEquelDices = false
        }
        if currentPlayerIndex > array.count - 1 {
            currentPlayerIndex = 0
        }
        if self.myPlayerPosition.id != self.playerPosition.id && self.playerPosition.inJail {
            self.enemyInJail()
        } else {
            self.performDice()
        }
//        dicePressed = true
        //check players special cards, example - move loosed
#warning("check if player is in jail - show popup")

    }
    
    @Published var activePanelType:PanelType?
    
    func saveProgress(db:inout AppData.DataBase) {
        db.gameProgress = .with({
            $0.player = myPlayerPosition
            $0.enemy = enemyPosition
            $0.round = round
        })
    }
    
    func fetchGame(db: AppData.DataBase) {
        self.usingDice = db.settings.game.usingDice
        if db.gameProgress.player.playerPosition == .go && db.gameProgress.enemy.playerPosition == .go {
            self.myPlayerPosition.balance = db.settings.game.balance
            self.enemyPosition.balance = db.settings.game.balance
        } else {
            self.myPlayerPosition = db.gameProgress.player
            self.enemyPosition = db.gameProgress.enemy
        }
    }
    
    func propertySelected(_ step: Step) {
        if let holder = selectingProperty {
            onPropertyMoved.updateValue(holder, forKey: step)
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
            self.message = .property(.init(owner: owner?.id == myPlayerPosition.id ? "You" : "Robot", ownerUpgrade: owner?.bought[step], property: step))
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
    
    var onPropertyMoved:[Step:BoardCard.Action.PropertySelectionAction] = [:]
    
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
            if let upgrade = self.myPlayerPosition.bought[step],
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
    var currentPlayerIndex:Int = 0
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
    
    @Published var moveCompleted:Bool = true
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
    var enemyLostAction:(()->())?
    func enemyLost() {
        gameCompleted = true
        enemyLostAction?()
        
    }
    var enemyMorgagedBalance = false
    @Published var updateBalancePresenting:Bool = false
    
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
    
    
    func enemySellAll(minMorgage:Int = 0) {
        if enemyPosition.balance >= 0 && minMorgage == 0 {
            return
        }
        enemyPosition.bought.forEach { (key: Step, value: PlayerStepModel.Upgrade) in
            if enemyPosition.balance < minMorgage {
                if let price = key.morgage,
                   value == .bought,
                   !enemyPosition.morgageProperties.contains(key) {
                    if minMorgage == 0 {
                        enemyPosition.morgageProperties.append(key)
                        enemyPosition.balance += price
                    } else if self.enemyPosition.canUpdateProperty(key, balance: minMorgage != 0 ? minMorgage : nil) {
                        enemyPosition.morgageProperties.append(key)
                        enemyPosition.balance += price
                    }
                    
                }
            }
        }
        var canRepeat = false
        if enemyPosition.balance < 0 {
            enemyPosition.bought.forEach { (key: Step, value: PlayerStepModel.Upgrade) in
                if enemyPosition.balance < 0 && !enemyPosition.morgageProperties.contains(key) {
                    if let price = key.buyPrice,
                       let prev = value.previousValue,
                       value != .bought {
                        enemyPosition.balance += (price / 2)
                        enemyPosition.bought.updateValue(prev, forKey: key)
                        canRepeat = true
                    }
                    if value == .bought {
                        canRepeat = true
                    }
                }
            }
        }
        if minMorgage == 0 {
            DispatchQueue.main.async {
                if self.enemyPosition.balance < 0 && !canRepeat {
                    self.enemyLost()
                } else if self.enemyPosition.balance <= 0 && canRepeat {
                    self.enemySellAll()
                }
            }
        }
        
        
    }
    
    func setBetWone() {
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
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds((250..<3000).randomElement() ?? 0), execute: {
            let last = self.bet.bet.last
            let differenceBalance = self.enemyPosition.balance - (last?.1 ?? 0)
            if differenceBalance <= 2 {
                self.setBetWone()
                return
            }
            var difference = last?.1 ?? 0 - (self.bet.betProperty?.buyPrice ?? 0)
            if difference <= 2 {
                difference = differenceBalance
                if [false, false, false, false, false, true, false, false, true].randomElement() ?? false {
                    self.setBetWone()
                    return
                }
            } 
            if difference <= 2 {
                self.setBetWone()
                return
            }
            let newBet = (last?.1 ?? 0) + Int.random(in: 1..<difference)
            if newBet <= self.enemyPosition.balance {
                let results = self.coreMLModel.predictAction(.init(type: .continiueBetting(.init(opponentBet: Double(last?.1 ?? 0), playerBet: Double(newBet))), base: .configure(self.enemyPosition, self.playerPosition)))
                switch results {
                case .continiueBetting(let response):
                    if response == .true {
                        self.bet.bet.append((self.enemyPosition, newBet))

                    } else {
                        self.setBetWone()
                    }
                default:
                    self.setBetWone()
                }
            } else {
                self.setBetWone()
            }

        })
    }
    
    func checkPlayersBalance() {
        if myPlayerPosition.id == self.playerPosition.id {
            if myPlayerPosition.balance <= 0 {
                updateBalancePresenting = true
            }
        } else {
            if enemyPosition.balance <= 250 && !enemyMorgagedBalance {
                enemyMorgagedBalance = true
                enemySellAll(minMorgage: 250)
            } else {
                enemyMorgagedBalance = false
            }
            if enemyPosition.balance <= 0 {
                self.enemySellAll()
            }
        }
    }
    
    private func checkEnemyCanUpgradeProperties() {
        let upgrades = enemyPosition.bought.filter {
            enemyPosition.canUpdateProperty($0.key)
        }.sorted(by: {$0.key.upgradePrice($0.value) >= $1.key.upgradePrice($1.value)})
        let maxUpgradeCountPerMove = 4
        var upgradedCount = 0
        upgrades.forEach { (key: Step, value: PlayerStepModel.Upgrade) in
            if let next = value.nextValue,
               self.enemyPosition.balance >= key.upgradePrice(next),
               maxUpgradeCountPerMove >= upgradedCount
            {
                let mlResponse = coreMLModel.predictAction(.init(type: .upgradeSkip(.configure(self.playerPosition, self.enemyPosition, step: key)), base: .configure(self.enemyPosition, self.playerPosition)))
                switch mlResponse {
                case .upgradeSkip(let skip):
                    if skip == .upgrade {
                        upgradedCount += 1
                        self.enemyPosition.upgradePropertyIfCan(key)
                        print("enemy upgrading property")
                    }
                default:break
                }
            }
        }
    }
    
    func resumeNextPlayer(forceMove:Bool = false) {
        self.performNextPlayer()
        if self.myPlayerPosition.id != self.playerPosition.id || forceMove {
            self.move()
        }
    }
    var isEquelDices = false
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
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500), execute: {
                self.move()
            })
        } else {
            self.playerCompletedMoving()
            self.checkPlayersBalance()
            moovingBack = false
            //check card holder actions
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
            })
            self.message = .property(.init(property: property))
        }
    }

    
    func enemyTrade() {
        let price = trade.myPlayerProperties.reduce(0) { partialResult, step in
            partialResult + (step.buyPrice ?? 0)
        } + Int(trade.tradeAmount * 100)
        let pricePlayer = trade.enemyProperties.reduce(0) { partialResult, step in
            partialResult + (step.buyPrice ?? 0)
        }
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
        if canUpdateCount >= colors.count {
            
        }
        trade.tradeResponse = canUpdateCount >= colors.count
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
        self.message = .custom(.init(title: "Robot \(trade.tradeResponse ?? false ? "Accepted" : "Declined") trade proposal", button: .init(title: "OK", pressed: {
            self.activePanelType = nil
        })))
    }
    
    func occupiedByPlayer(_ property:Step) -> PlayerStepModel? {
        playersArray.first(where: { player in
            player.bought[property] != nil
        })
    }
}


//MARK: completed mooving
fileprivate extension GameViewModel {
    
    private func enemyCompletedMooving(property:Step) {
        if property.buyPrice == nil {
            checkEnemyCanUpgradeProperties()
            return
        }
        if occupiedByPlayer(property) == nil {
            if enemyPosition.canBuy(property) {
                let request = coreMLModel.predictAction(.init(type: .buyAuction(.configure(property)), base: .configure(enemyPosition, playerPosition)))
                switch request {
                case .buyAuction(let results):
                    if results == .upgrade {
                        self.enemyPosition.buyIfCan(property)
                    } else {
                        self.bet.playerPalance = self.myPlayerPosition.balance
                        self.bet.betProperty = property
                    }
                default:
                    self.bet.playerPalance = self.myPlayerPosition.balance
                    self.bet.betProperty = property
                }
            } else {
                self.bet.playerPalance = self.myPlayerPosition.balance
                self.bet.betProperty = property
            }
        }
        
        checkEnemyCanUpgradeProperties()
    }
    
    private func payRent(property:Step) {
        if let occupiedBy = occupiedByPlayer(property) {
            if let upgrade = occupiedBy.bought[property],
               occupiedBy.id != playerPosition.id {
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
    
    func movingCompletedCheckChance(_ property:Step) {
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
    
    func movingCompletedCheckProperty(_ property:Step) {
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
    
    func enemyInJail() {
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
    func chestChanceDidSet() {
        guard let type = chestPresenting ?? chancePresenting else {
            return
        }
        switch type.action {
        case .propertySelection(let propertySelectionAction):
            if !playersArray.flatMap({$0.bought}).filter({$0.value.index >= 1}).isEmpty {
                selectingProperty = propertySelectionAction
            } else {
                selectingProperty = nil
                if chestPresenting != nil {
                    chestPresenting = nil
                }
                
                if chancePresenting != nil {
                    chancePresenting = nil
                }
            }
        default:break
        }
    }
    
    func chestChanceOkPressed(_ action:BoardCard.Action?) {
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
    
    func chestOkPressedGoTo(_ step:Step) {
        if step == .jail1 {
            playerPosition.inJail = true
            playerPosition.playerPosition = .jail1
            return
        }
        let destinationIndex:Int
        if step.color == nil {
            let number = "\(step.rawValue.number ?? 0)"
            let rawValue = step.rawValue.replacingOccurrences(of: number, with: "")
//            let steps = Step.allCases[playerPosition.playerPosition.index...Step.allCases.count]
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
            //                playerPosition.balance += balanceIncrement.amount
        }
        playerPosition.balance += (balanceIncrement.amount * i)
    }
    
    
    func chanceOkPressed() {
        let holder = chancePresenting
        chancePresenting = nil
        chestChanceOkPressed(holder?.action)
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

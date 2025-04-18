//
//  GameViewModel.swift
//  MonopolyGame
//
//  Created by Mykhailo Dovhyi on 08.04.2025.
//

import SwiftUI

class GameViewModel:ObservableObject {
    @Published var diceDestination:Int = 0
    @Published var myPlayerPosition:PlayerStepModel = .init(playerPosition: .go)
    @Published var enemyPosition:PlayerStepModel = .init(playerPosition: .go)
    @Published var message:PopupView.PopupType?
    @Published var messagePressed:ButtonData? = nil
    @Published var messagePressedSecondary:ButtonData? = nil
    var viewAppeared = false
    var dbUpdated = false
    @Published var bet:BetModel = .init(betValue: 0)
    
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

//    var itemWidth:CGFloat {
//        deviceWidth / Step.numberOfItemsInSection
//    }
    
    @Published var activePanelType:PanelType?
    enum PanelType:String, CaseIterable {
        case build, sell, morgage, redeem, trade
        var description: String {
            "Select properties to \(rawValue)"
        }
    }
    
    func saveProgress(db:inout AppData.DataBase) {
        db.gameProgress.player = myPlayerPosition
        db.gameProgress.enemy = enemyPosition
    }
    
    func fetchGame(db: AppData.DataBase) {
        if db.gameProgress.player.playerPosition == .go && db.gameProgress.enemy.playerPosition == .go {
            self.myPlayerPosition.balance = db.settings.game.balance
            self.enemyPosition.balance = db.settings.game.balance
        } else {
            self.myPlayerPosition = db.gameProgress.player
            self.enemyPosition = db.gameProgress.enemy
        }
        
    }
    
    func propertySelected(_ step: Step) {
        if activePanelType != nil {
            boardActionPropertySelected(step)
        } else {
            //presentMessage
            let owner = playersArray.first(where: {
                $0.bought.first { (key: Step, value: PlayerStepModel.Upgrade) in
                    key == step
                } != nil
            })
            self.message = .property(.init(owner: owner?.id == myPlayerPosition.id ? "You" : "Robot", ownerUpgrade: owner?.bought[step], property: step))
        }
    }
    
    func propertyTapDisabled(_ step: Step) -> Bool {
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
                
                print(price, " pricepriceprice ")
                self.myPlayerPosition.balance += price
                self.myPlayerPosition.bought.updateValue(newValue, forKey: step)
            }
            
        case .morgage:
            if let upgrade = self.myPlayerPosition.bought[step],
               let price = step.morgage,
               !self.myPlayerPosition.morgageProperties.contains(step)
            {
                
                print(price, " pricepriceprice ")
                self.myPlayerPosition.balance += price
                self.myPlayerPosition.morgageProperties.append(step)
            }
        case .redeem:
            if let upgrade = self.myPlayerPosition.bought[step],
               upgrade == .bought,
               self.myPlayerPosition.morgageProperties.contains(step),
               let price = step.rentTotal(upgrade)
            {
                
                print(price, " pricepriceprice ")
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
    var canDice:Bool {
        return moveCompleted && bet.betProperty == nil && activePanelType == nil && !trade.isPresenting && !updateBalancePresenting
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
    func prepareMoving() {
//        if playerPosition.balance < 0 {

//        } else {
            let array = playersArray
            currentPlayerIndex += 1
            if currentPlayerIndex > array.count - 1 {
                currentPlayerIndex = 0
            }
            print("preparepleyer:", playerPosition.id == self.myPlayerPosition.id)

            diceDestination = (2..<12).randomElement() ?? 0
//        }
        
        
    }
    
    func enemySellAll(minMorgage:Int = 0) {
        print("enemySellAllenemySellAll")
        if enemyPosition.balance >= 0 && minMorgage == 0 {
//            prepareMoving()
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
            print(bet.bet.last?.0.id == myPlayerPosition.id, " rgtefsd ", bet.bet.last?.0)
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
            if (self.bet.betProperty?.buyPrice ?? 0) >= (last?.1 ?? 0) {
                if self.enemyPosition.balance >= ((last?.1 ?? 0) + 1) {
                    self.bet.bet.append((self.enemyPosition, (last?.1 ?? 0) + 1))

                } else {
                    self.setBetWone()
                }
            } else {
                self.setBetWone()
            }
        })
    }
    
    func playerCompletedMoving() {
        self.moveCompleted = true
        let property = playerPosition.playerPosition
        if let occupiedBy = playersArray.first(where: { player in
            player.bought[property] != nil
        }) {
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
        if playerPosition.id == myPlayerPosition.id {
            if property.buyPrice != nil && myPlayerPosition.bought[property] == nil {
                if self.myPlayerPosition.canBuy(property) {
                    self.messagePressed = .init(title: "Buy", pressed: {
                        self.myPlayerPosition.buyIfCan(property)
                    })
                }
                self.messagePressedSecondary = .init(title: "auction", pressed: {
                    self.bet.playerPalance = self.myPlayerPosition.balance
                    self.bet.betProperty = property
                })
                self.message = .property(.init(property: property))
            }
            
        } else {
            if property.buyPrice == nil {
                print("notbuible")
                checkEnemyCanUpgradeProperties()

                return
            }
            if enemyPosition.canBuy(property) {
                self.enemyPosition.buyIfCan(property)

            } else {
                self.bet.playerPalance = self.myPlayerPosition.balance
                self.bet.betProperty = property
            }
            checkEnemyCanUpgradeProperties()
        }

    }
    
    func checkPlayersBalance() {
        if myPlayerPosition.id == self.playerPosition.id {
            if myPlayerPosition.balance <= 0 {
                updateBalancePresenting = true
            }
        } else {
//            if !enemyMorgagedBalance {
//                if enemyPosition.balance >= 260 {
//                    self.enemyPosition.morgageProperties.forEach { step in
//                        if let price = step.morgage {
//                            if (price + 100) <= self.enemyPosition.balance {
//                                self.enemyPosition.balance += price
//                                self.enemyPosition.morgageProperties.removeAll(where: {
//                                    $0 == step
//                                })
//                            }
//                        }
//                    }
//                }
//            }
            //check balance
            if enemyPosition.balance <= 250 && !enemyMorgagedBalance {
                enemyMorgagedBalance = true
                enemySellAll(minMorgage: 250)
            } else {
                enemyMorgagedBalance = false
            }
            if enemyPosition.balance <= 0 {
                print("checking enemy balance")
                self.enemySellAll()
            }
        }
    }
    
    private func checkEnemyCanUpgradeProperties() {
        let upgrades = enemyPosition.bought.filter {
            enemyPosition.canUpdateProperty($0.key)
        }.sorted(by: {$0.key.upgradePrice($0.value) >= $1.key.upgradePrice($1.value)})
        let ocupiedPropertiesCount = (self.enemyPosition.bought.compactMap({$0.key}) + self.myPlayerPosition.bought.compactMap({$0.key})).count
        let occupiedPercent = CGFloat(ocupiedPropertiesCount) / CGFloat(Step.allCases.count)
        let minEnemyRestBalaance = occupiedPercent >= 0.5 ? 250 : 100
        var bought = false
        upgrades.forEach { (key: Step, value: PlayerStepModel.Upgrade) in
            let balanceHolder = self.enemyPosition.balance
            if minEnemyRestBalaance < self.enemyPosition.balance {
                self.enemyPosition.upgradePropertyIfCan(key)
                if self.enemyPosition.balance < balanceHolder {
                    bought = true
                }
            }
        }
        print(bought, " enemyboughtProperties")
    }
    
    func resumeNextPlayer(forceMove:Bool = false) {
        self.prepareMoving()
        if self.myPlayerPosition.id != self.playerPosition.id || forceMove {
            self.move()

        }
    }
    
    func move() {
        moveCompleted = false
        withAnimation {
            playerPosition.playerPosition = Step.allCases.first(where: {
                (playerPosition.playerPosition.index + 1) == $0.index
            }) ?? .go
        }
        print(diceDestination, " newDestination ")
        print(playerPosition.playerPosition.index, " playerposition ")
        if playerPosition.playerPosition == .go {
            playerPosition.balance += 200
        }
        diceDestination -= 1
        if diceDestination >= 1 {
            print("movemovemove")
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500), execute: {
                self.move()
            })
        } else {
            print(playerPosition.playerPosition, " gvhvhgvg ")
            self.playerCompletedMoving()
            self.checkPlayersBalance()
        }
    }
    
    func enemyTrade() {
        let price = trade.myPlayerProperties.reduce(0) { partialResult, step in
            partialResult + (step.buyPrice ?? 0)
        } + Int(trade.tradeAmount * 100)
        let pricePlayer = trade.enemyProperties.reduce(0) { partialResult, step in
            partialResult + (step.buyPrice ?? 0)
        }
        print(price / pricePlayer, " erfwdsaz ")
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
        
//        if price >= pricePlayer {
//            let colors = myPlayerProperties.c
//        } else {
//            trade.tradeResponse = false
//        }
    }
    
}

extension GameViewModel {
    struct Trade {
        var myPlayerProperties:[Step] = []
        var enemyProperties:[Step] = []
        var tradeAmount:Float = 0
        var isPresenting:Bool = false {
            didSet {
                tradeAmount = 0
            }
        }
        var tradingByEnemy:Bool = false
        var okEnabled:Bool {
            (tradeAmount != 0 || !myPlayerProperties.isEmpty) && !enemyProperties.isEmpty
        }
        var tradeResponse:Bool? = nil
    }
    
    struct BetModel {
        var playerPalance:Int = 0
        var bet:[(PlayerStepModel, Int)] = [] {
            didSet {
                if (self.betValue * 100) <= Float(bet.last?.1 ?? 0) {
                    self.betValue = Float((bet.last?.1 ?? 0) + 1) / 100
                }
            }
        }
        var betProperty:Step? {
            didSet {
                betValue = 0.01
            }
        }
        var betValue:Float = 0 {
            didSet {
                if betValue < betSliderRange.lowerBound {
                    betValue = betSliderRange.lowerBound
                }
                if betValue > betSliderRange.upperBound {
                    betValue = betSliderRange.upperBound
                }
            }
        }
        
        var betSliderRange:ClosedRange<Float> {
            var from = (Float(bet.last?.1 ?? 1))
            if from > 0 {
                from += 1
            }
            let toValue:Int
            if betProperty?.buyPrice ?? 1 >= playerPalance {
                toValue = betProperty?.buyPrice ?? 1
            } else {
                toValue = playerPalance
            }
            var to = (Float(toValue))
            if from >= to {
                to = from + 1
            }
            return ((from / 100)...(to / 100))
    //        0...10
        }
    }
}

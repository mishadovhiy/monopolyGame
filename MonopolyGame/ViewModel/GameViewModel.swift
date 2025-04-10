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
    
    @Published var bet:[(PlayerStepModel, Int)] = [] {
        didSet {
            if (self.betValue * 100) <= Float(bet.last?.1 ?? 0) {
                self.betValue = Float((bet.last?.1 ?? 0) + 1) / 100
            }
        }
    }
    @Published var betProperty:Step? {
        didSet {
            betValue = 0.01
        }
    }
    @Published var betValue:Float = 0
    @Published var deviceWidth:CGFloat = 0
    var itemWidth:CGFloat = 60

//    var itemWidth:CGFloat {
//        deviceWidth / Step.numberOfItemsInSection
//    }
    
    @Published var boardActionType:BoardActionType?
    enum BoardActionType:String, CaseIterable {
        case build, sell, morgage, reedeem
    }
    
    func propertySelected(_ step: Step) {
        if boardActionType != nil {
            boardActionPropertySelected(step)
        } else {
            //presentMessage
            self.message = .property(step)
        }
    }
    
    func propertyTapDisabled(_ step: Step) -> Bool {
        guard let boardActionType else {
            return false
        }
        switch boardActionType {
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
        case .reedeem:
            return !self.myPlayerPosition.morgageProperties.contains(step)
        case .sell:
            if let upgrade = self.myPlayerPosition.bought[step] {
                return upgrade == .bought || upgrade.previousValue == nil
            }
            return true
        }
    }
    
    func boardActionPropertySelected(_ step: Step) {
        switch boardActionType {
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
        case .reedeem:
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
        return moveCompleted && betProperty == nil && boardActionType == nil
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
    
    func prepareMoving() {
        let array = playersArray
        currentPlayerIndex += 1
        if currentPlayerIndex > array.count - 1 {
            currentPlayerIndex = 0
        }
        print("preparepleyer:", playerPosition.id == self.myPlayerPosition.id)

        diceDestination = (2..<12).randomElement() ?? 0
        
    }
    
    func setBetWone() {
        if let property = betProperty {
            print(bet.last?.0.id == myPlayerPosition.id, " rgtefsd ", bet.last?.0)
            if bet.last?.0.id == myPlayerPosition.id {
                myPlayerPosition.buyIfCan(property, price: bet.last?.1 ?? 1)
            } else {
                enemyPosition.buyIfCan(property, price: bet.last?.1 ?? 1)
            }
            bet.removeAll()
            betValue = 0
            betProperty = nil
        }
    }
    
    func robotBet() {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds((250..<3000).randomElement() ?? 0), execute: {
            let last = self.bet.last
            if (self.betProperty?.buyPrice ?? 0) >= (last?.1 ?? 0) {
                if self.enemyPosition.balance >= ((last?.1 ?? 0) + 1) {
                    self.bet.append((self.enemyPosition, (last?.1 ?? 0) + 1))

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
            if property.buyPrice == nil {
                return
            }
            if myPlayerPosition.bought[property] == nil {
                if self.myPlayerPosition.canBuy(property) {
                    self.messagePressed = .init(title: "Buy", pressed: {
                        self.myPlayerPosition.buyIfCan(property)
                    })
                }
                self.messagePressedSecondary = .init(title: "auction", pressed: {
                    self.betProperty = property
                })
                self.message = .property(property)
            }
            
        } else {
            if property.buyPrice == nil {
                print("notbuible")
                return
            }
            if enemyPosition.canBuy(property) {
                self.enemyPosition.buyIfCan(property)

            } else {
                self.betProperty = property
            }
        }

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
        }
    }
    
    var betSliderRange:ClosedRange<Float> {
        var from = (Float(bet.last?.1 ?? 1))
        if from > 0 {
            from += 1
        }
        var to = (Float(betProperty?.buyPrice ?? 1) * 5)
        if from >= to {
            to = from + 1
        }
        return ((from / 100)...(to / 100))
//        0...10
    }
}

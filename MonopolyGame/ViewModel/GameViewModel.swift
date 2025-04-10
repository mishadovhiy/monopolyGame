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
    
    @Published var bet:[(PlayerStepModel, Int)] = []
    @Published var betProperty:Step?
    @Published var betValue:Float = 0

    var currentPlayerIndex:Int = 0
    var canDice:Bool {
        if playerPosition.id == myPlayerPosition.id {
            return moveCompleted
        } else {
            return false
        }
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
                myPlayerPosition.buyIfCan(property, price: bet.last?.1)
            } else {
                enemyPosition.buyIfCan(property, price: bet.last?.1)
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
        let property = myPlayerPosition.playerPosition
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
            let property = enemyPosition.playerPosition
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
        var to = (Float(betProperty?.buyPrice ?? 1))
        if from >= to {
            to = from + 1
        }
        return ((from / 100)...(to / 100))
//        0...10
    }
}

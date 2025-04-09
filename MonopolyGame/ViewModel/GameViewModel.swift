//
//  GameViewModel.swift
//  MonopolyGame
//
//  Created by Mykhailo Dovhyi on 08.04.2025.
//

import Foundation

class GameViewModel:ObservableObject {
    @Published var diceDestination:Int = 0
    @Published var myPlayerPosition:PlayerStepModel = .init(playerPosition: .go)
    @Published var enemyPosition:PlayerStepModel = .init(playerPosition: .go)
    @Published var message:PopupView.PopupType?
    @Published var messagePressed:ButtonData? = nil
    @Published var messagePressedSecondary:ButtonData? = nil
    @Published var bet:[(PlayerStepModel, Int)] = []
    var betProperty:Step?
    @Published var betValue:Float = 0
    var currentPlayerIndex:Int = 0

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
    
    func startMove() {
        let array = playersArray
        currentPlayerIndex += 1
        if currentPlayerIndex > array.count - 1 {
            currentPlayerIndex = 0
        }
        diceDestination = (2..<12).randomElement() ?? 0
        
    }
    
    func setBetWone() {
        print(bet.last?.0.id == myPlayerPosition.id, " rgtefsd ", bet.last?.0)
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
}

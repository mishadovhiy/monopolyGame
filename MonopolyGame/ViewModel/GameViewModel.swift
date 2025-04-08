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
    
    var playerPosition:PlayerStepModel {
        get {
            return playersArray[currentPlayerIndex]

        }
        set {
            playersArray[currentPlayerIndex] = newValue

        }
    }
    var currentPlayerIndex:Int = 0
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
}

//
//  DataBase.swift
//  MonopolyGame
//
//  Created by Mykhailo Dovhyi on 03.04.2025.
//

import Foundation

class AppData:ObservableObject {
    private let dbkey = "db4"
    @Published var deviceSize:CGSize = .zero
    @Published var db:DataBase = .init() {
        didSet {
            print("updatingDB")
            print(db.player.playerPosition, " rgefsda ")
            if dataLoaded {
                if Thread.isMainThread {
                    DispatchQueue(label: "db", qos: .userInitiated).async {
                        UserDefaults.standard.set(self.db.decode ?? .init(), forKey: self.dbkey)
                    }
                } else {
                    UserDefaults.standard.set(self.db.decode ?? .init(), forKey: dbkey)
                }
            } else {
                dataLoaded = true
            }
        }
    }
    
    init() {
        self.fetch()
    }
    
    private var dataLoaded = false
    
    func fetch() {
        if Thread.isMainThread {
            DispatchQueue(label: "db", qos: .userInitiated).async {
                self.performFetchDB()
            }
        }
        else {
            self.performFetchDB()
            
        }
    }
    
    private func performFetchDB() {
        let db = UserDefaults.standard.data(forKey: dbkey)
        DispatchQueue.main.async {
            self.dataLoaded = false
            self.db = .configure(db) ?? .init()
        }
    }

    struct DataBase:Codable {
        var player:PlayerStepModel = .init(playerPosition: .go)
        var enemy: PlayerStepModel = .init(playerPosition: .go)
    }
}

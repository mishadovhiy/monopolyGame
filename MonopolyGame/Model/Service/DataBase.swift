//
//  DataBase.swift
//  MonopolyGame
//
//  Created by Mykhailo Dovhyi on 03.04.2025.
//

import Foundation

class AppData:ObservableObject {
    let gameCenter:GameCenterModel
    var audioManager:AudioPlayerManagers?
    private let dbkey = "db6"
    @Published var deviceSize:CGSize = .zero
    @Published var db:DataBase = .init() {
        didSet {
            print("updatingDB")
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
        self.gameCenter = .init()
        self.fetch()

        self.gameCenter.configureGameCenterPlayer()
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
            if self.audioManager == nil {
                self.audioManager = .init(db: self.db)
                self.audioManager?.play(.background1)
            }
        }
    }

    struct DataBase:Codable {
        var gameProgress:GameProgress = .init()
        var settings:Settings = .init()
        var profile:Profile = .init()
        var gameCompletions:GameCompletions = .init()
        
        struct Settings:Codable {
            var sound:Sound = .init()
            var game:Game = .init()
            struct Game: Codable {
                var difficulty:Float = 0.5
                var balance:Int = 1000
            }
            struct Sound:Codable {
                var music:Float = 0.2
                var menuClick:Float = 0.3
                var sound: Float = 0.3
                var dict:[String:Float] {
                    get {
                        Dictionary(uniqueKeysWithValues: dictionary?.map({ (key: String, value: Any) in
                            (key, Float(value as? Double ?? 0))
                        }) ?? [])
                    }
                    set {
                        newValue.forEach { (key: String, value: Float) in
                            if let key:CodingKeys = .init(rawValue: key) {
                                switch key {
                                case .music:
                                    self.music = value
                                case .menuClick:
                                    self.menuClick = value
                                case .sound:
                                    self.sound = value

                                }
                            }
                        }

                    }
                }
                enum CodingKeys:String, CodingKey, CaseIterable {
                    case music
                    case menuClick
                    case sound
                    
                    var description:String {
                        switch self {
                        case .music:
                            "Background music"
                        case .menuClick:
                            "Navigation, button clicks"
                        case .sound:
                            "Game sound such as, player moves"
                        }
                    }
                }
            }
        }
        
        struct Profile:Codable {
            var imageURL:String = ""
            var username:String = ""
        }
        
        struct GameCompletions: Codable {
            var completionList:[Completion] = []
//            [
//                .init(balance: 130, upgrades: [
//                    .blue1:.higherMiddle,
//                    .chance1:.largest
//                ]),
//                .init(balance: 400, upgrades: [
//                    .blue1:.higherMiddle,
//                    .chance1:.largest
//                ]),
//                .init(balance: 500, upgrades: [
//                    .blue1:.higherMiddle,
//                    .chance1:.largest
//                ]),
//                .init(balance: 200, upgrades: [
//                    .blue1:.higherMiddle,
//                    .chance1:.largest
//                ])
//            ]
            struct Completion: Codable {
                var balance:Int = 0
                var time:Date = .init()
                var upgrades:PlayerStepModel.BoughtUpgrades = .init()
            }
        }
        
        struct GameProgress:Codable {
            private var _player:PlayerStepModel = .init(playerPosition: .go)
            private var _enemy: PlayerStepModel = .init(playerPosition: .go)
            var player:PlayerStepModel {
                get {
//                    var value = PlayerStepModel.init(playerPosition: .blue1)
//                    value.bought = [
//                        .green1:.largest,
//                        .green2:.largest,
//                        .green3:.largest,
//                        .pink1:.largest,
//                        .pink2:.largest,
//                        .pink3:.largest,
//                        .brawn1:.largest,
//                        .brawn2:.largest,
//                        .orange1:.largest,
//                        .orange2:.largest,
//                        .orange3:.largest,
//                        .purpure1:.largest,
//                        .purpure2:.largest,
//                        .yellow1:.largest,
//                        .yellow2:.largest,
//                        .yellow3:.largest,
//                        .red1:.largest,
//                        .red2:.largest,
//                        .red3:.largest
//                    ]
//                    value.balance = 2000
//                                        var value = PlayerStepModel.init(playerPosition: .blue1)
//                    value.balance = 50
//                    return value
                    _player
                }
                set {
                    _player = newValue
                }
            }
            var enemy: PlayerStepModel {
                get {
//                    var value = PlayerStepModel.init(playerPosition: .blue1)
//                    value.bought = [
//                        .blue1:.smallest,
//                        .blue2:.bought,
//                        .blue3:.smallest
//                    ]
//                    value.balance = -200
//                    return value
                    return _enemy
                }
                set {
                    _enemy = newValue
                }
            }
        }
    }
}

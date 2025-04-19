//
//  AudioPlayerManager.swift
//  MonopolyGame
//
//  Created by Mykhailo Dovhyi on 19.04.2025.
//

import AVFoundation

struct AudioPlayerManagers {
    fileprivate var audioPlayers:[AudioPlayerManager] = []
    init(db:AppData.DataBase) {
        audioPlayers = AudioType.allCases.compactMap({
            .init(type: $0, db: db)
        })
    }
    
    func play(_ name:AudioType) {
//        var name = name
//        if name.isBackground {
//            name = AudioType.allCases.filter({$0.isBackground}).randomElement() ?? name
//        }
        if let audio = audioPlayers.first(where: {$0.audioType == name}) {
            audio.play()
        } else {
            print("audio type \(name.rawValue) wasn't initiated, initiate audio before playing sound")
        }
    }
    
    func stop(_ name:AudioType? = nil) {
        audioPlayers.forEach {
            if let name, !name.isBackground {
                if name == $0.audioType {
                    $0.stop()
                }
            } else {
                $0.stop()
            }
        }
    }
}

class AudioPlayerManager:NSObject, AVAudioPlayerDelegate {
    
    var player: AVAudioPlayer?

    deinit {
        player?.stop()
        player = nil
    }
    
    init(type:AudioType = .default, db:AppData.DataBase) {
        super.init()
        self.audioType = type
        if let soundUrl = Bundle.main.url(forResource: type.rawValue, withExtension: type.format) {
            do {
                player = try? AVAudioPlayer(contentsOf: soundUrl)
                if type.isBackground {
                    player?.numberOfLoops = -1
                }
                player?.delegate = self
                player?.prepareToPlay()
                if type.isBackground {
                    try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
                    try? AVAudioSession.sharedInstance().setActive(true)
                }
                setDBVolume(db) {

                }
                
            }
        } else {
            print(type, " fatalerroraudionotfound")
        }
    }
    
    func play() {
        print(audioType?.rawValue, " playingg")
        self.player?.play()
    }
    
    func stop() {
        self.player?.stop()
    }
    
    var audioType:AudioType?
    
    func setDBVolume(_ db:AppData.DataBase,
                     completion:@escaping()->() = {}) {
        let action = {
            let sound = self.audioType?.volume(db)
            DispatchQueue.main.async {
                self.player?.volume = sound ?? 0.5
                completion()
            }
        }
        if Thread.isMainThread {
            DispatchQueue(label: "db", qos: .userInitiated).async {
                action()
            }
        } else {
            action()
        }
    }
}

enum AudioType: String, CaseIterable {
    case background
    case background1, background2, background3, background4, background5
    case click, click2, click3, click4
    case collect, loose, motorShort
    case shoot, hit
    
    static var wone:AudioType = .click2
    static var `default`:AudioType = .click2
    static var enemyShoot:AudioType = .shoot
    static var playerShoot:AudioType = .shoot
    static var enemyHitted:AudioType = .hit
    static var playerHitted:AudioType = .hit

    static var randomBackground:AudioType {
        allCases.filter({$0.isBackground}).randomElement() ?? .background
    }
    
    var format:String {
        let m4a:[AudioType] = [.hit, .shoot]
        if m4a.contains(self) {
            return "m4a"
        }
        return "mp3"
    }
    func volume(_ db:AppData.DataBase) -> Float {
        if isBackground {
            return db.settings.sound.music
        } else {
            return db.settings.sound.sound
        }
    }
    var isBackground:Bool {rawValue.uppercased().contains("background".uppercased())}
}

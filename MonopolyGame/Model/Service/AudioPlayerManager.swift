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
        var name = name
        if name.isBackground {
            name = AudioType.allCases.filter({$0.isBackground}).randomElement() ?? name
        }
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
    
    func dbVolumeChanged(_ db:AppData.DataBase) {
        audioPlayers.forEach { manager in
            manager.setDBVolume(db) {
                
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
        self.setAudioFile(type: type, db: db)
    }
    
    func play() {
        print(audioType?.rawValue, " playingg")
        self.player?.play()
    }
    
    func stop() {
        self.player?.stop()
    }
    
    var audioType:AudioType?
    private var volume:Float = 0
    private func setAudioFile(type:AudioType = .default, db:AppData.DataBase?) {
        self.audioType = type
        if let soundUrl = Bundle.main.url(forResource: type.rawValue, withExtension: type.format) {
            do {
                player = try? AVAudioPlayer(contentsOf: soundUrl)
//                if type.isBackground {
//                    player?.numberOfLoops = -1
//                }
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
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag && (audioType?.isBackground ?? false) {
            print("changingaudiofile")
            self.player?.stop()
            self.player = nil
            self.setAudioFile(type: .randomBackground, db: nil)
            self.play()
        }
    }
    
    func setDBVolume(_ db:AppData.DataBase?,
                     completion:@escaping()->() = {}) {
        let action = {
            
            let sound = db == nil ? self.volume : self.audioType?.volume(db!)
            self.volume = sound ?? 0.5
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
    case background1, background2, background3, background4, background5
    case money, loose, menu, wone
    case menuRegular, menuPlay
    static var `default`:AudioType { .menu}
    static var randomBackground:AudioType {
        allCases.filter({$0.isBackground}).randomElement() ?? .background1
    }
    
    var format:String {
        let m4a:[AudioType] = [.money, .menuPlay, .menuRegular]
        let wav:[AudioType] = [.loose, .menu, .wone]
        if m4a.contains(self) {
            return "m4a"
        }
        if wav.contains(self) {
            return "wav"
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

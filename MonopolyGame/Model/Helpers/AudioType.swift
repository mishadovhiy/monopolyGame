//
//  AudioType.swift
//  MonopolyGame
//
//  Created by Mykhailo Dovhyi on 18.09.2025.
//

import UIKit

enum AudioType: String, CaseIterable {
    case background1, background2, background3, background4, background5
    case money, loose, menu, wone
    case menuRegular, menuPlay
    
    var needHaptic: UIImpactFeedbackGenerator.FeedbackStyle? {
        switch self {
        case .menu, .menuRegular: .light
        case .menuPlay, .loose, .wone: .heavy
            
        default: nil
        }
    }
    
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

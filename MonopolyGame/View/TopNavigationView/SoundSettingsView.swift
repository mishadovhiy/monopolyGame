//
//  SoundSettingsView.swift
//  MonopolyGame
//
//  Created by Mykhailo Dovhyi on 13.04.2025.
//

import SwiftUI

struct SoundSettingsView: View {
    @Binding var viewModel: HomeViewModel
    @EnvironmentObject var db: AppData
    var body: some View {
        VStack {
            ForEach(AppData.DataBase.Settings.Sound.CodingKeys.allCases, id:\.rawValue) { key in
                VStack {
                    Text(key.rawValue)
                    Text(key.description)
                    Slider(value: .init(get: {
                        db.db.settings.sound.dict[key.rawValue] ?? 0.5
                    }, set: { newValue in
                        db.db.settings.sound.dict.updateValue(newValue, forKey: key.rawValue)
                    }))
                }
            }
        }
        .navigationBarHidden(true)
        .background {
            ClearBackgroundView()
        }
    }
}


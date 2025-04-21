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
        VStack(content: {
            Spacer().frame(height: 10)
            ScrollView(.vertical, content: {
                VStack {
                    VStack(spacing:10, content: {
                        ForEach(AppData.DataBase.Settings.Sound.CodingKeys.allCases, id:\.rawValue) { key in
                            VStack(alignment:.leading) {
                                Text(key.rawValue.capitalized)
                                    .font(.system(size: 18, weight:.semibold))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Text(key.description.capitalized)
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondaryText)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Slider(value: .init(get: {
                                    db.db.settings.sound.dict[key.rawValue] ?? 0.5
                                }, set: { newValue in
                                    db.db.settings.sound.dict.updateValue(newValue, forKey: key.rawValue)
                                }))
                                Divider()
                            }
                            .frame(maxWidth:.infinity, alignment: .leading)
                        }
                    })
                    .padding(10)
                    .background(.primaryBackground)
                    .cornerRadius(8)
                    .padding(.horizontal, 5)
                    Spacer()
                }
            })
        })
        
        .background {
            ClearBackgroundView()
        }
        .background(.secondaryBackground)

    }
}


//
//  PropertyView.swift
//  MonopolyGame
//
//  Created by Mykhailo Dovhyi on 09.04.2025.
//

import SwiftUI

struct PropertyView: View {
    let step:Step
    var canScroll:Bool = true
    var body: some View {
        if canScroll {
            ScrollView(.vertical) {
                contentView
            }
        } else {
            contentView
        }
    }
    
    var contentView: some View {
        VStack {
            Text(step.title)
                .frame(maxWidth: .infinity)
            VStack {
                HStack {
                    Text("Rent: ")
                    Text("\(step.rent ?? 0) / (price:\(step.buyPrice ?? 0))")
                }
                Text("Rent is doubled on owning all unimproved sites in the group.")
                HStack {
                    Text("Morgage:")
                    Text("$ \(step.morgage ?? 0)")
                }
                VStack {
                    ForEach(PlayerStepModel.Upgrade.allCases, id:\.rawValue) { upgrade in
                        HStack {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(.red)
                                .aspectRatio(1, contentMode: .fit)
                                .overlay {
                                    Text("\(upgrade.index)")
                                }
                            Spacer()
                            Text("\(step.upgradePrice(upgrade))")
                                .font(.system(size: 9))
                        }
                        .frame(height:20)
                    }
                }
                
            }
        }
        .padding(3)
        .background(step.color?.color ?? .gray)
    }
}

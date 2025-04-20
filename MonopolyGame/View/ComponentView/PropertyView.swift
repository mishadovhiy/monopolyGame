//
//  PropertyView.swift
//  MonopolyGame
//
//  Created by Mykhailo Dovhyi on 09.04.2025.
//

import SwiftUI

struct PropertyView: View {
    let step:Step
    var higlightUpgrade:PlayerStepModel.Upgrade?
    var canScroll:Bool = true
    var needPrice = true

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
            Text(step.attributedTitle(.medium))
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity)
                .background(step.color?.color ?? .gray)
                .cornerRadius(4)
            VStack {
                HStack {
                    Text("Morgage:")
                        .foregroundColor(.secondaryText)
                        .font(.system(size: 12))

                    Text("$ \(step.morgage ?? 0)")
                        .foregroundColor(.light)
                        .font(.system(size: 12, weight: .semibold))

                }
                Spacer().frame(height: 10)
                Text("Rent is doubled on owning all unimproved sites in the group.")
                    .foregroundColor(.secondaryText)
                    .font(.system(size: 9))
                Spacer().frame(height: 10)

                VStack {
                    HStack {
                        Spacer()
                        Text("upgrade")
                            .foregroundColor(.secondaryText)
                            .font(.system(size: 9))
                        Text("rent")
                            .foregroundColor(.secondaryText)
                            .font(.system(size: 9))
                    }
                    ForEach(PlayerStepModel.Upgrade.allCases, id:\.rawValue) { upgrade in
                        HStack {
                            Image("upgrades/\(upgrade.index)")
                                .resizable()
                                .scaledToFit()
                                .frame(width:30)
                            Spacer()
                            Text("\(step.upgradePrice(upgrade))")
                                .foregroundColor(higlightUpgrade == upgrade ? .black : .light)

                                .font(.system(size: 9))
                            Text("\(step.rentTotal(upgrade) ?? 0)")
                                .foregroundColor(higlightUpgrade == upgrade ? .black : .light)

                                .font(.system(size: 9))
                        }
                        .frame(height:20)
                        .padding(.vertical, higlightUpgrade == upgrade ? 2 : 0)
                        .padding(.horizontal, higlightUpgrade == upgrade ? 5 : 0)
                        .background {
                            if higlightUpgrade == upgrade {
                                Color(.green)
                                    .cornerRadius(4)
                            }
                        }
                        Divider()
                    }
                }
                
            }
            .padding(5)
        }
        .background(content: {
            RoundedRectangle(cornerRadius: 8)
                .stroke(step.color?.color ?? .lightsecondaryBackground, lineWidth: 1)
                
        })
        .padding(3)
        
//        .background(step.color?.color ?? .gray)
    }
}

//
//  BuyPropertyView.swift
//  MonopolyGame
//
//  Created by Mykhailo Dovhyi on 08.04.2025.
//

import SwiftUI

struct BuyPopupContentView: View {
    var step: Step
    var owner:String? = nil
    var body: some View {
        VStack {
            Spacer()
                .frame(minHeight: 50)
            VStack {
                Text("Price:")
                    .font(.system(size: 12))

                    .foregroundColor(.secondaryText)
                Spacer().frame(height:5)
                Text("\(step.buyPrice ?? 0)")
                    .font(.system(size: 24, weight: .semibold))

                    .foregroundColor(.light)
                if let owner {
                    Spacer()
                        .frame(minHeight: 60)
                    HStack {
                        Spacer()
                        Text("Owner:")
                            .font(.system(size: 12))
                            .foregroundColor(.secondaryText)
                        Text(owner)
                            .font(.system(size: 12, weight:.semibold))

                            .foregroundColor(.light)
                    }
                }
            }
            Spacer()
        }
        .frame(maxHeight: .infinity)
    }
}


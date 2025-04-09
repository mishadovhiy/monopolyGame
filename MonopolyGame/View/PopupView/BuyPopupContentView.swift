//
//  BuyPropertyView.swift
//  MonopolyGame
//
//  Created by Mykhailo Dovhyi on 08.04.2025.
//

import SwiftUI

struct BuyPopupContentView: View {
    var step: Step
    var body: some View {
        VStack {
            Spacer()
            VStack {
                Text("Price:")
                    .foregroundColor(.black)
                Text("\(step.buyPrice ?? 0)")
                    .foregroundColor(.black)
                
            }
            Spacer()
        }
    }
}


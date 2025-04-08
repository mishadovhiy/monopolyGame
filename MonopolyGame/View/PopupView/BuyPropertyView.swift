//
//  BuyPropertyView.swift
//  MonopolyGame
//
//  Created by Mykhailo Dovhyi on 08.04.2025.
//

import SwiftUI

struct BuyPropertyView: View {
    var step: Step
    var body: some View {
        HStack {
            Text("Price:")
                .foregroundColor(.black)
            Text("\(step.buyPrice ?? 0)")
                .foregroundColor(.black)
        }
    }
}


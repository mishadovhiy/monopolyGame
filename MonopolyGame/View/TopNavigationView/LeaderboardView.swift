//
//  LeaderboardView.swift
//  MonopolyGame
//
//  Created by Mykhailo Dovhyi on 13.04.2025.
//

import SwiftUI

struct LeaderboardView: View {
    @Binding var viewModel:HomeViewModel
    @EnvironmentObject var db: AppData
    var body: some View {
        VStack(content: {
            self.itemView(nil)
            ScrollView(.vertical, content: {
                VStack {
                    ForEach(db.db.gameCompletions.completionList.sorted(by: {
                        ($0.balance + $0.upgrades.totalPrice.price) >= ($1.balance + $1.upgrades.totalPrice.price)
                    }), id:\.time) { item in
                        self.itemView(item)
                    }
                }
            })
            HStack {
                Button {
                    viewModel.gameCenterPressed()
                } label: {
                    Text("Game center")
                }
                .background(.green)
            }
        })
        .navigationBarHidden(true)
        .background {
            ClearBackgroundView()
        }
    }
    
    func itemView(_ item:AppData.DataBase.GameCompletions.Completion?) -> some View {
        let total = item?.upgrades.totalPrice
        return HStack {
            Text(item?.time.formatted(Date.FormatStyle()
                .year(.defaultDigits)
                .month(.abbreviated)
                .day(.twoDigits)) ?? "When")
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
            HStack {
                Text(item?.balance == nil ? "Balance" : "$\(item?.balance ?? 0)")
                    .multilineTextAlignment(.leading)
                    .offset(x:-20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(total == nil ? "Properies" : "\(total?.propertyCount ?? 0)($\(total?.price ?? 0))")
                    .multilineTextAlignment(.trailing)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

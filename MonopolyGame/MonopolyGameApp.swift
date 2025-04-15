//
//  MonopolyGameApp.swift
//  MonopolyGame
//
//  Created by Mykhailo Dovhyi on 03.04.2025.
//

import SwiftUI

@main
struct MonopolyGameApp: App {
    @StateObject var db:AppData = .init()
    @State var viewLoaded:Bool = false
    var body: some Scene {
        WindowGroup {
//            VStack {
//                if !viewLoaded {
//                    Text("...")
//                } else {
//                    HomeView()
//                }
//            }
            GameView()
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                    self.viewLoaded = true
                })
            }
            .environmentObject(db)


//            PropertyListView(list: Step.allCases.filter({$0.buyPrice != nil}))

        }
    }
}

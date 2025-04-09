//
//  PropertyListView.swift
//  MonopolyGame
//
//  Created by Mykhailo Dovhyi on 09.04.2025.
//

import SwiftUI

struct PropertyListView: View {
    let list:[Step]
    var body: some View {
        ScrollView(.vertical) {
            ForEach(list, id:\.rawValue) { step in
                PropertyView(step: step, canScroll: false)
            }
        }
    }
}


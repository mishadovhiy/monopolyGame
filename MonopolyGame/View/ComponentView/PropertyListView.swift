//
//  PropertyListView.swift
//  MonopolyGame
//
//  Created by Mykhailo Dovhyi on 09.04.2025.
//

import SwiftUI

struct PropertyListView: View {
    var list:[Step]
    @Binding var selectedProperties:[Step]
    var body: some View {
        ScrollView(.vertical) {
            VStack {
                if list.isEmpty {
                    VStack {
                        Spacer().frame(height: 150)
                        Text("Property list is empty")
                            .font(.system(size: 18, weight:.semibold))
                            .foregroundColor(.secondaryText)
                    }
                    .frame(maxWidth: .infinity)
                }
                ForEach(list, id:\.rawValue) { step in
                    PropertyView(step: step, canScroll: false)
                        .onTapGesture {
                            if !selectedProperties.contains(step) {
                                selectedProperties.append(step)
                            } else {
                                selectedProperties.removeAll(where: {
                                    $0 == step
                                })
                            }
                        }
                        .overlay {
                            if selectedProperties.contains(step) {
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(.red, lineWidth: 2)
                            }
                        }
                }
            }
        }
        .onChange(of: list.count) { newValue in
            print(newValue, " rgtefrdeas ")
        }
    }
}


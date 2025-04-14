//
//  BlurView.swift
//  MonopolyGame
//
//  Created by Mykhailo Dovhyi on 14.04.2025.
//

import UIKit
import SwiftUI

struct BlurView: UIViewRepresentable {
    var style: UIBlurEffect.Style = .init(rawValue: -1000)!
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        let effect = UIBlurEffect(style: style)
        let view = UIVisualEffectView(effect: effect)
        view.isUserInteractionEnabled = false
        let vibracity = UIVisualEffectView(effect: effect)
        view.contentView.addSubview(vibracity)
        return view
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
    }
}

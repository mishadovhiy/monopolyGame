//
//  ImageView.swift
//  MonopolyGame
//
//  Created by Mykhailo Dovhyi on 13.04.2025.
//

import SwiftUI
import UIKit

struct ImageView:UIViewRepresentable {
    func makeUIView(context: Context) -> some UIView {
        let view = UIView()
        let imageView = UIImageView(image: .grass)
        view.addSubview(imageView)
        view.layer.masksToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.leadingAnchor.constraint(equalTo: imageView.superview!.leadingAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: imageView.superview!.trailingAnchor).isActive = true
        imageView.topAnchor.constraint(equalTo: imageView.superview!.topAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: imageView.superview!.bottomAnchor).isActive = true

        return view
    }
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
}

//
//  ButtonData.swift
//  MonopolyGame
//
//  Created by Mykhailo Dovhyi on 08.04.2025.
//

import CoreGraphics

struct ButtonData {
    let title:String
    var backgroundColor:ColorResource? = .lightsecondaryBackground
    var pressed:(()->())?
}

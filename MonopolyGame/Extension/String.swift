//
//  String.swift
//  MonopolyGame
//
//  Created by Mykhailo Dovhyi on 03.04.2025.
//

import Foundation

extension String {
    var number:Int? {
        if let match = self.range(of: "\\d+", options: .regularExpression) {
            let numberString = String(self[match])
            return Int(numberString)
        }
        return nil
    }
}

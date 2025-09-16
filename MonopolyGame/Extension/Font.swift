//
//  Font.swift
//  MonopolyGame
//
//  Created by Mykhailo Dovhyi on 17.09.2025.
//

import SwiftUI

extension Font {
    static func custom(_ size: CGFloat, weight: WeightType = .regular) -> Self {
        return custom("ComicRelief-\(weight.rawValue.capitalized)", size: size)
    }
    
    public static func system(size: CGFloat, weight: Font.Weight = .regular, design: Font.Design = .default) -> Self {
        custom(size, weight: .init(systemWeight: weight))
    }
    
    enum WeightType: String {
        case bold, regular
        
        init(systemWeight: Font.Weight) {
            switch systemWeight {
            case .black, .semibold, .heavy, .bold: self = .bold
            default: self = .regular
            }
        }
    }
}

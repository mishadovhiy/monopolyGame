//
//  UIImage.swift
//  MonopolyGame
//
//  Created by Mykhailo Dovhyi on 14.04.2025.
//

import UIKit

extension UIImage {
    func changeSize(newWidth:CGFloat, from:CGSize? = nil, origin:CGPoint = .zero) -> UIImage {
#if os(iOS)
        let widthPercent = newWidth / (from?.width ?? self.size.width)
        let proportionalSize: CGSize = .init(width: newWidth, height: widthPercent * (from?.height ?? self.size.height))
        let renderer = UIGraphicsImageRenderer(size: proportionalSize)
        let newImage = renderer.image { _ in
            self.draw(in: CGRect(origin: origin, size: proportionalSize))
        }
        return newImage
#else
        return self
#endif
        
    }
}

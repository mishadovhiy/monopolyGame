//
//  CloseIconPath.swift
//  MonopolyGame
//
//  Created by Mykhailo Dovhyi on 17.09.2025.
//

import SwiftUI

struct CloseIconPath: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height
        path.move(to: CGPoint(x: 0.66667*width, y: 0.66667*height))
        path.addLine(to: CGPoint(x: 0.5*width, y: 0.5*height))
        path.move(to: CGPoint(x: 0.5*width, y: 0.5*height))
        path.addLine(to: CGPoint(x: 0.33333*width, y: 0.33333*height))
        path.move(to: CGPoint(x: 0.5*width, y: 0.5*height))
        path.addLine(to: CGPoint(x: 0.66667*width, y: 0.33333*height))
        path.move(to: CGPoint(x: 0.5*width, y: 0.5*height))
        path.addLine(to: CGPoint(x: 0.33333*width, y: 0.66667*height))
        return path
    }
}

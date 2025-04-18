//
//  MessageContent.swift
//  MonopolyGame
//
//  Created by Mykhailo Dovhyi on 08.04.2025.
//

import Foundation
import UIKit

struct MessageContent {
    let title:String
    var description:String = ""
    var image:ImageResource? = nil
    var button:ButtonData? = nil
    var id:UUID = .init()
    var boldDescription:String = ""
    
    func sttributedDescription(fontSize:CGFloat) -> AttributedString {
        /**
         .init(data.description, attributes: .init([
             .font:UIFont.systemFont(ofSize: 19, weight: .semibold)
         ]))
         */
        var text:AttributedString = .init(boldDescription, attributes: .init([
                        .font:UIFont.systemFont(ofSize: fontSize, weight: .bold)
                    ]))
//        text.append(.init(string: description, attributes: [
//            .font:UIFont.systemFont(ofSize: fontSize, weight: .regular)
//
//        ]))
        text.append(AttributedString(description, attributes: .init([
            .font:UIFont.systemFont(ofSize: fontSize, weight: .regular)
        ])))
        return text
    }
}

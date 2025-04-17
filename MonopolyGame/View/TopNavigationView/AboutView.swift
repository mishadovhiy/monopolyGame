//
//  AboutView.swift
//  MonopolyGame
//
//  Created by Mykhailo Dovhyi on 13.04.2025.
//

import SwiftUI

struct AboutView: View {
    var body: some View {
        VStack(alignment:.leading, content: {
            Text("About Monopoly")
                .multilineTextAlignment(.leading)
                .font(.system(size: 24, weight: .black))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
            ScrollView(.vertical, showsIndicators: false, content: {
                VStack( alignment:.leading, spacing:0) {
                    
                    ForEach(data, id:\.id) { data in
                        Spacer().frame(height: data.boldDescription.isEmpty ? 10 : 2)
                        section(data)
                    }
                }
                .frame(alignment: .leading)
                .padding(.bottom, 10)
                
            })
        })
        .background {
            ClearBackgroundView()
        }
        .background(.secondaryBackground)

    }
    
    func section(_ data:MessageContent) -> some View {
        VStack(alignment:.leading) {
            if !data.title.isEmpty {
                Text(data.title)
                    .multilineTextAlignment(.leading)
                    .font(.system(size: 17, weight: .black))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            
            if !data.description.isEmpty {
                Text(data.sttributedDescription(fontSize: 12))
                    .multilineTextAlignment(.leading)
                    .font(.system(size: 14))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    let data:[MessageContent] = [
        .init(title: "Introduction", description: """
                    Monopoly is a classic board game that has been enjoyed by players around the world for over a century. The game combines strategy, negotiation, and luck, as players try to dominate the real estate market by buying, trading, and developing properties. The goal is to bankrupt your opponents by managing your money wisely and making the right investments.
                    """),
        .init(title: "Objective of the Game", description: """
            The objective of Monopoly is to become the wealthiest player through property acquisition, development, and strategic trading, while eliminating other players through bankruptcy. The game continues until one player remains financially intact, having outlasted all the other players.
            """),
        .init(title: "How to Play", description: ""),
        .init(title: "", description: """
        Place the board on a flat surface and distribute the starting money to each player. 
        """, boldDescription: "1. Set Up:"),
        .init(title: "", description: """
        Players take turns rolling two six-sided dice. The number rolled determines how many spaces to move on the board.
        """, boldDescription: "2. Roll the Dice:"),
        .init(title: "", description: """
        When you land on an unowned property, you can buy it for the listed price. If you decide not to buy it, the property is auctioned to other players.
        """, boldDescription: "3. Buying Properties:"),
        .init(title: "", description: """
        Once you own all the properties in a color set, you can begin building houses and hotels to increase the rent that other players must pay when landing on those properties.
        """, boldDescription: "4. Building Houses and Hotels:"),
        .init(title: "", description: """
        The game includes special spaces such as Chance and Community Chest, where players can receive rewards or penalties.
        """, boldDescription: "5. Special Spaces:"),
        .init(title: "Key Features", description: ""),
        .init(title: "", description: """
        One of the most exciting aspects of Monopoly is the ability to trade properties with other players. Strategic negotiations can help you acquire the properties you need to complete color sets and build houses and hotels.
        """, boldDescription: "- Trading and Negotiation: "),
        .init(title: "", description: """
        The more you develop your properties, the higher the rent you can charge other players. Owning a complete color set allows you to build houses and eventually hotels to maximize your income.
        """, boldDescription: "- Rent and Income: "),
        .init(title: "", description: """
        These cards add an element of surprise and unpredictability, giving you opportunities for both rewards and challenges that can change the course of the game.
        """, boldDescription: "- Chance and Community Chest: "),

        .init(title: "Tips for Winning"),
        .init(title: "", description: "Owning a complete color set and developing it into houses and hotels gives you the best chance of winning. Prioritize property acquisition and development.", boldDescription: "- Focus on Property Development: "),
        .init(title: "", description: "Don’t overspend early in the game. Keep enough cash on hand to pay rent and avoid bankruptcy.", boldDescription: "- Manage Your Cash: "),
        .init(title: "", description: "Trading with other players can be the key to completing your color sets and strengthening your position. Be strategic in your trades.", boldDescription: "- Negotiation Is Key: "),
        .init(title: "Fun Facts"),
        .init(title: "", description: " Monopoly was created in 1903 by Elizabeth Magie as a way to teach about the dangers of monopolies. The game evolved over time, eventually becoming the classic we know today.", boldDescription: " - Origins: "),
        .init(title: "", description: """
        Monopoly has been translated into over 40 languages, with localized editions that feature cities and landmarks from all around the world.
        """, boldDescription: "- Global Versions: "),
        .init(title: "", description: "The longest game of Monopoly ever played lasted for 70 straight days!", boldDescription: "- Record: "),
        .init(title: "Conclusion", description: """
            Monopoly is a game of strategy, luck, and negotiation. Whether you’re a seasoned player or new to the game, there’s always a new strategy to try and a new way to outsmart your opponents. Gather your friends, roll the dice, and see if you can build your empire in the world of Monopoly!
            """)
    ]
}

#Preview {
    AboutView()
}

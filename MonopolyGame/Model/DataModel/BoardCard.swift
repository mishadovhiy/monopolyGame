//
//  CardActionData.swift
//  MonopolyGame
//
//  Created by Mykhailo Dovhyi on 20.04.2025.
//

import Foundation

/// data model for Chance and Chest board cards
struct BoardCard: Codable {
    let title:String
    var text:String = ""
    var action:Action
    var canPressOk: Bool = true
    
    enum PlayerSpecialCard:Codable {
        case outOfJail
        case looseMove
    }
        
    var canClose:Bool {
        if canPressOk {
            return ![
                action.properySelection != nil
            ].contains(true)
        } else {
            return false
        }
        
    }
}


extension BoardCard {
    enum Action: Codable {
        case goTo(Step)
        case moveIncrement(Int)
        case specialCard(PlayerSpecialCard)
        case balanceIncrement(BalanceIncrement)
        case propertySelection(PropertySelectionAction)
        
        var goTo:Step? {
            switch self {
            case .goTo(let property):property
            default:nil
            }
        }
        var moveIncrement:Int? {
            switch self {
            case .moveIncrement(let i): i
            default:nil
            }
        }
        var specialCard:PlayerSpecialCard? {
            switch self {
            case .specialCard(let card):card
            default:nil
            }
        }
        var balanceIncrement:BalanceIncrement? {
            switch self {
            case .balanceIncrement(let value):value
            default:nil
            }
        }
        var properySelection:PropertySelectionAction? {
            switch self {
            case .propertySelection(let value):value
            default:nil
            }
        }
        
        struct BalanceIncrement: Codable {
            var from:BalanceFrom? = nil
            enum BalanceFrom: Codable {
                //oposite balance would be Incremented to other players
                case otherPlayers
                case houses
            }
            var amount:Int
        }
            
        enum PropertySelectionAction: Codable {
            case decrementUpgrade
            case firstRent50PercentDecrees
            var performOnMoved:Bool {
                switch self {
                case .firstRent50PercentDecrees:
                    true
                default:false
                }
            }
        }
    }

}


extension [BoardCard] {
    static var chance:Self {
        [
            .init(title: "Advance to Go", text: "Move directly to GO and collect $200.", action: .goTo(.go)),
            .init(title: "Go to Jail", text: "Go directly to Jail. Do not pass Go, do not collect $200.", action: .goTo(.go)),
            .init(title: "Advance to the nearest Railroad", text: "Move to the nearest Railroad and pay the owner rent.", action: .goTo(.transportGrey1)),
            .init(title: "Bank pays you a dividend of $50", text: "Collect $50 from the bank.", action: .balanceIncrement(.init(amount: 50))),
            .init(title: "Pay poor tax of $15", text: "Pay $15 to the bank.", action: .balanceIncrement(.init(amount: -15))),
            .init(title: "Take a trip to Reading Railroad", text: "Move directly to Reading Railroad and pay rent if owned by another player.", action: .goTo(.transportGrey1)),
            .init(title: "You have been elected Chairman of the Board", text: "Pay each player $50.", action: .balanceIncrement(.init(from: .otherPlayers, amount: -50))),
            .init(title: "Advance to Illinois Avenue", text: "Move directly to Illinois Avenue and pay rent if owned by another player.", action: .goTo(.green2)),
            .init(title: "Speeding fine: Pay $15", text: "Pay a $15 speeding fine.", action: .balanceIncrement(.init(amount: -15))),
            .init(title: "Collect $100 from each player", text: "Each player must pay you $100.", action: .balanceIncrement(.init(from: .otherPlayers, amount: 100))),
            .init(title: "Get out of Jail Free", text: "This card can be used to get out of Jail without paying the $50 fine.", action: .specialCard(.outOfJail)),
            .init(title: "Advance to the nearest Utility", text: "Move to the nearest Utility and pay rent.", action: .goTo(.tax2)),
            .init(title: "Move forward 3 spaces", text: "Advance 3 spaces forward.", action: .moveIncrement(3)),
            .init(title: "Move backward 2 spaces", text: "Move backward 2 spaces.", action: .moveIncrement(-2)),
            .init(title: "Take a loan from the bank", text: "Take a $500 loan from the bank", action: .balanceIncrement(.init(amount: 500))),
            .init(title: "You have a MonoFusion in Railroad properties", text: "Collect an additional $100 from each player.", action: .balanceIncrement(.init(from: .otherPlayers, amount: 100))),
            .init(title: "Collect $200 from the bank", text: "Collect $200 from the bank.", action: .balanceIncrement(.init(amount: 200))),
            .init(title: "Collect rent from a player of your choice", text: "Choose a player and collect rent on one of their properties.", action: .propertySelection(.firstRent50PercentDecrees)),
            .init(title: "Advance to Boardwalk", text: "Move directly to Boardwalk and pay rent if owned by another player.", action: .goTo(.transportGrey2)),
            .init(title: "Pay $50 for school fees", text: "Pay $50 to the bank for school fees.", action: .balanceIncrement(.init(amount: -50))),
            .init(title: "Sale of stock: Collect $150", text: "Collect $150 from the bank due to successful stock investments.", action: .balanceIncrement(.init(amount: 150))),
            .init(title: "Property tax refund: Collect $75", text: "Collect $75 from the bank as a property tax refund.", action: .balanceIncrement(.init(amount: 75))),
            .init(title: "Advance to St. Charles Place", text: "Move directly to St. Charles Place and pay rent if owned by another player.", action: .goTo(.blue1)),
            .init(title: "Bank error in your favor: Collect $200", text: "Collect $200 from the bank due to a clerical error.", action: .balanceIncrement(.init(amount: 200))),
            .init(title: "Pay a $100 insurance premium", text: "Pay a $100 premium for insurance.", action: .balanceIncrement(.init(amount: -100))),
            .init(title: "Swap one property with another player", text: "Swap one of your properties with another player.", action: .propertySelection(.decrementUpgrade)),
            .init(title: "Pay $25 for traffic violation", text: "Pay $25 for a traffic violation.", action: .balanceIncrement(.init(amount: -25))),
            .init(title: "Your business gets a boost: Collect $150", text: "Collect $150 due to a boost in your business.", action: .balanceIncrement(.init(amount: 150))),
            .init(title: "Advance to the nearest Green property", text: "Move to the nearest Green property and pay rent.", action: .goTo(.green1)),
            .init(title: "Lose a turn due to illness", text: "Miss your next turn due to illness.", action: .specialCard(.looseMove))
//            .init(title: "You have won a crossword competition.", text: "Collect $100.", action: .balanceIncrement(.init(amount: 100))),
//            .init(title: "Pay hospital fees of $100.", action: .balanceIncrement(.init(amount: -100))),
//            .init(title: "You inherit $100.", action: .balanceIncrement(.init(amount: 100)))
        ]
    }
    
    static var chest: Self {
        [
            .init(title: "You have won a crossword competition.", text: "Collect $100.", action: .balanceIncrement(.init(amount: 100))),
            .init(title: "Pay hospital fees of $100.", action: .balanceIncrement(.init(amount: -100))),
            .init(title: "You inherit $100.", action: .balanceIncrement(.init(amount: 100))),
            .init(title: "Advance to Go.", text: "Collect $200.", action: .goTo(.go)),
            .init(title: "You have been elected Chairman of the Board.", text: "Pay each player $50.", action: .balanceIncrement(.init(from: .otherPlayers, amount: -50))),
            .init(title: "Collect $20 for your birthday.", action: .balanceIncrement(.init(from: .otherPlayers, amount: 20))),
            .init(title: "Collect $20 for your birthday.", action: .balanceIncrement(.init(from: .otherPlayers, amount: 20))),
            .init(title: "Bank error in your favor.", text: "Collect $200.", action: .balanceIncrement(.init(amount: 200))),
            .init(title: "Pay a $50 fine for not following the rules.", action: .balanceIncrement(.init(amount: -50))),
            .init(title: "Go directly to Jail.", action: .goTo(.jail1)),
            .init(title: "You won a prize in a lottery.", text: "Collect $500.", action: .balanceIncrement(.init(amount: 500))),
            .init(title: "Pay $25 for each house you own.", action: .balanceIncrement(.init(from: .houses, amount: -25))),
            .init(title: "Receive a rebate from your insurance. Collect $50.", action: .balanceIncrement(.init(amount: 50))),
            .init(title: "You are audited.", text: "Pay $200 in taxes.", action: .balanceIncrement(.init(amount: 200))),
            .init(title: "Your stock investment has paid off.", text: "Collect $150.", action: .balanceIncrement(.init(amount: 150))),
            .init(title: "Advance to St. Charles Place.", action: .goTo(.yellow3)),
            .init(title: "Collect $150 as a Christmas bonus.", action: .balanceIncrement(.init(amount: 150))),
            .init(title: "Pay school fees of $50.", action: .balanceIncrement(.init(amount: -50))),
            .init(title: "Speeding fine! Pay $15.", action: .balanceIncrement(.init(amount: -15))),
            .init(title: "Take a trip to the nearest tax service company.", action: .goTo(.tax1)),
            .init(title: "Collect $100 for your successful business venture.", action: .balanceIncrement(.init(amount: 100))),
            .init(title: "Your property was sold at auction.", text:"Collect $200.", action: .balanceIncrement(.init(amount: 200))),
            .init(title: "Get out of Jail free.", text: "This card may be kept until needed or traded.", action: .specialCard(.outOfJail)),
            .init(title: "Loan has been repaid.", text: "Collect $100.", action: .balanceIncrement(.init(amount: 100))),
            .init(title: "Pay $50 to repair your car.", action: .balanceIncrement(.init(amount: -50))),
            .init(title: "You receive a tax refund.", text: "Collect $150.", action: .balanceIncrement(.init(amount: 150))),
            .init(title: "Pay $100 in legal fees.", action: .balanceIncrement(.init(amount: -100))),
            .init(title: "You’ve been awarded a grant.", text: "Collect $250.", action: .balanceIncrement(.init(amount: 250))),
            .init(title: "You’ve won a cooking contest.", text: "Collect $50.", action: .balanceIncrement(.init(amount: 50))),
            .init(title: "Advance to the nearest Train station.", text: "Pay rent if owned.", action: .goTo(.transportGrey1)),
            .init(title: "You have been given an inheritance. Collect $200.", action: .balanceIncrement(.init(amount: 200)))
        ]
    }
#warning("if title.contains(nearest) - go to nearest color")

}
//if color == nil ? find nearest

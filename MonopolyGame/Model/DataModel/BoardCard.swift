//
//  CardActionData.swift
//  MonopolyGame
//
//  Created by Mykhailo Dovhyi on 20.04.2025.
//

import Foundation

/// data model for Chance and Chest board cards
struct BoardCard {
    let title:String
    var text:String = ""
    var action:Action
    
    enum PlayerSpecialCard:Codable {
        case outOfJail
        case looseMove
    }
        
    var canClose:Bool {
        ![
            action.properySelection != nil
        ].contains(true)
    }
}


extension BoardCard {
    enum Action {
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
        
        struct BalanceIncrement {
            var from:BalanceFrom? = nil
            enum BalanceFrom {
                //oposite balance would be Incremented to other players
                case otherPlayers
                case houses
            }
            var amount:Int
        }
            
        enum PropertySelectionAction {
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
            .init(title: "Go directly to Jail.", action: .goTo(.jail1))
//            .init(title: "You have won a crossword competition.", text: "Collect $100.", action: .balanceIncrement(.init(amount: 100))),
//            .init(title: "Pay hospital fees of $100.", action: .balanceIncrement(.init(amount: -100))),
//            .init(title: "You inherit $100.", action: .balanceIncrement(.init(amount: 100)))
        ]
    }
    
    static var chest: Self {
        [
            .init(title: "Go directly to Jail.", action: .goTo(.jail1))
//            .init(title: "You have won a crossword competition.", text: "Collect $100.", action: .balanceIncrement(.init(amount: 100))),
//            .init(title: "Pay hospital fees of $100.", action: .balanceIncrement(.init(amount: -100))),
//            .init(title: "You inherit $100.", action: .balanceIncrement(.init(amount: 100))),
//            .init(title: "Advance to Go.", text: "Collect $200.", action: .goTo(.go)),
//            .init(title: "You have been elected Chairman of the Board.", text: "Pay each player $50.", action: .balanceIncrement(.init(from: .otherPlayers, amount: -50))),
//            .init(title: "Collect $20 for your birthday.", action: .balanceIncrement(.init(from: .otherPlayers, amount: 20))),
//            .init(title: "Collect $20 for your birthday.", action: .balanceIncrement(.init(from: .otherPlayers, amount: 20))),
//            .init(title: "Bank error in your favor.", text: "Collect $200.", action: .balanceIncrement(.init(amount: 200))),
//            .init(title: "Pay a $50 fine for not following the rules.", action: .balanceIncrement(.init(amount: -50))),
//            .init(title: "Go directly to Jail.", action: .goTo(.jail1)),
//            .init(title: "You won a prize in a lottery.", text: "Collect $500.", action: .balanceIncrement(.init(amount: 500))),
//            .init(title: "Pay $25 for each house you own.", action: .balanceIncrement(.init(from: .houses, amount: -25))),
//            .init(title: "Receive a rebate from your insurance. Collect $50.", action: .balanceIncrement(.init(amount: 50))),
//            .init(title: "You are audited.", text: "Pay $200 in taxes.", action: .balanceIncrement(.init(amount: 200))),
//            .init(title: "Your stock investment has paid off.", text: "Collect $150.", action: .balanceIncrement(.init(amount: 150))),
//            .init(title: "Advance to St. Charles Place.", action: .goTo(.yellow3)),
//            .init(title: "Collect $150 as a Christmas bonus.", action: .balanceIncrement(.init(amount: 150))),
//            .init(title: "Pay school fees of $50.", action: .balanceIncrement(.init(amount: -50))),
//            .init(title: "Speeding fine! Pay $15.", action: .balanceIncrement(.init(amount: -15))),
//            .init(title: "Take a trip to the nearest tax service company.", action: .goTo(.tax1)),
//            .init(title: "Collect $100 for your successful business venture.", action: .balanceIncrement(.init(amount: 100))),
//            .init(title: "Your property was sold at auction.", text:"Collect $200.", action: .balanceIncrement(.init(amount: 200))),
//            .init(title: "Get out of Jail free.", text: "This card may be kept until needed or traded.", action: .specialCard(.outOfJail)),
//            .init(title: "Loan has been repaid.", text: "Collect $100.", action: .balanceIncrement(.init(amount: 100))),
//            .init(title: "Pay $50 to repair your car.", action: .balanceIncrement(.init(amount: -50))),
//            .init(title: "You receive a tax refund.", text: "Collect $150.", action: .balanceIncrement(.init(amount: 150))),
//            .init(title: "Pay $100 in legal fees.", action: .balanceIncrement(.init(amount: -100))),
//            .init(title: "You’ve been awarded a grant.", text: "Collect $250.", action: .balanceIncrement(.init(amount: 250))),
//            .init(title: "You’ve won a cooking contest.", text: "Collect $50.", action: .balanceIncrement(.init(amount: 50))),
//            .init(title: "Advance to the nearest Train station.", text: "Pay rent if owned.", action: .goTo(.transportGrey1)),
//            .init(title: "You have been given an inheritance. Collect $200.", action: .balanceIncrement(.init(amount: 200)))
        ]
    }
#warning("if title.contains(nearest) - go to nearest color")

}
//if color == nil ? find nearest

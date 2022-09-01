//
//  SetGameModel.swift
//  Set
//
//  Created by 涂庭鋆 on 2022/9/1.
//

import Foundation

struct SetGame{
    
    private(set) var cards: Array<card>
    
    init(){
        cards = []
        for color in card.color.allCases{
            for shape in card.shape.allCases{
                for shading in card.shading.allCases{
                    for number in card.number.allCases{
                        cards.append(card(color: color, shape: shape, shading: shading, number: number))
                    }
                }
            }
        }
        cards.shuffle()
    }
    
    mutating func choose(_ card: card){
        if let chosenIndex =  cards.firstIndex(where: { $0.id == card.id }){
            cards[chosenIndex].state = .isSelected
        }
    }
    
    struct card: Identifiable{
        var id: UUID
        var state: card_state
        var content: [String: Any]
        
        init(color: color, shape: shape, shading: shading, number: number){
            self.id = UUID()
            self.state = .default
            self.content = ["color": color, "shape": shape, "shading": shading, "number": number]
        }
        
        enum card_state{
            case isSelected, isInSet, isNotInSet, `default`
        }
        
        enum color: CaseIterable{
            case orange, green, red
        }
        enum shape: CaseIterable{
            case diamond, squiggle, oval
        }
        enum shading: CaseIterable{
            case solid, striped, open
        }
        enum number: CaseIterable{
            case one, two, three
        }
        
    }
}

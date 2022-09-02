//
//  SetGameModel.swift
//  Set
//
//  Created by 涂庭鋆 on 2022/9/1.
//

import Foundation

struct SetGame{
    private(set) var deck: Array<card>
    private(set) var displayedCards: Array<card>
    
    private var selectedCard: Array<card>
    
    init(){
        selectedCard = []
        deck = []
        for color in card.color.allCases{
            for shape in card.shape.allCases{
                for shading in card.shading.allCases{
                    for number in card.number.allCases{
                        deck.append(card(color: color, shape: shape, shading: shading, number: number))
                    }
                }
            }
        }
        deck.shuffle()
        displayedCards = Array(deck[0..<12])
        deck = deck.filter({ !displayedCards.containCard($0.id) })
    }
    
    mutating func choose(_ card: card){
        // TODO: test multiple click
        if let chosenIndex = displayedCards.firstIndex(where: { $0.id == card.id }){
            displayedCards[chosenIndex].state = .isSelected
            selectedCard.append(displayedCards[chosenIndex])
            if selectedCard.count == 3{
                setCardSetState(isSet: isSet(cards: selectedCard), selectedCard: selectedCard)
                selectedCard = []
            }
        }
    }
    
    private func isSet(cards: Array<card>) -> Bool{
        let categories = ["color","shape", "shading", "number"]
        for cat in categories{
            var catList = [cards.first?.content[cat]!]
            cards.forEach{ card in
                if !catList.contains(card.content[cat]!){
                    catList.append(card.content[cat]!)
                }
            }
            // has only two same category and one different
            if catList.count == 2{
                return false
            }
        }
        return true
    }
    
    private mutating func setCardSetState(isSet: Bool, selectedCard: Array<card>){
        var indexList: Array<Int> = []
        selectedCard.forEach{ card in
            indexList.append(displayedCards.firstIndex(where: { $0.id == card.id })!)
        }
        if isSet{
            indexList.forEach{ index in
                displayedCards[index].state = .isInSet
            }
        } else {
            indexList.forEach{ index in
                displayedCards[index].state = .isNotInSet
            }
        }
    }
    
    struct card: Identifiable{
        var id: UUID
        var state: card_state
        var content: [String: String]
        
        init(color: color, shape: shape, shading: shading, number: number){
            self.id = UUID()
            self.state = .default
            self.content = ["color": color.rawValue, "shape": shape.rawValue, "shading": shading.rawValue, "number": number.rawValue]
        }
        
        enum card_state{
            case isSelected, isInSet, isNotInSet, `default`
        }
        
        enum color: String, CaseIterable{
            case orange, green, red
        }
        enum shape: String, CaseIterable{
            case diamond, squiggle, oval
        }
        enum shading: String, CaseIterable{
            case solid, striped, open
        }
        enum number: String, CaseIterable{
            case one, two, three
        }
        
    }
}

extension Array where Element == SetGame.card{
    func containCard(_ id: UUID) -> Bool{
        for ele in self{
            if ele.id == id {
                return true
            }
        }
        return false
    }
}

//
//  SetGameModel.swift
//  Set
//
//  Created by 涂庭鋆 on 2022/9/1.
//

import Foundation

struct SetGame{
    private typealias cardState = SetGame.card.cardState
    
    private var deck: Array<card>
    private(set) var displayedCards: Array<card>
    
    private var selectedCard: Array<card>{
        return displayedCards.filter({ $0.state == .isSelected })
    }
    private var inSetCard: Array<card>{
        return displayedCards.filter({ $0.state == .isInSet })
    }
    private var notSetCard: Array<card>{
        return displayedCards.filter({ $0.state == .isNotInSet })
    }
    var deckCount: Int{
        return deck.count
    }
    
    init(){
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
        if let chosenIndex = displayedCards.firstIndex(where: { $0.id == card.id }){
            // If here are already 3 matching Set cards
            if inSetCard.count == 3 {
                removeInSetCards(card: card, index: chosenIndex)
                return
            }
            
            // If there are already 3 non-matching Set cards
            if notSetCard.count == 3{
                setCardSetState(selectedCard: notSetCard, state: .default)
                displayedCards[chosenIndex].state = .isSelected
                return
            }
            
            
            if (selectedCard.count == 1 || selectedCard.count == 2) &&
                (card.state == .isSelected) {
                // Deselect a card
                displayedCards[chosenIndex].state = .default
            } else if card.state == .default {
                // Select a card
                displayedCards[chosenIndex].state = .isSelected
                if selectedCard.count == 3{
                    // Change Card status
                    let state = isSet(cards: selectedCard) ? cardState.isInSet : cardState.isNotInSet
                    setCardSetState(selectedCard: selectedCard, state: state)
                }
            }
        }
    }
    
    mutating func getThreeCards(){
        if inSetCard.count == 3 {
            removeInSetCards()
        } else {
            displayedCards += Array(deck[0..<3])
            deck = deck.filter({ !displayedCards.containCard($0.id) })
        }
    }
    
    private mutating func removeInSetCards(card: card? = nil, index: Int? = nil){
        if let saveCard = card, let saveIndex = index{
            if !inSetCard.containCard(saveCard.id){
                displayedCards[saveIndex].state = .isSelected
            }
        }
        
        if deckCount != 0{
            inSetCard.forEach{ card in
                if let index = displayedCards.firstIndex(where: {$0.id == card.id}){
                    displayedCards[index] = deck.removeFirst()
                }
            }
        } else {
            displayedCards = displayedCards.filter({ !inSetCard.containCard($0.id) })
        }
    }
    
    private func isSet(cards: Array<card>) -> Bool{
        let categories = ["color","shape", "shading", "number"]
        for cat in categories{
            var catList: Array<String> = []
            cards.forEach{ card in
                if !catList.contains(card.content[cat]!){
                    catList.append(card.content[cat]!)
                }
            }
            // has only two same category and one different therefore not conform to the rules
            if catList.count == 2{
                return false
            }
        }
        return true
    }
    
    private mutating func setCardSetState(selectedCard: Array<card>, state: cardState){
        var indexList: Array<Int> = []
        
        selectedCard.forEach{ card in
            indexList.append(displayedCards.firstIndex(where: { $0.id == card.id })!)
        }

        indexList.forEach{
            displayedCards[$0].state = state
        }

    }
    
    struct card: Identifiable{
        var id: UUID
        var state: cardState
        var content: [String: String]
        
        init(color: color, shape: shape, shading: shading, number: number){
            self.id = UUID()
            self.state = .default
            self.content = ["color": color.rawValue, "shape": shape.rawValue, "shading": shading.rawValue, "number": number.rawValue]
        }
        
        enum cardState{
            case isSelected, isInSet, isNotInSet, `default`
        }
        
        enum color: String, CaseIterable{
            case purple, green, red
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

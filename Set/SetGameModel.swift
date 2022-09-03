//
//  SetGameModel.swift
//  Set
//
//  Created by 涂庭鋆 on 2022/9/1.
//

import Foundation

struct SetGame{
    private typealias cardState = SetGame.card.cardState
    
    private(set) var displayedCards: Array<card>
    private var deck: Array<card>
    private var timeOfFirstSelection: Date
    private var hintSetIndex: Array<Int>
    
    private var selectedCard: Array<card>{
        return displayedCards.filter({ $0.state == .isSelected })
    }
    private var inSetCard: Array<card>{
        return displayedCards.filter({ $0.state == .isInSet })
    }
    private var notSetCard: Array<card>{
        return displayedCards.filter({ $0.state == .isNotInSet })
    }
    private var hintCard: Array<card>{
        return displayedCards.filter({ $0.state == .hint })
    }
    private var ignoreCardsForHint: Array<card>{
        let index = hintCard.count / 3
        return Array(hintCard[0..<index*3]) + inSetCard
    }
    var deckCount: Int{
        return deck.count
    }
    var hasHint: Bool{
        if hintSetIndex.count == 0{
            return false
        }
        return true
    }
    
    init(){
        deck = []
        hintSetIndex = []
        timeOfFirstSelection = Date()
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
        getHintIndex(hasSetCards: hasSet(displayedCard: displayedCards))
    }
    
    mutating func choose(_ card: card, by player: Player.singlePlayer, _ playerObj: inout Player, isMultiplayer: Bool){
        if !player.isSelecting{
            return
        }
        if let chosenIndex = displayedCards.firstIndex(where: { $0.id == card.id }){
            // If here are already 3 matching Set cards
            if inSetCard.count == 3 {
                if isMultiplayer{
                    removeInSetCards()
                    playerObj.changeIsSelecting(player: player)
                } else {
                    removeInSetCards(card: card, index: chosenIndex)
                }
                getHintIndex(hasSetCards: hasSet(displayedCard: displayedCards))
                return
            }
            
            // If there are already 3 non-matching Set cards
            if notSetCard.count == 3{
                setCardSetState(selectedCard: notSetCard, state: .default)
                if !isMultiplayer{
                    displayedCards[chosenIndex].state = .isSelected
                } else {
                    playerObj.changeIsSelecting(player: player)
                }
                return
            }
            
            
            if (selectedCard.count == 1 || selectedCard.count == 2) &&
                (card.state == .isSelected) {
                // Deselect a card
                displayedCards[chosenIndex].state = .default
                getHintIndex(hasSetCards: hasSet(displayedCard: displayedCards, selectedCards: selectedCard))
            } else{
                // Select a card
                displayedCards[chosenIndex].state = .isSelected
                if selectedCard.count == 1{
                    timeOfFirstSelection = Date()
                }
                getHintIndex(hasSetCards: hasSet(displayedCard: displayedCards, selectedCards: selectedCard))
                if selectedCard.count == 3{
                    // Change Card status
                    let state = isSet(cards: selectedCard) ? cardState.isInSet : cardState.isNotInSet
                    let secondsInterval = Int(Date().timeIntervalSince(timeOfFirstSelection))
                    setCardSetState(selectedCard: selectedCard, state: state)
                    if state == .isInSet{
                        playerObj.addScore(player: player, score: 3 * max(5 - secondsInterval, 1))
                    } else {
                        playerObj.addScore(player: player, score: -1 * max(min(secondsInterval, 5), 1))
                    }
                }
            }
        }
    }
    
    mutating func hint(from player:Player.singlePlayer, _ playerObj: inout Player){
        if !player.isSelecting{
            return
        }
        playerObj.addScore(player: player, score: -2)
        hintSetIndex = hintSetIndex.filter({displayedCards[$0].state != .hint})
        if selectedCard.count == 0{
            displayedCards[hintSetIndex.removeFirst()].state = .hint
        } else {
            hintSetIndex = hintSetIndex.filter({displayedCards[$0].state != .isSelected})
            displayedCards[hintSetIndex.removeFirst()].state = .hint
        }
        
        if hintSetIndex == []{
            getHintIndex(hasSetCards: hasSet(displayedCard: displayedCards))
        }
        
    }
    
    mutating func getThreeCards(from player:Player.singlePlayer, _ playerObj: inout Player){
        if inSetCard.count == 3 {
            removeInSetCards()
        } else {
            displayedCards += Array(deck[0..<3])
            deck = deck.filter({ !displayedCards.containCard($0.id) })
        }
        getHintIndex(hasSetCards: hasSet(displayedCard: displayedCards))
        if hasHint{
            playerObj.addScore(player: player, score: -3)
        }
    }
    
    private mutating func getHintIndex(hasSetCards: Array<card>?){
        hintSetIndex = []
        if let canInSetCards = hasSetCards{
            canInSetCards.forEach{ card in
                hintSetIndex.append(displayedCards.firstIndex(where: { $0.id == card.id })!)
            }
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
    
    private func hasSet(displayedCard: Array<card>, selectedCards: Array<card>? = nil) -> Array<card>?{
        let defaultCards = displayedCards.filter({ !ignoreCardsForHint.containCard($0.id) })
        let saveSelectedCards = selectedCards ?? []
        
        if saveSelectedCards.count == 1{
            for j in 0..<defaultCards.count{
                for k in 0..<defaultCards.count{
                    if isSet(cards: [saveSelectedCards[0], defaultCards[j], defaultCards[k]]){
                        return [saveSelectedCards[0], defaultCards[j], defaultCards[k]]
                    }
                }
            }
        } else if saveSelectedCards.count == 2{
            for k in 0..<defaultCards.count{
                if isSet(cards: [saveSelectedCards[0], saveSelectedCards[1], defaultCards[k]]){
                    return [saveSelectedCards[0], saveSelectedCards[1], defaultCards[k]]
                }
            }
        } else if saveSelectedCards.count == 0 {
            for i in 0..<defaultCards.count{
                for j in 0..<defaultCards.count{
                    for k in 0..<defaultCards.count{
                        if isSet(cards: [defaultCards[i], defaultCards[j], defaultCards[k]]){
                            return [defaultCards[i], defaultCards[j], defaultCards[k]]
                        }
                    }
                }
            }
        }
        return nil
    }
    
    private func isSet(cards: Array<card>) -> Bool{
        let categories = ["color","shape", "shading", "number"]
        var sameCat = 0
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
            } else if catList.count == 1{
                sameCat += 1
            }
        }
        return true && sameCat != 4
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
            case isSelected, isInSet, isNotInSet, hint, `default`
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

//
//  MemoryGame.swift
//  Memorize
//
//  Created by 涂庭鋆 on 2022/8/30.
//

import Foundation

struct MemoryGame<CardContent>  where CardContent: Equatable {
    private(set) var cards: Array<Card>
    
    private var indexOfOnlyFaceUpCard: Int?
    
    mutating func choose(_ card: Card){
        if let chosenIndex = cards.firstIndex(where: {$0.id == card.id}),
           !cards[chosenIndex].isFaceUp,
           !cards[chosenIndex].isMatched
        {
            if let potentialMatched = indexOfOnlyFaceUpCard {
                if cards[potentialMatched].content == cards[chosenIndex].content {
                    cards[chosenIndex].isMatched = true
                    cards[potentialMatched].isMatched = true
                }
                indexOfOnlyFaceUpCard = nil
            } else {
                for index in cards.indices {
                    cards[index].isFaceUp = false
                }
                indexOfOnlyFaceUpCard = chosenIndex
            }
            
            cards[chosenIndex].isFaceUp.toggle()
        }
    }
    
    func index(of card: Card) -> Int? {
        for index in 0..<cards.count {
            if cards[index].id == card.id {
                return index
            }
        }
        return nil
    }
    
    init(numOfParisOfCards: Int, createCardContent: (Int) -> CardContent){
        cards = Array<Card>()
        
        for pairIndex in 0..<numOfParisOfCards{
            let content = createCardContent(pairIndex)
            cards.append(Card(id: pairIndex * 2, content: content))
            cards.append(Card(id: pairIndex * 2 + 1, content: content))
        }
    }
    
    struct Card: Identifiable {
        var id: Int
        var isFaceUp: Bool = false
        var isMatched: Bool = false
        var content: CardContent
    }
}

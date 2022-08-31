//
//  MemoryGame.swift
//  Memorize
//
//  Created by 涂庭鋆 on 2022/8/30.
//

import Foundation

struct MemoryGame<CardContent>  where CardContent: Equatable {
    private(set) var cards: Array<Card>
    private(set) var score: Int
    
    private var indexOfOnlyFaceUpCard: Int?{
        get { cards.indices.filter({ cards[$0].isFaceUp }).oneAndOnly }
        set { cards.indices.forEach{ cards[$0].isFaceUp = ($0 == newValue) } }
    }
    
    mutating func choose(_ card: Card){
        if let chosenIndex = cards.firstIndex(where: {$0.id == card.id}),
           !cards[chosenIndex].isFaceUp,
           !cards[chosenIndex].isMatched
        {
            // Get the time for the the card is clicked
            let chosenTime = Date()
            
            if let potentialMatched = indexOfOnlyFaceUpCard {
                // If one cards is faced up and another one is selected
                if cards[potentialMatched].content == cards[chosenIndex].content {
                    // If 2 cards match
                    let secondsInterval = Int(chosenTime.timeIntervalSince(cards[potentialMatched].timeChosen)) // number of seconds since last card was chosen
                    cards[chosenIndex].isMatched = true
                    cards[potentialMatched].isMatched = true
                    score += max(3 - secondsInterval, 1) * 2
                } else {
                    // If 2 cards don't match
                    if cards[potentialMatched].isSeem{
                        score -= 1
                    }
                    if cards[chosenIndex].isSeem{
                        score -= 1
                    }
                }
                cards[chosenIndex].isSeem = true
                cards[potentialMatched].isSeem = true
                cards[chosenIndex].isFaceUp.toggle()
                
            } else {
                cards[chosenIndex].timeChosen = chosenTime
                indexOfOnlyFaceUpCard = chosenIndex
            }
        }
    }
    
    init(numOfParisOfCards: Int, createCardContent: (Int) -> CardContent){
        score = 0
        cards = []
        
        for pairIndex in 0..<numOfParisOfCards{
            let content = createCardContent(pairIndex)
            cards.append(Card(id: pairIndex * 2, content: content))
            cards.append(Card(id: pairIndex * 2 + 1, content: content))
        }
        cards.shuffle()
    }
    
    struct Card: Identifiable {
        let id: Int
        var isFaceUp = false
        var isMatched = false
        var isSeem = false
        var timeChosen: Date = Date()
        let content: CardContent
    }
}

extension Array {
    var oneAndOnly: Element?{
        if self.count == 1 {
            return first
        } else {
            return nil
        }
    }
}

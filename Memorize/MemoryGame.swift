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
    
    private var indexOfOnlyFaceUpCard: Int?
    
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
                indexOfOnlyFaceUpCard = nil
            } else {
                // If no cards are faced up
                for index in cards.indices {
                    // Flip all the cards down
                    cards[index].isFaceUp = false
                }
                // Set the chosen card's time and such card must be the only faced up one
                cards[chosenIndex].timeChosen = chosenTime
                indexOfOnlyFaceUpCard = chosenIndex
            }
            // Make the chosen card face up
            cards[chosenIndex].isFaceUp.toggle()
        }
    }
    
    init(numOfParisOfCards: Int, createCardContent: (Int) -> CardContent){
        score = 0
        cards = Array<Card>()
        
        for pairIndex in 0..<numOfParisOfCards{
            let content = createCardContent(pairIndex)
            cards.append(Card(id: pairIndex * 2, content: content))
            cards.append(Card(id: pairIndex * 2 + 1, content: content))
        }
        cards.shuffle()
    }
    
    struct Card: Identifiable {
        var id: Int
        var isFaceUp: Bool = false
        var isMatched: Bool = false
        var isSeem: Bool = false
        var timeChosen: Date = Date()
        var content: CardContent
    }
}

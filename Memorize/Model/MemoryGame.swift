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
    
    var matchedCards: Array<Card>{
        cards.filter({ $0.isMatched })
    }
    
    private var indexOfOnlyFaceUpCard: Int?{
        get { cards.indices.filter({ cards[$0].isFaceUp }).oneAndOnly }
        set { cards.indices.forEach{ cards[$0].isFaceUp = ($0 == newValue) } }
    }
    
    mutating func choose(_ card: Card){
        if let chosenIndex = cards.firstIndex(where: {$0.id == card.id}),
           !cards[chosenIndex].isFaceUp,
           !cards[chosenIndex].isMatched
        {
            
            if let potentialMatched = indexOfOnlyFaceUpCard {
                // If one cards is faced up and another one is selected
                if cards[potentialMatched].content == cards[chosenIndex].content {
                    // If 2 cards match
                    cards[chosenIndex].isMatched = true
                    cards[potentialMatched].isMatched = true
                    score += Int(max(max(cards[potentialMatched].bonusRemaining,
                                         cards[chosenIndex].bonusRemaining) * 5,
                                     1)  * 2)
                } else {
                    // If 2 cards don't match
                    if cards[potentialMatched].isSeem{
                        score -= 2
                    }
                    if cards[chosenIndex].isSeem{
                        score -= 2
                    }
                }
                cards[chosenIndex].isSeem = true
                cards[potentialMatched].isSeem = true
                cards[chosenIndex].isFaceUp.toggle()
                
            } else {
                indexOfOnlyFaceUpCard = chosenIndex
            }
        }
    }
    
    mutating func unSelect(_ card: Card){
        let index = cards.firstIndex(where: { $0.id == card.id })!
        cards[index].isFaceUp = false
    }
    
    mutating func shuffle(){
        cards.shuffle()
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
        var isFaceUp = false {
            didSet {
                if isFaceUp{
                    startUsingBonusTime()
                } else {
                    stopUsingBonusTime()
                }
            }
        }
        var isMatched = false {
            didSet{
                stopUsingBonusTime()
            }
        }
        var isSeem = false
        let content: CardContent
        
        // MARK: - Bonus Time
                
        // this could give matching bonus points
        // if the user matches the card
        // before a certain amount of time passes during which the card is face up

        // can be zero which means "no bonus available" for this card
        var bonusTimeLimit: TimeInterval = 6

        // how long this card has ever been face up
        private var faceUpTime: TimeInterval {
            if let lastFaceUpDate = self.lastFaceUpDate {
                return pastFaceUpTime + Date().timeIntervalSince(lastFaceUpDate)
            } else {
                return pastFaceUpTime
            }
        }
        // the last time this card was turned face up (and is still face up)
        var lastFaceUpDate: Date?
        // the accumulated time this card has been face up in the past
        // (i.e. not including the current time it's been face up if it is currently so)
        var pastFaceUpTime: TimeInterval = 0

        // how much time left before the bonus opportunity runs out
        var bonusTimeRemaining: TimeInterval {
            max(0, bonusTimeLimit - faceUpTime)
        }
        // percentage of the bonus time remaining
        var bonusRemaining: Double {
            (bonusTimeLimit > 0 && bonusTimeRemaining > 0) ? bonusTimeRemaining/bonusTimeLimit : 0
        }
        // whether the card was matched during the bonus time period
        var hasEarnedBonus: Bool {
            isMatched && bonusTimeRemaining > 0
        }
        // whether we are currently face up, unmatched and have not yet used up the bonus window
        var isConsumingBonusTime: Bool {
            isFaceUp && !isMatched && bonusTimeRemaining > 0
        }

        // called when the card transitions to face up state
        private mutating func startUsingBonusTime() {
            if isConsumingBonusTime, lastFaceUpDate == nil {
                lastFaceUpDate = Date()
            }
        }
        // called when the card goes back face down (or gets matched)
        private mutating func stopUsingBonusTime() {
            pastFaceUpTime = faceUpTime
            self.lastFaceUpDate = nil
        }

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

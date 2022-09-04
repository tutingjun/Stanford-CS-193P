//
//  EmojiMemoryGame.swift
//  Memorize
//
//  Created by 涂庭鋆 on 2022/8/30.
//

import SwiftUI


class EmojiMemoryGame: ObservableObject {
    static let emojis = ["🚌", "🚇", "🚋", "🚁", "🛳", "⛵️", "🛴", "🚠", "🚀", "🛵", "🛰", "🚂", "⛴"]
    
    static func createMemoryGame() -> MemoryGame<String> {
        MemoryGame<String>(numOfParisOfCards: 4) { pairIndex in
            emojis[pairIndex]
        }
    }
    
    @Published private var model: MemoryGame<String> = createMemoryGame()
        
    
    var cards: Array<MemoryGame<String>.Card>{
        return model.cards
    }
    
    // MARK: - Intent
    
    func choose(_ card: MemoryGame<String>.Card){
        model.choose(card)
    }
}

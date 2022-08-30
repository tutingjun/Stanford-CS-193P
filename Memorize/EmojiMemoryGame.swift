//
//  EmojiMemoryGame.swift
//  Memorize
//
//  Created by 涂庭鋆 on 2022/8/30.
//

import SwiftUI


class EmojiMemoryGame {
    static let emojis = ["🚌", "🚇", "🚋", "🚁", "🛳", "⛵️", "🛴", "🚠", "🚀", "🛵", "🛰", "🚂", "⛴"]
    
    static func createMemoryGame() -> MemoryGame<String> {
        MemoryGame<String>(numOfParisOfCards: 4) { pairIndex in
            emojis[pairIndex]
        }
    }
    
    private var model: MemoryGame<String> = createMemoryGame()
        
    
    var cards: Array<MemoryGame<String>.Card>{
        return model.cards
    }
    
}

//
//  EmojiMemoryGame.swift
//  Memorize
//
//  Created by 涂庭鋆 on 2022/8/30.
//

import SwiftUI


class EmojiMemoryGame: ObservableObject {
    typealias Card = MemoryGame<String>.Card
    
    private static func createMemoryGame(_ theme: Theme) -> MemoryGame<String> {
        var emojis = theme.emojis.map{ String($0) }
        emojis.shuffle()
        return MemoryGame<String>(numOfParisOfCards: theme.numOfPairs) { pairIndex in
            emojis[pairIndex]
        }
    }
    
    private var theme: Theme
    @Published private var model: MemoryGame<String>
    
    init(theme: Theme){
        self.theme = theme
        model = EmojiMemoryGame.createMemoryGame(theme)
    }
    
    private(set) var isDealt = false
    
    var cards: Array<Card>{
        return model.cards
    }
    
    var themeTitle: String {
        return theme.name.capitalized
    }
    
    var themeColor: Color {
        return Color(rgbaColor: theme.colorDisplayed)
    }
    
    var score: Int {
        return model.score
    }
    
    // MARK: - Intent
    
    func choose(_ card: Card){
        model.choose(card)
    }
    
    func unSelect(_ card: Card){
        model.unSelect(card)
    }
    
    func newGame(){
        model = EmojiMemoryGame.createMemoryGame(theme)
        isDealt = false
    }
    
    func shuffle(){
        model.shuffle()
    }
    
    func setIsDealt(){
        isDealt = true
    }
}

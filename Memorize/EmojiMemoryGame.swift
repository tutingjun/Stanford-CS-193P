//
//  EmojiMemoryGame.swift
//  Memorize
//
//  Created by 涂庭鋆 on 2022/8/30.
//

import SwiftUI


class EmojiMemoryGame: ObservableObject {
    typealias Card = MemoryGame<String>.Card
    typealias Theme = MemoryGameTheme<String>.Theme
    
    private static let vehicleList = ["🚌", "🚇", "🚋", "🚁", "🛳", "⛵️", "🛴", "🚠", "🚀", "🛵", "🛰", "🚂", "⛴"]
    private static let animalList = ["🐵", "🐼", "🐙", "🐔", "🦅", "🐢", "🐷", "🐟", "🦐", "🐳", "🦒", "🐝", "🐊"]
    private static let foodList = ["🍔", "🍕", "🌭", "🌮", "🌶", "🌯", "🥟", "🍙", "🍚", "🍝", "🥖", "🍤"]
    private static let sportList = ["🏀", "⚽️", "🏈", "⚾️", "🥎", "🎾", "🏐", "🏉", "🥏", "🎱", "🪀", "🏓"]
    private static let countryList = ["🇨🇳", "🇰🇷", "🇸🇪", "🇯🇵", "🇺🇸", "🇬🇧", "🇪🇸", "🇪🇺", "🏳️‍🌈"]
    private static let toolsList = ["🪛", "✂️","🔧","🔨","🧲","🔩","🔦","🔌","💡","📱","⌚️","💻"]
    
    private static func addThemes(curTheme: inout MemoryGameTheme<String>) -> MemoryGameTheme<String>{
        let defaultPairs = 8
        curTheme.addTheme(curTheme.createSingleTheme(name: "Vehicles", emojis: vehicleList, numOfPairs: defaultPairs, colorDisplayed: "orange"))
        curTheme.addTheme(curTheme.createSingleTheme(name: "Animals", emojis: animalList, numOfPairs: defaultPairs, colorDisplayed: "red", randomPairs: true))
        curTheme.addTheme(curTheme.createSingleTheme(name: "Food", emojis: foodList, colorDisplayed: "yellow"))
        curTheme.addTheme(curTheme.createSingleTheme(name: "Sport", emojis: sportList, numOfPairs: defaultPairs, colorDisplayed: "purple"))
        curTheme.addTheme(curTheme.createSingleTheme(name: "Tools", emojis: toolsList, numOfPairs: defaultPairs, colorDisplayed: "green"))
        return curTheme
    }
    
    private static func randomTheme(_ curTheme: MemoryGameTheme<String>) -> Theme{
        return curTheme.themes.randomElement()!
    }
    
    private static func createMemoryGame(theme: Theme) -> MemoryGame<String> {
        var emojis = theme.emojis
        emojis.shuffle()
        return MemoryGame<String>(numOfParisOfCards: theme.numOfPairs) { pairIndex in
            emojis[pairIndex]
        }
    }
    
    private static func parseColor(color: String) -> Color{
        switch color{
        case "orange":
            return .orange
        case "red":
            return.red
        case "yellow":
            return .yellow
        case "purple":
            return .purple
        case "green":
            return .green
        default:
            print("This color: \(color) is not supported, return to color blue")
            return .blue
        }
    }
    
    private var themes: MemoryGameTheme<String>
    private var curTheme: Theme
    @Published private var model: MemoryGame<String>
    
    init(){
        themes = MemoryGameTheme<String>()
        themes = EmojiMemoryGame.addThemes(curTheme: &themes)
        curTheme = EmojiMemoryGame.randomTheme(themes)
        model = EmojiMemoryGame.createMemoryGame(theme: curTheme)
    }
    
    var cards: Array<Card>{
        return model.cards
    }
    
    var themeTitle: String {
        return curTheme.name.capitalized
    }
    
    var themeColor: Color {
        return EmojiMemoryGame.parseColor(color: curTheme.colorDisplayed)
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
        curTheme = EmojiMemoryGame.randomTheme(themes)
        model = EmojiMemoryGame.createMemoryGame(theme: curTheme)
    }
    
    func shuffle(){
        model.shuffle()
    }
}

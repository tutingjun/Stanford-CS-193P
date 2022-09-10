//
//  ThemeStore.swift
//  Memorize
//
//  Created by 涂庭鋆 on 2022/9/10.
//

import SwiftUI

struct Theme: Codable, Hashable, Identifiable {
    var name: String
    var emojis: String
    var removedEmojis: String
    var numOfPairs: Int
    var colorDisplayed: RGBAColor
    var id: Int
}

class EmojiThemeStore: ObservableObject {
    private let name: String
    @Published var themes = [Theme]() {
        didSet {
            storeInUserDefaults()
            updateThemeDict()
        }
    }
    private(set) var themeDict = [Int: EmojiMemoryGame]()
    
    private var userDefaultKey: String {
        "ThemeStore" + name
    }
    
    private func storeInUserDefaults(){
        UserDefaults.standard.set(try? JSONEncoder().encode(themes), forKey: userDefaultKey)
    }
    
    private func restoreInUserDefaults(){
        if let jsonData = UserDefaults.standard.data(forKey: userDefaultKey),
            let decodedThemes = try? JSONDecoder().decode(Array<Theme>.self, from: jsonData){
                themes = decodedThemes
        }
    }
    
    init(named name: String){
        self.name = name
        restoreInUserDefaults()
        if themes.isEmpty {
            insertTheme(named: "Vehicles",
                        emojis: "🚌🚇🚋🚁🛳⛵️🛴🚠🚀🛵🛰🚂⛴",
                        color: .orange)
            insertTheme(named: "Animals",
                        emojis: "🐵🐼🐙🐔🦅🐢🐷🐟🦐🐳🦒🐝🐊",
                        color: .red)
            insertTheme(named: "Food",
                        emojis: "🍔🍕🌭🌮🌶🌯🥟🍙🍚🍝🥖🍤",
                        color: .yellow)
            insertTheme(named: "Sport",
                        emojis: "🏀⚽️🏈⚾️🥎🎾🏐🏉🥏🎱🪀🏓",
                        color: .purple)
            insertTheme(named: "Tools",
                        emojis: "🪛✂️🔧🔨🧲🔩🔦🔌💡📱⌚️💻",
                        color: .green)
            
        }
        updateThemeDict()
    }
    
    // MARK: - Intent
    
    func theme(at index: Int) -> Theme {
        let safeIndex = min(max(index, 0), themes.count - 1)
        return themes[safeIndex]
    }
    
    @discardableResult
    func removeTheme(at index: Int) -> Int {
        if themes.count > 1, themes.indices.contains(index) {
            themes.remove(at: index)
        }
        return index % themes.count
    }
    
    func insertTheme(named name: String, emojis: String? = nil, at index: Int = 0, numOfPairs: Int? = nil, randomPairs: Bool = false, color: Color) {
        let unique = (themes.max(by: { $0.id < $1.id})? .id ?? 0) + 1
        let numPairAdded: Int
        let saveEmoji = emojis ?? ""
        if randomPairs {
            // Handle random num of pairs, ignore the numOfPairs params
            numPairAdded = Int.random(in: 4...themes.count)
        } else {
            // Handle optional numOfPairs params
            if let saveNumOfPairs = numOfPairs {
                // If has value, check if it is out of bounds (emoji.count)
                if saveEmoji.count < saveNumOfPairs{
                    numPairAdded = saveEmoji.count
                } else {
                    numPairAdded = saveNumOfPairs
                }
            } else {
                // No values, assign to size
                numPairAdded = saveEmoji.count
            }
        }
//        print(RGBAColor(color: color))
        let theme = Theme(name: name, emojis: saveEmoji, removedEmojis: "", numOfPairs: numPairAdded, colorDisplayed: RGBAColor(color: color), id: unique)
        print(theme)
        let safeIndex = min(max(index, 0), themes.count)
        themes.insert(theme, at: safeIndex)
    }
    
    func updateThemeDict(){
        themeDict = [Int: EmojiMemoryGame]()
        for theme in themes {
            themeDict[theme.id] = EmojiMemoryGame(theme: theme)
        }
    }
}



//
//  MemoryGameTheme.swift
//  Memorize
//
//  Created by 涂庭鋆 on 2022/8/31.
//

import Foundation

struct MemoryGameTheme<CardContent> where CardContent: Hashable{
    private(set) var themes: Array<Theme>
    
    func createSingleTheme (name: String,
                            emojis: Array<CardContent>,
                            numOfPairs: Int? = nil,
                            colorDisplayed: String,
                            randomPairs: Bool = false) -> Theme{
        
        var numOfPairsAdded: Int
        
        if randomPairs {
            // Handle random num of pairs, ignore the numOfPairs params
            numOfPairsAdded = Int.random(in: 4...emojis.count)
        } else {
            // Handle optional numOfPairs params
            if let saveNumOfPairs = numOfPairs {
                // If has value, check if it is out of bounds (emoji.count)
                if emojis.count < saveNumOfPairs{
                    numOfPairsAdded = emojis.count
                } else {
                    numOfPairsAdded = saveNumOfPairs
                }
            } else {
                // No values, assign to size
                numOfPairsAdded = emojis.count
            }
        }
        
        return Theme(name: name,
                     emojis: Array(Set(emojis)), // Remove duplicates
                     numOfPairs: numOfPairsAdded,
                     colorDisplayed: colorDisplayed)
    }
    
    init(){
        themes = Array<Theme>()
    }
    
    mutating func addTheme(_ singleTheme: Theme){
        themes.append(singleTheme)
    }
    
    struct Theme {
        var name: String
        var emojis: Array<CardContent>
        var numOfPairs: Int
        var colorDisplayed: String
    }
}

//
//  SetViewModel.swift
//  Set
//
//  Created by 涂庭鋆 on 2022/9/1.
//

import Foundation

class SetViewModel: ObservableObject {
    @Published private var model: SetGame
    
    init(){
        model = SetGame()
    }

    
    var displayedCards: Array<SetGame.card>{
        return model.displayedCards
    }
    
    var deckCount: Int {
        return model.deckCount
    }
    
    // MARK: - Intent
    func choose(_ card: SetGame.card){
        model.choose(card)
    }
    
    func newGame(){
        model = SetGame()
    }
    
    func dealThreeMore(){
        if deckCount != 0{
            model.getThreeCards()
        }
    }
}

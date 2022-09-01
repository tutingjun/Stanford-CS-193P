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

    
    var first12Cards: Array<SetGame.card>{
        return Array(model.cards[0..<12])
    }
    
    // MARK: - Intent
    func choose(_ card: SetGame.card){
        model.choose(card)
    }
}

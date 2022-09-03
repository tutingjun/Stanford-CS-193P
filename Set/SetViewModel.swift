//
//  SetViewModel.swift
//  Set
//
//  Created by 涂庭鋆 on 2022/9/1.
//

import Foundation

class SetViewModel: ObservableObject {
    @Published private var model: SetGame
    @Published private var player: Player
    
    private var isMultiplayer: Bool
    
    init(isMultiplayer: Bool){
        model = SetGame()
        player = Player(isMultiplayer: isMultiplayer)
        self.isMultiplayer = isMultiplayer
    }

    
    var displayedCards: Array<SetGame.card>{
        return model.displayedCards
    }
    
    var deckCount: Int {
        return model.deckCount
    }
    
    var hasCheat: Bool{
        return model.hasHint
    }
    
    var canSelect: Bool{
        return player.canSelect
    }
    
    var players: Array<Player.singlePlayer>{
        return player.players
    }
    
    // MARK: - Intent
    func choose(_ card: SetGame.card){
        if !canSelect{
            let curPlayer = players.filter({$0.isSelecting == true})[0]
            model.choose(card, by: curPlayer, &player, isMultiplayer: isMultiplayer)
        }
        
    }
    
    func newGame(){
        model = SetGame()
        player = Player(isMultiplayer: isMultiplayer)
    }
    
    func hint(by curPlayer: Player.singlePlayer){
        if hasCheat && !canSelect{
            model.hint(from: curPlayer, &player)
        }
    }
    
    func dealThreeMore(by curPlayer: Player.singlePlayer){
        if deckCount != 0{
            model.getThreeCards(from: curPlayer, &player)
        }
    }
    
    func playerChoose(by curPlayer: Player.singlePlayer){
        if canSelect{
            player.changeIsSelecting(player: curPlayer)
        }
    }
}

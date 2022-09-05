//
//  PlayerModel.swift
//  Set
//
//  Created by 涂庭鋆 on 2022/9/2.
//

import Foundation

struct Player{
    private(set) var players: Array<singlePlayer>
    
    var canSelect: Bool{
        var result = false
        players.forEach{ player in
            result = result || player.isSelecting
        }
        return !result
    }
    
    init(isMultiplayer: Bool){
        players = Array<singlePlayer>()
        if isMultiplayer{
            players.append(singlePlayer())
            players.append(singlePlayer())
        } else {
            players.append(singlePlayer())
            changeIsSelecting(player: players[0])
        }
    }
    
    mutating func reset(){
        for i in players.indices{
            players[i].score = 0
        }
    }
    
    mutating func addScore(player: singlePlayer, score: Int){
        let index = players.indices.filter({ players[$0].id == player.id }).first!
        players[index].score += score
    }
    
    mutating func changeIsSelecting(player: singlePlayer){
        let index = players.indices.filter({ players[$0].id == player.id }).first!
        players[index].isSelecting = !players[index].isSelecting
    }
    
    struct singlePlayer: Identifiable{
        var id: UUID
        var isSelecting: Bool
        var score: Int
        
        init(){
            id = UUID()
            isSelecting = false
            score = 0
        }
    }
}

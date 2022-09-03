//
//  SetApp.swift
//  Set
//
//  Created by 涂庭鋆 on 2022/9/1.
//

import SwiftUI

@main
struct SetApp: App {
    var multiplayer = false
    let game: SetViewModel
    
    init(){
        game = SetViewModel(isMultiplayer: multiplayer)
    }
    var body: some Scene {
        WindowGroup {
            SetGameView(game: game, isMultiplayer: multiplayer)
        }
    }
}

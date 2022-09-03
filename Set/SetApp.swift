//
//  SetApp.swift
//  Set
//
//  Created by 涂庭鋆 on 2022/9/1.
//

import SwiftUI

@main
struct SetApp: App {
    let game =  SetViewModel(isMultiplayer: false)
    let gameMulti =  SetViewModel(isMultiplayer: true)
    
    var body: some Scene {
        WindowGroup {
            SetGameView(game: game,gameMulti: gameMulti)
        }
    }
}

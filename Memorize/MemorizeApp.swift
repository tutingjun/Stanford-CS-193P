//
//  MemorizeApp.swift
//  Memorize
//
//  Created by 涂庭鋆 on 2022/8/29.
//

import SwiftUI

@main
struct MemorizeApp: App {
    @StateObject var themeStore = EmojiThemeStore(named: "test")
    
    var body: some Scene {
        WindowGroup {
            EmojiThemeChooser()
                .environmentObject(themeStore)
        }
    }
}

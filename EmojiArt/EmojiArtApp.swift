//
//  EmojiArtApp.swift
//  EmojiArt
//
//  Created by 涂庭鋆 on 2022/9/5.
//

import SwiftUI

@main
struct EmojiArtApp: App {
    var body: some Scene {
        DocumentGroup(newDocument: EmojiArtDocument()) { file in
            ContentView(document: file.$document)
        }
    }
}

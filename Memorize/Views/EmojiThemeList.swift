//
//  EmojiThemeList.swift
//  Memorize
//
//  Created by 涂庭鋆 on 2022/9/10.
//

import SwiftUI

struct EmojiThemeList: View {
    @EnvironmentObject var store: EmojiThemeStore
    
    var body: some View {
        NavigationView{
            List{
                ForEach(store.themes){ theme in
                    NavigationLink(destination: EmojiMemoryGameView(game: store.themeDict[theme.id]!)){
                        VStack(alignment: .leading){
                            Text(theme.name)
                            Text(theme.emojis)
                        }
                    }
                    
                    
                }
            }
            .navigationTitle("Memory Game")
        }
    }
}

struct EmojiThemeList_Previews: PreviewProvider {
    static var previews: some View {
        EmojiThemeList()
            .environmentObject(EmojiThemeStore(named: "preview"))
            
    }
}

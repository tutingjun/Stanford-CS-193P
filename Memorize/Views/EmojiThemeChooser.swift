//
//  EmojiThemeChooser.swift
//  Memorize
//
//  Created by 涂庭鋆 on 2022/9/10.
//

import SwiftUI

struct EmojiThemeChooser: View {
    @EnvironmentObject var store: EmojiThemeStore
    
    @State private var editMode: EditMode = .inactive
    @State private var themeToEdit: Theme?
//    @State private var isNewTheme: Bool = false
    
    var body: some View {
        NavigationView{
            List{
                ForEach(store.themes){ theme in
                    NavigationLink(destination: EmojiMemoryGameView(game: store.themeDict[theme.id]!)){
                        body(for: theme)
                            .gesture(editMode == .active ? tap(of: theme) : nil )
                    }
                }
                .onDelete{ indexSet in
                    store.themes.remove(atOffsets: indexSet)
                }
                .onMove{ indexSet, newOffset in
                    store.themes.move(fromOffsets: indexSet, toOffset: newOffset)
                }
            }
            .listStyle(.plain)
            .navigationBarTitleDisplayMode(.large)
            .navigationTitle("Memory Game")
            .toolbar{
                ToolbarItem{ EditButton() }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button{
                        store.insertTheme(named: "New", color: .white)
                        themeToEdit = store.themes[0]
                    } label:{
                        Image(systemName: "plus")
                    }
                }
            }
            .environment(\.editMode, $editMode)
            .onAppear{
                print("curThemes: \(store.themes)")
            }
        }
    }
    
    @ViewBuilder
    private func body(for theme: Theme) -> some View{
        VStack(alignment: .leading){
            Text(theme.name)
                .font(.title2)
                .bold()
                .padding(.vertical, 3.0)
                .foregroundColor(Color(rgbaColor: theme.colorDisplayed))
            HStack{
                Text(computePairText(theme: theme))
                Text(theme.emojis)
                    .lineLimit(1)
            }
        }
        .sheet(item: $themeToEdit){ theme in
            EmojiThemeEditor(theme: $store.themes[theme])
        }
    }
    
    private func tap(of theme: Theme) -> some Gesture{
        TapGesture().onEnded{
            themeToEdit = theme
        }
    }
    
    private func computePairText(theme: Theme) -> String{
        if theme.numOfPairs == 0{
            return ""
        }
        if theme.numOfPairs == theme.emojis.count {
            return "All of"
        } else {
            return "\(theme.numOfPairs) pairs of"
        }
    }
}

struct EmojiThemeList_Previews: PreviewProvider {
    static var previews: some View {
        EmojiThemeChooser()
            .environmentObject(EmojiThemeStore(named: "preview"))
            
    }
}

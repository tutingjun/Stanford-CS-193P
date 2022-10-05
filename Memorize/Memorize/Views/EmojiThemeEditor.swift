//
//  EmojiThemeEditor.swift
//  Memorize
//
//  Created by 涂庭鋆 on 2022/9/10.
//

import SwiftUI

struct EmojiThemeEditor: View {
    @EnvironmentObject var store: EmojiThemeStore
    
    @Binding var theme: Theme
    @Environment(\.dismiss) var dismiss
    
    @State private var originalTheme: Theme?
    @State private var emojisToAdd = ""
    @State private var colorChange: Color =  .white
    @State private var showAlert =  false
    
    
    var body: some View {
        NavigationView{
            Form{
                nameSection
                removeEmojis
                if theme.removedEmojis != ""{
                    recoverEmojis
                }
                addEmojis
                addNumOfPairs
                colorChoose
            }
            .navigationTitle("\(theme.name)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar{
                ToolbarItem {
                    Button("Done"){
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        showAlert = true
                    }
                }
            }
            .onAppear{
                colorChange = Color(rgbaColor: theme.colorDisplayed)
                originalTheme = theme
            }
            .alert(isPresented: $showAlert){
                Alert(title: Text("Are you sure you want to discard all changes?"),
                      message: Text("There will be no recovery"),
                      primaryButton:
                        .destructive(Text("Yes")) {
                            theme = originalTheme!
                            if theme.emojis == ""{
                                store.removeTheme(at: 0)
                            }
                            dismiss()
                        },
                      secondaryButton: .cancel())
            }
        }
        
    }
    
    private var nameSection: some View{
        Section(header: sectionHeader("Theme Name")){
            TextField("Name", text: $theme.name)
        }
    }
    
    private var removeEmojis: some View{
        Section{
            let emojis = theme.emojis.removingDuplicateCharacters.map { String($0) }
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 40))]) {
                ForEach(emojis, id: \.self) { emoji in
                    Text(emoji)
                        .onTapGesture {
                            withAnimation {
                                if theme.numOfPairs == emojis.count {
                                    theme.numOfPairs -= 1
                                }
                                theme.emojis.removeAll(where: { String($0) == emoji })
                                theme.removedEmojis = (emoji + theme.removedEmojis)
                            }
                        }
                }
            }
            .font(.system(size: 40))
        } header: {
            HStack{
                sectionHeader("Emojis")
                Spacer()
                Text("Tap emoji to remove")
            }
        }
    }
    
    private var addEmojis: some View{
        Section(header: sectionHeader("Add Emojis")){
            TextField("", text: $emojisToAdd)
                .onChange(of: emojisToAdd) { emojis in
                    addEmojis(emojis)
                }
        }
    }
    
    private var recoverEmojis: some View{
        Section{
            let emojis = theme.removedEmojis.removingDuplicateCharacters.map { String($0) }
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 40))]) {
                ForEach(emojis, id: \.self) { emoji in
                    Text(emoji)
                        .onTapGesture {
                            withAnimation {
                                theme.emojis = (emoji + theme.emojis)
                                theme.removedEmojis.removeAll(where: { String($0) == emoji })
                            }
                        }
                }
            }
            .font(.system(size: 40))
        } header: {
            HStack{
                sectionHeader("Deleted Emojis")
                Spacer()
                Text("Tap emoji to recover")
            }
        }
    }
    
    private var addNumOfPairs: some View{
        Section(header: sectionHeader("Card Count")){
            if theme.numOfPairs < 2{
                Stepper("\(theme.numOfPairs) pairs", value: $theme.numOfPairs, in: 0...theme.emojis.count)
            } else {
                Stepper("\(theme.numOfPairs) pairs", value: $theme.numOfPairs, in: 2...theme.emojis.count)
            }
        }
    }
    
    private var colorChoose: some View{
        Section(header: sectionHeader("Card Color")){
            ColorPicker("Card Color", selection: $colorChange)
                .onChange(of: colorChange){ color in
                    theme.colorDisplayed = RGBAColor(color: color)
                }
        }
    }
    
    func addEmojis(_ emojis: String){
        withAnimation{
            theme.emojis = (emojis + theme.emojis)
                .filter{ $0.isEmoji }
                .removingDuplicateCharacters
        }
    }
    
    
    @ViewBuilder
    private func sectionHeader(_ headerText: String) -> some View{
        Text(headerText).font(.body).fontWeight(.semibold).foregroundColor(.black)
    }
}

struct EmojiThemeEditor_Previews: PreviewProvider {
    static var previews: some View {
        EmojiThemeEditor(theme: .constant(Theme(name: "test", emojis: "🐵🐼🐙🐔🦅🐢🐷🐟🦐🐳🦒🐝🐊", removedEmojis: "", numOfPairs: 10, colorDisplayed: RGBAColor(color: .blue), id: 30)))
    }
}

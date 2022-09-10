//
//  PaletteManger.swift
//  EmojiArt
//
//  Created by 涂庭鋆 on 2022/9/9.
//

import SwiftUI

struct PaletteManger: View {
    @EnvironmentObject var store: PaletteStore
    @Environment(\.presentationMode) var presentationMode
    
    @State private var editMode: EditMode = .inactive
    
    var body: some View {
        NavigationView{
            List {
                ForEach(store.palettes){ palette in
                    NavigationLink(destination: PaletteEditor(palette: $store.palettes[palette])){
                        VStack(alignment: .leading) {
                            Text(palette.name)
                            Text(palette.emojis)
                        }
                    }
                }
                .onDelete{ indexSet in
                    store.palettes
                        .remove(atOffsets: indexSet)
                }
                .onMove{ indexSet, newOffset in
                    store.palettes.move(fromOffsets: indexSet, toOffset: newOffset)
                }
            }
            .navigationTitle("Manage Palettes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar{
                ToolbarItem{ EditButton() }
                ToolbarItem(placement: .navigationBarLeading) {
                    if presentationMode.wrappedValue.isPresented,
                       UIDevice.current.userInterfaceIdiom != .pad {
                        Button("Close") {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
            }
            .environment(\.editMode, $editMode)
        }
    }
}

struct PaletteManger_Previews: PreviewProvider {
    static var previews: some View {
        PaletteManger()
            .previewDevice("iPhone 8")
            .environmentObject(PaletteStore(named: "test2"))
    }
}

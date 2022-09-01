//
//  SetGameView.swift
//  Set
//
//  Created by 涂庭鋆 on 2022/9/1.
//

import SwiftUI

struct SetGameView: View {
    @ObservedObject var game: SetViewModel
    
    var body: some View {
        VStack{
            Text("Set Game!")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()
            AspectVGrid(items: game.first12Cards, aspectRatio: 2/3) { item in
                CardView(card: item)
                    .padding(4)
                    .onTapGesture {
                        game.choose(item)
                    }
            }
            .foregroundColor(.purple)
            
            HStack{
                button("New Game"){
                    
                }
                Spacer()
                button("Deal 3 More"){
                    
                }
            }
        }
        .padding(.horizontal)
    }
    
    @ViewBuilder
    private func button(_ content: String, actionToDo: @escaping () -> Void) -> some View{
        Button(action: {
            actionToDo()
        }, label: {
            Text(content)
        })
        .padding()
        .font(.headline)
        .foregroundColor(.white)
        .background(Color.blue)
        .clipShape(RoundedRectangle(cornerRadius: 15))
    }
}

struct SetGameView_Previews: PreviewProvider {
    static var previews: some View {
        let game = SetViewModel()
        SetGameView(game: game)
    }
}

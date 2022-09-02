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
                .padding(.vertical)
            
            HStack{
                Text("Score")
                    .font(.title3)
                    .fontWeight(.semibold)
                Spacer()
                Text("\(game.score)")
                    .fontWeight(.semibold)
            }
            
            AspectVGrid(items: game.displayedCards, aspectRatio: 2/3) { item in
                CardView(card: item)
                    .padding(4)
                    .onTapGesture {
                        game.choose(item)
                    }
            }
            .foregroundColor(Color.teal)
            
            HStack{
                button("New Game", color: .blue){
                    game.newGame()
                }
                Spacer()
                button("Hint", color: game.hasCheat ? Color.yellow : Color.gray){
                    game.hint()
                }
                Spacer()
                button("Deal 3 More", color: game.deckCount == 0 ? Color.gray : Color.blue){
                    game.dealThreeMore()
                }
            }
        }
        .padding(.horizontal)
    }
    
    @ViewBuilder
    private func button(_ content: String, color: Color, actionToDo: @escaping () -> Void) -> some View{
        Button(action: {
            actionToDo()
        }, label: {
            Text(content)
        })
        .padding()
        .font(.headline)
        .foregroundColor(.white)
        .background(color)
        .clipShape(RoundedRectangle(cornerRadius: 15))
    }
    
    private func convertDeckCount(_ deck: Int?) -> Int{
        if let saveCount = deck{
            return saveCount
        } else {
            return 1
        }
    }
}

struct SetGameView_Previews: PreviewProvider {
    static var previews: some View {
        let game = SetViewModel()
        SetGameView(game: game)
        SetGameView(game: game)
            .rotationEffect(.degrees(180))
    }
}

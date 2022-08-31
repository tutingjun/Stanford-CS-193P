//
//  ContentView.swift
//  Memorize
//
//  Created by 涂庭鋆 on 2022/8/29.
//

import SwiftUI

func widthThatBestFits(cardCount: Int) -> CGFloat{
    switch cardCount{
    case 4:
        return 130
    case 5...9:
        return 90
    case 10...13:
        return 80
    default:
        return 80
    }
}

struct ContentView: View {
    @ObservedObject var viewModel: EmojiMemoryGame
    
    var body: some View {
        VStack{
            Text("Memorize!")
                .font(.largeTitle)
                .padding()
            ScrollView{
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 65))]){
                    ForEach(viewModel.cards) {card in
                        CardView(card: card)
                            .aspectRatio(2/3, contentMode: .fit)
                            .onTapGesture {
                                viewModel.choose(card)
                            }
                    }
                }
            }
            .foregroundColor(.orange)
        }
        .padding(.horizontal)
    }
}

struct CardView: View{
    let card: MemoryGame<String>.Card
    
    var body: some View{
        ZStack(alignment: .center) {
            let shape = RoundedRectangle(cornerRadius: 20)
            if card.isFaceUp{
                shape.fill().foregroundColor(.white)
                shape.strokeBorder(lineWidth: 3)
                Text(card.content).font(.largeTitle)
            } else if card.isMatched {
                shape.opacity(0)
            }
            else {
                shape.fill()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let game = EmojiMemoryGame()
        ContentView(viewModel: game)
            .preferredColorScheme(.dark)
        ContentView(viewModel: game)
            .preferredColorScheme(.light)
    }
}

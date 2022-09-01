//
//  EmojiMemoryGameView.swift
//  Memorize
//
//  Created by 涂庭鋆 on 2022/8/29.
//

import SwiftUI

struct EmojiMemoryGameView: View {
    @ObservedObject var game: EmojiMemoryGame
    
    var body: some View {
        VStack{
            Text("Memorize!")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()
            
            subHeadline(themeTitle: game.themeTitle, score: game.score)
            
            AspectVGrid(items: game.cards, aspectRatio: 2/3) { card in
                cardStackView(for: card)
            }
            .foregroundColor(game.themeColor)

            newGameButton("New Game")
        }
        .padding(.horizontal)
    }
    
    @ViewBuilder
    private func subHeadline(themeTitle: String, score: Int) -> some View{
        HStack{
            VStack(alignment: .leading){
                Text("Current Theme")
                    .font(.title3)
                    .fontWeight(.semibold)
                Text("\(themeTitle)")
            }
            Spacer()
            VStack(alignment: .leading){
                Text("Score")
                    .font(.title3)
                    .fontWeight(.semibold)
                Text("\(score)")
            }
        }
    }
    
    @ViewBuilder
    private func newGameButton(_ content: String) -> some View{
        Button(action: {
            game.newGame()
        }, label: {
            Text(content)
        })
        .padding()
        .font(.headline)
        .foregroundColor(.white)
        .background(Color.blue)
        .clipShape(RoundedRectangle(cornerRadius: 15))
    }
    
    @ViewBuilder
    private func cardStackView(for card: EmojiMemoryGame.Card) -> some View{
        if card.isMatched && !card.isFaceUp {
            Rectangle().opacity(0)
        } else {
            CardView(card: card)
                .padding(4)
                .onTapGesture {
                    game.choose(card)
                }
        }
    }
}

struct CardView: View{
    let card: EmojiMemoryGame.Card
    
    var body: some View{
        GeometryReader{ geometry in
            ZStack(alignment: .center) {
                let shape = RoundedRectangle(cornerRadius: DrawingConstants.cornerRadius)
                if card.isFaceUp{
                    shape.fill().foregroundColor(.white)
                    shape.strokeBorder(lineWidth: DrawingConstants.lineWidth)
                    Pie(startAngle: Angle(degrees: 0-90), endAngle: Angle(degrees: 110-90))
                        .padding(5).opacity(0.5)
                    Text(card.content) .font(font(in: geometry.size))
                } else {
                    shape.fill()
                }
            }
        }
    }
    
    private func font(in size: CGSize) -> Font {
        Font.system(size: min(size.width, size.height) * DrawingConstants.fontScale)
    }
    
    private struct DrawingConstants {
        static let cornerRadius: CGFloat = 10
        static let lineWidth: CGFloat = 3
        static let fontScale: CGFloat = 0.6
    }
    
}



















struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let game = EmojiMemoryGame()
        game.choose(game.cards.first!)
        return EmojiMemoryGameView(game: game)
            .preferredColorScheme(.light)
    }
}

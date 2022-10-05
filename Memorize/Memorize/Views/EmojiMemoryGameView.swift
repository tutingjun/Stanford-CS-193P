//
//  EmojiMemoryGameView.swift
//  Memorize
//
//  Created by 涂庭鋆 on 2022/8/29.
//

import SwiftUI

import ConfettiSwiftUI

struct EmojiMemoryGameView: View {
    @ObservedObject var game: EmojiMemoryGame
    @Namespace private var dealingNameSpace
    @State private var isNewGame: Bool = false
    @State private var counter: Int = 0
    
    var body: some View {
        ZStack(alignment: .bottom){
            VStack{
                Text("Memorize!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()
                subHeadline(themeTitle: game.themeTitle, score: game.score)
                if game.matchedCardCount == game.cards.count{
                    winScreen
                } else {
                    gameBody
                }
                HStack{
                    newGameButton("New Game"){
                        withAnimation{
                            isNewGame = true
                            dealt = []
                            game.newGame()
                        }
                    }
                    Spacer()
                    newGameButton("Shuffle"){
                        withAnimation{
                            game.shuffle()
                        }
                    }
                }
            }
            .confettiCannon(counter: $counter, num: 50, repetitions: 1, repetitionInterval: 0.7)
            deckBody
        }
        .onAppear{
            if game.isDealt{
                for card in game.cards{
                    deal(card)
                }
            }
        }
        .padding(.horizontal)
        .navigationBarTitle("")
        .navigationBarTitleDisplayMode(.inline)
//        .navigationBarHidden(true)
    }
    
    private var winScreen: some View{
        VStack{
            Spacer()
            Text("You win! 🎉")
                .font(.largeTitle)
                .bold()
                .foregroundColor(.teal)
            Spacer()
        }
        .onAppear{
            counter += 1
        }
    }
    
    @State private var dealt = Set<Int>()
    
    private func deal(_ card: EmojiMemoryGame.Card) {
        dealt.insert(card.id)
    }
    
    private func isUndealt(_ card: EmojiMemoryGame.Card) -> Bool{
        !dealt.contains(card.id)
    }
    
    private func dealAnimation(for card: EmojiMemoryGame.Card) -> Animation {
        var delay = 0.0
        if let index = game.cards.firstIndex(where: { $0.id == card.id }){
            delay = Double(index) * (CardConstants.totalDealDuration / Double(game.cards.count))
        }
        return Animation.easeInOut(duration: CardConstants.dealDuration).delay(delay)
    }
    
    private func zIndex(of card: EmojiMemoryGame.Card) -> Double {
        -Double(game.cards.firstIndex(where: {$0.id == card.id}) ?? 0)
    }
    
    var gameBody: some View{
        AspectVGrid(items: game.cards, aspectRatio: 2/3) { card in
            if isUndealt(card) || (card.isMatched && !card.isFaceUp) {
                Color.clear
            } else {
                CardView(card: card)
                    .matchedGeometryEffect(id: card.id, in: dealingNameSpace)
                    .padding(4)
                    .transition(AnyTransition.asymmetric(insertion: .identity, removal: isNewGame ? .opacity : .scale))
                    .zIndex(zIndex(of: card))
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.5)){
                            isNewGame = false
                            game.choose(card)
                        }
                    }
            }
        }
        .foregroundColor(game.themeColor)
    }
    
    var deckBody: some View {
        ZStack{
            ForEach(game.cards.filter(isUndealt)){ card in
                CardView(card: card)
                    .transition(AnyTransition.asymmetric(insertion: .opacity, removal: .identity))
                    .matchedGeometryEffect(id: card.id, in: dealingNameSpace)
            }
        }
        .frame(width: CardConstants.undealtWidth, height: CardConstants.undealtHeight)
        .foregroundColor(game.themeColor)
        .onTapGesture {
            for card in game.cards{
                withAnimation(dealAnimation(for: card)){
                    deal(card)
                }
            }
            game.setIsDealt()
        }
    }
    
    private struct CardConstants {
        static let aspectRatio: CGFloat = 2/3
        static let dealDuration: Double = 0.5
        static let totalDealDuration: Double = 2
        static let undealtHeight: CGFloat = 90
        static let undealtWidth = undealtHeight * aspectRatio
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
    private func newGameButton(_ content: String, actionToDo: @escaping () -> Void) -> some View{
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

struct CardView: View{
    let card: EmojiMemoryGame.Card
    
    @State private var animatedBonusRemaining: Double = 0
    
    var body: some View{
        GeometryReader{ geometry in
            ZStack(alignment: .center) {
                Group{
                    if card.isConsumingBonusTime{
                        Pie(startAngle: Angle(degrees: 0-90), endAngle: Angle(degrees: (1 - animatedBonusRemaining) * 360-90))
                            .onAppear{
                                animatedBonusRemaining = card.bonusRemaining
                                withAnimation(.linear(duration: card.bonusTimeRemaining)){
                                    animatedBonusRemaining = 0
                                }
                            }
                    } else {
                        if card.bonusRemaining == 1{
                            Pie(startAngle: Angle(degrees: 0-90), endAngle: Angle(degrees: -360-90))
                        } else {
                            Pie(startAngle: Angle(degrees: 0-90), endAngle: Angle(degrees: (1 - card.bonusRemaining) * 360-90))
                        }
                    }
            
                }
                .padding(5).opacity(0.5)
                Text(card.content)
                    .rotationEffect(Angle.degrees(card.isMatched ? 360 : 0))
                    .animation(Animation.easeInOut(duration: 1), value: card.isMatched)
                    .font(.system(size: DrawingConstants.fontSize))
                    .scaleEffect(scale(thatFits: geometry.size))
            }
            .cardify(isFaceUp: card.isFaceUp)
        }
    }
    
    private func scale(thatFits size: CGSize) -> CGFloat{
        min(size.width, size.height) / (DrawingConstants.fontSize / DrawingConstants.fontScale)
    }
    
    private func font(in size: CGSize) -> Font {
        Font.system(size: min(size.width, size.height) * DrawingConstants.fontScale)
    }
    
    private struct DrawingConstants {
        static let fontScale: CGFloat = 0.6
        static let fontSize: CGFloat = 32
    }
    
}














struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let game = EmojiMemoryGame(theme: Theme(name: "animal", emojis: "🐵🐼🐙🐔🦅🐢🐷🐟🦐🐳🦒🐝🐊", removedEmojis: "", numOfPairs: 2, colorDisplayed: RGBAColor(color: .green), id: 234))
        return EmojiMemoryGameView(game: game)
            .preferredColorScheme(.light)
    }
}

//
//  onePlayer.swift
//  Set
//
//  Created by 涂庭鋆 on 2022/9/4.
//

import SwiftUI

struct onePlayer: View {
    @ObservedObject var game: SetViewModel
    @Namespace private var dealingNameSpace
    
    @State private var dealt = Set<UUID>()
    var player1: Player.singlePlayer
    
    init(_ game: SetViewModel){
        self.game = game
        self.player1 = game.players[0]
    }
    
    var body: some View{
        ZStack(alignment: .bottom){
            gameBody
            gameDeck
                .padding(.bottom)
        }
    }
    
    var gameBody: some View{
        VStack{
            Text("Set Game!")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.vertical)
            
            score(player1.score)
            
            cardBody
            
            HStack{
                gameButton("New Game", color: .blue){
                    withAnimation{
                        game.newGame()
                    }
                }
                Spacer()
                gameButton("Hint", color: game.hasCheat ? Color.yellow : Color.gray){
                    print(player1)
                    game.hint(by: player1)
                }
            }
        }
        .padding([.leading, .bottom, .trailing])
    }
    
    var cardBody: some View{
        AspectVGrid(items: game.displayedCards, aspectRatio: 2/3, isMiddle: false) { item in
            if isUndealt(item) {
                Rectangle().strokeBorder()
            } else {
                CardView(card: item)
                    .matchedGeometryEffect(id: item.id, in: dealingNameSpace)
                    .padding(4)
                    .zIndex(zIndex(of: item))
                    .onTapGesture {
                        withAnimation{
                            game.choose(item)
                        }
                    }
            }
        }
        .foregroundColor(CardConstants.cardColor)
    }
    
    var gameDeck: some View{
        ZStack{
            ForEach(game.deck.filter(isUndealt)){ card in
                CardView(card: card)
                    .matchedGeometryEffect(id: card.id, in: dealingNameSpace)
            }
        }
        .frame(width: CardConstants.undealtWidth, height: CardConstants.undealtHeight)
        .foregroundColor(CardConstants.cardColor)
        .onTapGesture {
            for card in game.displayedCards{
                withAnimation(dealAnimation(at: card)){
                    deal(card)
                }
            }
        }
    }
    
    private func deal(_ card: SetGame.card) {
        dealt.insert(card.id)
    }
    
    private func zIndex(of card: SetGame.card) -> Double {
        -Double(game.deck.firstIndex(where: {$0.id == card.id}) ?? 0)
    }
    
    private func isUndealt(_ card: SetGame.card) -> Bool{
        !dealt.contains(card.id)
    }
    
    private func dealAnimation(at card: SetGame.card) -> Animation {
        var delay = 0.0
        if let index = game.displayedCards.firstIndex(where: { $0.id == card.id }){
            delay = Double(index) * (CardConstants.totalDealDuration / Double(game.displayedCards.count))
        }
        return Animation.easeInOut(duration: CardConstants.dealDuration).delay(delay)
    }
}

private struct CardConstants {
    static let cardColor: Color = .teal
    static let aspectRatio: CGFloat = 2/3
    static let dealDuration: Double = 0.5
    static let totalDealDuration: Double = 2
    static let undealtHeight: CGFloat = 90
    static let undealtWidth = undealtHeight * aspectRatio
}






//
//struct onePlayer_Previews: PreviewProvider {
//    static var previews: some View {
//        onePlayer()
//    }
//}

//
//  onePlayer.swift
//  Set
//
//  Created by 涂庭鋆 on 2022/9/4.
//

import SwiftUI

struct onePlayer: View{
    @ObservedObject var game: SetViewModel
    @Namespace private var dealingNameSpace
    @Namespace private var matchNameSpace
    
    @State private var dealt = Set<UUID>()
    @State private var matched = Array<SetGame.card>()
    
    init(_ game: SetViewModel){
        self.game = game
    }
    
    var body: some View{
        ZStack(alignment: .bottom){
            gameBody
            HStack{
                gameDeck
                discardDeck
            }
                .padding(.bottom)
        }
    }
    
    var gameBody: some View{
        let player1 = game.players[0]
        return VStack{
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
                        dealt = Set<UUID>()
                        matched = Array<SetGame.card>()
                    }
                }
                Spacer()
                gameButton("Hint", color: game.hasCheat ? Color.yellow : Color.gray){
                    game.hint(by: player1)
                }
            }
        }
        .padding([.leading, .bottom, .trailing])
    }
    
    var cardBody: some View{
        AspectVGrid(items: game.displayedCards, aspectRatio: 2/3, isMiddle: false) { item in
            if isUndealt(item) || matched.contains(where: { $0.id == item.id }) {
                Color.clear
            } else if item.state == .isInSet && !matched.contains(where: { $0.id == item.id }){
                CardView(card: item, isFaceUp: false)
                 .matchedGeometryEffect(id: item.id.hashValue, in: matchNameSpace)
            } else {
                CardView(card: item, isFaceUp: false)
                
                    .matchedGeometryEffect(id: item.id, in: dealingNameSpace)
                    .padding(4)
                    .zIndex(zIndex(of: item))
                    .onTapGesture {
                        game.choose(item)
                        
                        if game.inSetCards.count != 0{
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            for card in game.inSetCards{
                                withAnimation(dealAnimation(at: card,
                                                            duration: CardConstants.totalDealDuration - 1.6,
                                                            range: 3,
                                                            from: game.inSetCards)){
                                    match(card)
                                }
                            }
                            game.choose(item)
                            let filteredList = game.displayedCards.filter(isUndealt)
                            
                            let secondsToDelay = 0.75
                            DispatchQueue.main.asyncAfter(deadline: .now() + secondsToDelay) {
                                for card in filteredList{
                                    withAnimation(dealAnimation(at: card,
                                                                duration: CardConstants.totalDealDuration - 1.6,
                                                                range: 3,
                                                                from: filteredList)){
                                        deal(card)
                                    }
                                }
                            }
                            }
                        }
                    }
            }
        }
        .foregroundColor(CardConstants.cardColor)
    }
    
    var gameDeck: some View{
        let player1 = game.players[0]
        return ZStack{
            ForEach(game.allCards.filter(isUndealt)){ card in
                CardView(card: card, isFaceUp: true)
                    .matchedGeometryEffect(id: card.id, in: dealingNameSpace)
            }
        }
        .frame(width: CardConstants.undealtWidth, height: CardConstants.undealtHeight)
        .foregroundColor(CardConstants.cardColor)
        .onTapGesture {
            var filteredList = game.displayedCards.filter(isUndealt)
            if game.displayedCards.containAllCards(Array(dealt)){
                game.dealThreeCards(by: player1)
                filteredList = game.displayedCards.filter(isUndealt)
            }
            
            for card in filteredList{
                if filteredList.count == 12{
                    withAnimation(dealAnimation(at: card,
                                                duration: CardConstants.totalDealDuration,
                                                range: game.displayedCards.count,
                                                from: filteredList)){
                        deal(card)
                    }
                } else {
                    withAnimation(dealAnimation(at: card,
                                                duration: CardConstants.totalDealDuration - 1.6,
                                                range: 3,
                                                from: filteredList)){
                        deal(card)
                    }
                }
            }
        }
    }
    
    var discardDeck: some View{
        ZStack{
            ForEach(matched){ card in
                CardView(card: card, isFaceUp: false)
                    .matchedGeometryEffect(id: card.id.hashValue, in: matchNameSpace)
            }
        }
        .frame(width: CardConstants.undealtWidth, height: CardConstants.undealtHeight)
        .foregroundColor(CardConstants.cardColor)
    }
    
    private func match(_ card: SetGame.card) {
        if card.state == .isInSet{
            matched.append(card)
        }
    }
    
    private func deal(_ card: SetGame.card) {
        dealt.insert(card.id)
    }
    
    private func zIndex(of card: SetGame.card) -> Double {
        -Double(game.allCards.firstIndex(where: {$0.id == card.id}) ?? 0)
    }
    
    private func isUndealt(_ card: SetGame.card) -> Bool{
        !dealt.contains(card.id)
    }
    
    private func dealAnimation(at card: SetGame.card, duration: Double, range: Int, from list: Array<SetGame.card>) -> Animation {
        var delay = 0.0
        if let index = list.firstIndex(where: { $0.id == card.id }){
            delay = Double(index) * (duration / Double(range))
        }
        print("delay: \(delay)")
        return Animation.easeInOut(duration: CardConstants.dealDuration).delay(delay)
    }
}

private struct CardConstants {
    static let cardColor: Color = .teal
    static let aspectRatio: CGFloat = 2/3
    static let dealDuration: Double = 0.25
    static let totalDealDuration: Double = 2
    static let undealtHeight: CGFloat = 90
    static let undealtWidth = undealtHeight * aspectRatio
}

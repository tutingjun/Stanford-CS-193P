//
//  SetGameView.swift
//  Set
//
//  Created by 涂庭鋆 on 2022/9/1.
//
//
//import SwiftUI
//
//struct SetGameView: View {
//    var game: SetViewModel
//    var gameMulti: SetViewModel
//    
//    @State private var activeTab: Int = 1
//    
//    init(game: SetViewModel, gameMulti: SetViewModel) {
//        let appearance = UITabBarAppearance()
//        appearance.configureWithOpaqueBackground()
//        if #available(iOS 15.0, *) {
//            UITabBar.appearance().scrollEdgeAppearance = appearance
//        }
//        self.game = game
//        self.gameMulti = gameMulti
//    }
//    
////    var body: some View {
//////        TabView(selection: $activeTab){
//////            onePlayerView(game)
//////                .tabItem{
//////                    Image(systemName: "person.fill")
//////                    Text("One player")
//////                }
//////                .tag(1)
//////
//////            twoPlayerView(gameMulti)
//////                .tabItem{
//////                    Image(systemName: "person.2.fill")
//////                    Text("Two players")
//////                }
//////                .tag(2)
//////        }
//////        .onChange(of: activeTab){ _ in
//////            if activeTab == 1{
//////                game.newGame()
//////            } else {
//////                gameMulti.newGame()
//////            }
//////        }
//    
//    }
//
//}
//
//struct onePlayerView: View{
//    @ObservedObject var game: SetViewModel
//    @Namespace private var dealingNameSpace
//    
//    @State private var dealt = Set<UUID>()
//    var player1: Player.singlePlayer
//    
//    init(_ game: SetViewModel){
//        self.game = game
//        self.player1 = game.players[0]
//    }
//    
//    var body: some View{
//        ZStack(alignment: .bottom){
//            gameBody
//            gameDeck
//                .padding(.bottom)
//        }
//    }
//    
//    var gameBody: some View{
//        VStack{
//            Text("Set Game!")
//                .font(.largeTitle)
//                .fontWeight(.bold)
//                .padding(.vertical)
//            
//            score(player1.score)
//            
//            cardBody
//            
//            HStack{
//                gameButton("New Game", color: .blue){
//                    withAnimation{
//                        game.newGame()
//                    }
//                }
//                Spacer()
//                gameButton("Hint", color: game.hasCheat ? Color.yellow : Color.gray){
//                    print(player1)
//                    game.hint(by: player1)
//                }
//            }
//        }
//        .padding([.leading, .bottom, .trailing])
//    }
//    
//    var cardBody: some View{
//        AspectVGrid(items: game.displayedCards, aspectRatio: 2/3, isMiddle: false) { item in
//            if isUndealt(item) {
//                Rectangle().strokeBorder()
//            } else {
//                CardView(card: item)
//                    .matchedGeometryEffect(id: item.id, in: dealingNameSpace)
//                    .padding(4)
//                    .zIndex(zIndex(of: item))
//                    .onTapGesture {
//                        withAnimation{
//                            game.choose(item)
//                        }
//                    }
//            }
//        }
//        .foregroundColor(CardConstants.cardColor)
//    }
//    
//    var gameDeck: some View{
//        ZStack{
//            ForEach(game.deck.filter(isUndealt)){ card in
//                CardView(card: card)
//                    .matchedGeometryEffect(id: card.id, in: dealingNameSpace)
//            }
//        }
//        .frame(width: CardConstants.undealtWidth, height: CardConstants.undealtHeight)
//        .foregroundColor(CardConstants.cardColor)
//        .onTapGesture {
//            for card in game.displayedCards{
//                withAnimation(dealAnimation(at: card)){
//                    deal(card)
//                }
//            }
//        }
//    }
//    
//    private func deal(_ card: SetGame.card) {
//        dealt.insert(card.id)
//    }
//    
//    private func zIndex(of card: SetGame.card) -> Double {
//        -Double(game.deck.firstIndex(where: {$0.id == card.id}) ?? 0)
//    }
//    
//    private func isUndealt(_ card: SetGame.card) -> Bool{
//        !dealt.contains(card.id)
//    }
//    
//    private func dealAnimation(at card: SetGame.card) -> Animation {
//        var delay = 0.0
//        if let index = game.displayedCards.firstIndex(where: { $0.id == card.id }){
//            delay = Double(index) * (CardConstants.totalDealDuration / Double(game.displayedCards.count))
//        }
//        return Animation.easeInOut(duration: CardConstants.dealDuration).delay(delay)
//    }
//    
//}
//
//struct twoPlayerView: View{
//    var game: SetViewModel
//    let player1: Player.singlePlayer
//    let player2: Player.singlePlayer
//
//    init(_ game: SetViewModel){
//        self.game = game
//        self.player1 = game.players[0]
//        self.player2 = game.players[1]
//    }
//
//    var body: some View{
//        VStack{
//            HStack{
//                gameButton("Choose", color: game.canSelect ? .blue:.gray){
//                    game.playerChoose(by: player1)
//                }
//                Spacer()
//                gameButton("Hint", color: game.hasCheat ? Color.yellow : Color.gray){
//                    game.hint(by: player1)
//                }
//                Spacer()
//                gameButton("Deal 3 More", color: game.deckCount == 0 ? Color.gray : Color.blue){
//                }
//            }
//            .rotationEffect(.degrees(180))
//
//            score(player1.score)
//                .rotationEffect(.degrees(180))
//
//            AspectVGrid(items: game.displayedCards, aspectRatio: 2/3, isMiddle: true) { item in
//                CardView(card: item)
//                    .padding(4)
//                    .onTapGesture {
//                        game.choose(item)
//                    }
//            }
//            .foregroundColor(Color.teal)
//
//            score(player2.score)
//
//            HStack{
//                gameButton("Choose", color: game.canSelect ? .blue:.gray){
//                    game.playerChoose(by: player2)
//                }
//                Spacer()
//                gameButton("Hint", color: game.hasCheat ? Color.yellow : Color.gray){
//                    game.hint(by: player2)
//                }
//                Spacer()
//                gameButton("Deal 3 More", color: game.deckCount == 0 ? Color.gray : Color.blue){
//
//                }
//            }
//        }
//        .padding([.leading, .bottom, .trailing])
//    }
//}
//
//private struct CardConstants {
//    static let cardColor: Color = .teal
//    static let aspectRatio: CGFloat = 2/3
//    static let dealDuration: Double = 0.5
//    static let totalDealDuration: Double = 2
//    static let undealtHeight: CGFloat = 90
//    static let undealtWidth = undealtHeight * aspectRatio
//}
//
//
//
//
//
//
//
//
//
//
//
//
//
//struct SetGameView_Previews: PreviewProvider {
//    static var previews: some View {
//        let game = SetViewModel(isMultiplayer: true)
//        
//        let gameNew = SetViewModel(isMultiplayer: false)
//        SetGameView(game: gameNew, gameMulti: game)
//            
//    }
//}

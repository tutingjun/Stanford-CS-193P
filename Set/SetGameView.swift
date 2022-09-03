//
//  SetGameView.swift
//  Set
//
//  Created by 涂庭鋆 on 2022/9/1.
//

import SwiftUI

struct SetGameView: View {
    @ObservedObject var game: SetViewModel
    @ObservedObject var gameMulti: SetViewModel
    
    @State private var activeTab: Int = 1
    
    init(game: SetViewModel, gameMulti: SetViewModel) {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
        self.game = game
        self.gameMulti = gameMulti
    }
    
    var body: some View {
        TabView(selection: $activeTab){
            onePlayer(game)
                .tabItem{
                    Image(systemName: "person.fill")
                    Text("One player")
                }
                .tag(1)

            twoPlayer(gameMulti)
                .tabItem{
                    Image(systemName: "person.2.fill")
                    Text("Two players")
                }
                .tag(2)
        }
        .onChange(of: activeTab){ _ in
            if activeTab == 1{
                game.newGame()
            } else {
                gameMulti.newGame()
            }
        }
    
    }
    
    @ViewBuilder
    private func twoPlayer(_ game: SetViewModel) -> some View{
        let player1 = game.players[0]
        let player2 = game.players[1]
        VStack{
            HStack{
                button("Choose", color: game.canSelect ? .blue:.gray){
                    game.playerChoose(by: player1)
                }
                Spacer()
                button("Hint", color: game.hasCheat ? Color.yellow : Color.gray){
                    game.hint(by: player1)
                }
                Spacer()
                button("Deal 3 More", color: game.deckCount == 0 ? Color.gray : Color.blue){
                    game.dealThreeMore(by: player1)
                }
            }
            .rotationEffect(.degrees(180))
            
            score(player1.score)
                .rotationEffect(.degrees(180))
            
            AspectVGrid(items: game.displayedCards, aspectRatio: 2/3, isMiddle: true) { item in
                CardView(card: item)
                    .padding(4)
                    .onTapGesture {
                        game.choose(item)
                    }
            }
            .foregroundColor(Color.teal)
            
            score(player2.score)
            
            HStack{
                button("Choose", color: game.canSelect ? .blue:.gray){
                    game.playerChoose(by: player2)
                }
                Spacer()
                button("Hint", color: game.hasCheat ? Color.yellow : Color.gray){
                    game.hint(by: player2)
                }
                Spacer()
                button("Deal 3 More", color: game.deckCount == 0 ? Color.gray : Color.blue){
                    game.dealThreeMore(by: player2)
                }
            }
        }
        .padding([.leading, .bottom, .trailing])
    }
    
    @ViewBuilder
    private func onePlayer(_ game: SetViewModel) -> some View{
        let player1 = game.players[0]
        
        VStack{
            Text("Set Game!")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.vertical)
            
            score(player1.score)
            
            AspectVGrid(items: game.displayedCards, aspectRatio: 2/3, isMiddle: false) { item in
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
                    game.hint(by: player1)
                }
                Spacer()
                button("Deal 3 More", color: game.deckCount == 0 ? Color.gray : Color.blue){
                    game.dealThreeMore(by: player1)
                }
            }
        }
        .padding([.leading, .bottom, .trailing])
    }
    
    @ViewBuilder
    private func score(_ score: Int) -> some View{
        HStack{
            Text("Score")
                .font(.title3)
                .fontWeight(.semibold)
            Spacer()
            Text("\(score)")
                .fontWeight(.semibold)
        }
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
}

struct SetGameView_Previews: PreviewProvider {
    static var previews: some View {
        let game = SetViewModel(isMultiplayer: true)
        
        let gameNew = SetViewModel(isMultiplayer: false)
        SetGameView(game: gameNew, gameMulti: game)
            
    }
}

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
    @State var emojis = ["🚌", "🚇", "🚋", "🚁", "🛳", "⛵️", "🛴", "🚠", "🚀", "🛵", "🛰", "🚂", "⛴"]
    @State var emojiCount = Int.random(in: 4...13)
    @State var bottonSelected = 1
    
    var body: some View {
        VStack{
            Text("Memorize!")
                .font(.largeTitle)
                .padding()
            ScrollView{
                LazyVGrid(columns: [GridItem(.adaptive(minimum: widthThatBestFits(cardCount: emojiCount)))]){
                    ForEach(emojis[0..<emojiCount],id: \.self) {emoji in
                        CardView(content: emoji)
                            .aspectRatio(2/3, contentMode: .fit)
                    }
                }
            }
            .foregroundColor(.orange)
            Spacer()
            HStack{
                Spacer()
                car
                Spacer()
                animal
                Spacer()
                food
                Spacer()
            }
            .font(.largeTitle)
            .padding(.horizontal)
        }
        .padding(.horizontal)
    }
    
    var car: some View{
        Button {
            emojis = ["🚌", "🚇", "🚋", "🚁", "🛳", "⛵️", "🛴", "🚠", "🚀", "🛵", "🛰", "🚂", "⛴"]
            bottonSelected = 1
            emojis.shuffle()
            emojiCount = Int.random(in: 4...emojis.count)
        } label: {
            VStack{
                Image(systemName: "car")
                Text("Cars")
                    .font(.subheadline)
            }
            .foregroundColor(bottonSelected == 1 ? .blue: .gray)
            
        }
    }
    
    var animal: some View{
        Button{
            emojis = ["🐵", "🐼", "🐙", "🐔", "🦅", "🐢", "🐷", "🐟", "🦐", "🐳", "🦒", "🐝", "🐊"]
            bottonSelected = 2
            emojis.shuffle()
            emojiCount = Int.random(in: 4...emojis.count)
        } label: {
            VStack{
                Image(systemName: "pawprint")
                Text("Animals")
                    .font(.subheadline)
            }
            .foregroundColor(bottonSelected == 2 ? .blue: .gray)
            
        }
    }
    
    var food: some View{
        Button{
            emojis = ["🍔", "🍕", "🌭", "🌮", "🌶", "🌯", "🥟", "🍙", "🍚", "🍝", "🥖", "🍤"]
            bottonSelected = 3
            emojis.shuffle()
            emojiCount = Int.random(in: 4...emojis.count)
        } label: {
            VStack{
                Image(systemName: "takeoutbag.and.cup.and.straw")
                Text("Foods")
                    .font(.subheadline)
            }
            .foregroundColor(bottonSelected == 3 ? .blue: .gray)
            
        }
    }
}

struct CardView: View{
    var content: String
    @State var isFaceUp: Bool = true
    
    var body: some View{
        ZStack(alignment: .center) {
            let shape = RoundedRectangle(cornerRadius: 20)
            if isFaceUp{
                shape.fill().foregroundColor(.white)
                shape.strokeBorder(lineWidth: 3)
                Text(content).font(.largeTitle)
            } else {
                shape.fill()
            }
        }
        .onTapGesture {
            isFaceUp =  !isFaceUp
        }
        .onAppear{
            isFaceUp = true
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.dark)
        ContentView()
            .preferredColorScheme(.light)
    }
}

//
//  AspectVGrid.swift
//  Set
//
//  Created by 涂庭鋆 on 2022/9/1.
//

import SwiftUI

struct AspectVGrid<Item, ItemView>: View  where ItemView: View, Item: Identifiable {
    var isMiddle: Bool
    var items: [Item]
    var aspectRatio: CGFloat
    var content: (Item) -> ItemView
    
    init(items: [Item], aspectRatio: CGFloat, isMiddle: Bool, @ViewBuilder content: @escaping (Item) -> ItemView){
        self.items = items
        self.aspectRatio = aspectRatio
        self.content = content
        self.isMiddle = isMiddle
    }
    
    var body: some View {
        GeometryReader{ geometry in
            VStack{
                if isMiddle{
                    Spacer()
                    cardGrid(items: items, aspectRatio: aspectRatio, size: geometry.size, content: content)
                    Spacer()
                } else {
                    cardGrid(items: items, aspectRatio: aspectRatio, size: geometry.size, content: content)
                    Spacer(minLength: 0)
                }
            }
           
        }
    }
    
    @ViewBuilder
    private func cardGrid(items: [Item], aspectRatio: CGFloat, size: CGSize, @ViewBuilder content: @escaping (Item) -> ItemView) -> some View where ItemView: View, Item: Identifiable {
        let width: CGFloat = widthThatFits(itemCount: items.count, in: size, itemAspectRatio: aspectRatio)
        LazyVGrid(columns: [adaptiveGridCount(width: width)], spacing: 0) {
            ForEach(items) { item in
                content(item).aspectRatio(aspectRatio,contentMode: .fit)
            }
        }
    }
    
    private func adaptiveGridCount(width: CGFloat) -> GridItem{
        var gridItem = GridItem(.adaptive(minimum: width))
        gridItem.spacing = 0
        return gridItem
    }
    
    private func widthThatFits(itemCount: Int, in size: CGSize, itemAspectRatio: CGFloat) -> CGFloat {
        var colCount = 1
        var rowCount = itemCount
        
        repeat {
            let itemWidth = size.width / CGFloat(colCount)
            let itemHeight = itemWidth / itemAspectRatio
            if CGFloat(rowCount) * itemHeight < size.height {
                break
            }
            colCount += 1
            rowCount = (itemCount + (colCount - 1)) / colCount // prevent underflow, case as: 10 cards 3 col
        } while colCount < itemCount
        
        if colCount > itemCount{
            colCount = itemCount
        }
        return floor(size.width / CGFloat(colCount))
    }
}

struct gameButton: View{
    var content: String
    var color: Color
    var actionToDo: () -> Void
    
    init(_ content: String, color: Color, actionToDo: @escaping () -> Void){
        self.content = content
        self.color = color
        self.actionToDo = actionToDo
    }
    
    var body: some View{
        Button(action: {
            actionToDo()
        }, label: {
            Text(content)
        })
        .padding()
        .font(.headline)
        .foregroundColor(.white
        )
        .background(color)
        .clipShape(RoundedRectangle(cornerRadius: 15))
    }
}

struct score: View{
    var score: Int
    
    init(_ score: Int){
        self.score = score
    }
    
    var body: some View{
        HStack{
            Text("Score")
                .font(.title3)
                .fontWeight(.semibold)
            Spacer()
            Text("\(score)")
                .fontWeight(.semibold)
        }
    }
}

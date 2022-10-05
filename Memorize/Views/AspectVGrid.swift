//
//  AspectVGrid.swift
//  Memorize
//
//  Created by 涂庭鋆 on 2022/8/31.
//

import SwiftUI

struct AspectVGrid<Item, ItemView>: View  where ItemView: View, Item: Identifiable {
    var items: [Item]
    var aspectRatio: CGFloat
    var content: (Item) -> ItemView
    
    init(items: [Item], aspectRatio: CGFloat, @ViewBuilder content: @escaping (Item) -> ItemView){
        self.items = items
        self.aspectRatio = aspectRatio
        self.content = content
    }
    
    var body: some View {
        GeometryReader{ geometry in
            VStack{
                let width: CGFloat = widthThatFits(itemCount: items.count, in: geometry.size, itemAspectRatio: aspectRatio)
                LazyVGrid(columns: [adaptiveGridCount(width: width)], spacing: 0) {
                    ForEach(items) { item in
                        content(item).aspectRatio(aspectRatio,contentMode: .fit)
                    }
                }
                Spacer(minLength: 0)
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

//struct AspectVGrid_Previews: PreviewProvider {
//    static var previews: some View {
//        AspectVGrid()
//    }
//}

//
//  CardView.swift
//  Set
//
//  Created by 涂庭鋆 on 2022/9/1.
//

import SwiftUI


struct CardView: View {
    let card: SetGame.card
    
    var body: some View {
        GeometryReader{ geometry in
            ZStack(alignment: .center) {
                let shape = RoundedRectangle(cornerRadius: DrawingConstants.cornerRadius)
                shape.fill().foregroundColor(.white)

                switch card.state{
                case .isSelected:
                    shape.strokeBorder(lineWidth: DrawingConstants.lineWidth_emphasize).foregroundColor(.blue)
                case.isInSet:
                    shape.strokeBorder(lineWidth: DrawingConstants.lineWidth_emphasize).foregroundColor(.green)
                case .isNotInSet:
                    shape.strokeBorder(lineWidth: DrawingConstants.lineWidth_emphasize).foregroundColor(.red)
                default:
                    shape.strokeBorder(lineWidth: DrawingConstants.lineWidth)
                }
            
                cardStack(content: card.content, width: geometry.size.width)
            }
        }
    }
    
    @ViewBuilder
    private func cardStack(content: Dictionary<String, Any>, width: CGFloat) -> some View{
        let shape = content["shape"] as! SetGame.card.shape
        let color = content["color"] as! SetGame.card.color
        let shading = content["shading"] as! SetGame.card.shading
        let number = content["number"] as! SetGame.card.number
        let width = width * 2/3
        
        VStack{
            ForEach(0..<numOfPattern(number), id: \.self){_ in
                singleCardPattern(shape, color, shading, width: width)
                    .frame(width: width, height: width/2, alignment: .center)
//                    .padding()
            }
        }
    }
    
    @ViewBuilder
    private func singleCardPattern(_ shape: SetGame.card.shape, _ color: SetGame.card.color, _ shading: SetGame.card.shading, width: CGFloat) -> some View{
        switch shape{
        case.oval:
            addShading(content: RoundedRectangle(cornerRadius: 100), shading: shading)
                .foregroundColor(colorOfCard(color))
        case .squiggle:
            addShading(content: Rectangle(), shading: shading)
                .foregroundColor(colorOfCard(color))
        case .diamond:
            addShading(content: Diamond(width: width, height: width/2), shading: shading)
                .foregroundColor(colorOfCard(color))
        }
    }
    
    @ViewBuilder
    private func addShading<cardShape>(content: cardShape, shading: SetGame.card.shading) -> some View where cardShape: Shape{
        switch shading{
        case .solid:
            content.fill()
        case .striped:
            content.fill().opacity(DrawingConstants.opacity)
        case .open:
            content.stroke(lineWidth: DrawingConstants.lineWidth)
        }
    }
    
    private func numOfPattern(_ num: SetGame.card.number) -> Int {
        switch num{
        case .one:
            return 1
        case .two:
            return 2
        case .three:
            return 3
        }
    }
    
    private func colorOfCard(_ color: SetGame.card.color) -> Color{
        switch color {
        case.green:
            return .green
        case.orange:
            return .orange
        case .red:
            return .red
        }
    }
    
    private struct DrawingConstants {
        static let cornerRadius: CGFloat = 10
        static let lineWidth: CGFloat = 3
        static let lineWidth_emphasize: CGFloat = 5
        static let opacity: CGFloat = 0.4
    }
}

struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        CardView(card: SetGame.card(color: .red, shape: .diamond, shading: .striped, number: .three))
            .aspectRatio(2/3, contentMode: .fit)
    }
}

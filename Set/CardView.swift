//
//  CardView.swift
//  Set
//
//  Created by 涂庭鋆 on 2022/9/1.
//

import SwiftUI


struct CardView: View {
    let card: SetGame.card
    let isFaceUp: Bool
    
//    var body: some View{
//        if card.state == .isNotInSet{
//            cardBody
//                .rotationEffect(.degrees(3))
//                .animation(Animation.easeInOut.repeatForever(), value: card.state)
//        } else if card.state == .isInSet {
//            cardBody
//                .offset(x: 0, y: -10)
//                .animation(Animation.interactiveSpring(), value: card.state)
//        } else {
//            cardBody
//        }
//    }
    
    var body: some View {
        GeometryReader{ geometry in
            ZStack(alignment: .center) {
                let shape = RoundedRectangle(cornerRadius: DrawingConstants.cornerRadius)
                if isFaceUp{
                    shape.fill().foregroundColor(.teal)
                } else {
                    shape.fill().foregroundColor(.white)

                    switch card.state{
                    case .isSelected:
                        shape.strokeBorder(lineWidth: DrawingConstants.lineWidth_emphasize).foregroundColor(.blue)
                    case.isInSet:
                        shape.strokeBorder(lineWidth: DrawingConstants.lineWidth_emphasize).foregroundColor(.green)
                    case .isNotInSet:
                        shape.strokeBorder(lineWidth: DrawingConstants.lineWidth_emphasize).foregroundColor(.red)
                    case .hint:
                        shape.strokeBorder(lineWidth: DrawingConstants.lineWidth_emphasize).foregroundColor(.yellow)
                    default:
                        shape.strokeBorder(lineWidth: DrawingConstants.lineWidth)
                    }

                    cardStack(content: card.content, width: geometry.size.width)
                }
            }
            .rotationEffect(.degrees(card.state == .isNotInSet ? 3 : 0))
            .animation(Animation.easeInOut, value: card.state)
        }
    }
    
    @ViewBuilder
    private func cardStack(content: Dictionary<String, String>, width: CGFloat) -> some View{
        let shape = content["shape"]!
        let color = content["color"]!
        let shading = content["shading"]!
        let number = content["number"]!
        let width = max( width * 2/3, 0)
        
        VStack{
            ForEach(0..<numOfPattern(number), id: \.self){_ in
                singleCardPattern(shape, color, shading)
                    .frame(width: width, height: width/2, alignment: .center)
            }
        }
    }
    
    @ViewBuilder
    private func singleCardPattern(_ shape: String, _ color: String, _ shading: String) -> some View{
        switch shape{
        case "oval":
            addShading(content: RoundedRectangle(cornerRadius: 100), shading: shading, color: colorOfCard(color))
        case "squiggle":
            addShading(content: Squiggle(), shading: shading, color: colorOfCard(color))
        case "diamond":
            addShading(content: Diamond(), shading: shading, color: colorOfCard(color))
        default:
            Rectangle()
        }
    }
    
    @ViewBuilder
    private func addShading<cardShape>(content: cardShape, shading: String, color: Color) -> some View where cardShape: Shape{
        switch shading{
        case "solid":
            content
                .fill()
                .foregroundColor(color)
        case "striped":
            StripShading(shape: content, color: color)
        case "open":
            content
                .stroke(lineWidth: DrawingConstants.lineWidth)
                .foregroundColor(color)
        default:
            content
                .foregroundColor(color)
        }
    }
    
    private func numOfPattern(_ num: String) -> Int {
        switch num{
        case "one":
            return 1
        case "two":
            return 2
        case "three":
            return 3
        default:
            print("error")
            return 0
        }
    }
    
    private func colorOfCard(_ color: String) -> Color{
        switch color {
        case "green":
            return .green
        case "purple":
            return .purple
        case "red":
            return .red
        default:
            print("error")
            return .white
        }
    }
    
    private struct DrawingConstants {
        static let cornerRadius: CGFloat = 10
        static let lineWidth: CGFloat = 3
        static let lineWidth_emphasize: CGFloat = 5
    }
}

struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        CardView(card: SetGame.card(color: .red, shape: .diamond, shading: .open, number: .one), isFaceUp: true)
            .aspectRatio(2/3, contentMode: .fit)
    }
}

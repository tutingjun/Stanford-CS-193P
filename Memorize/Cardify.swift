//
//  Cardify.swift
//  Memorize
//
//  Created by 涂庭鋆 on 2022/9/3.
//

import SwiftUI

struct Cardify: AnimatableModifier {
    var rotation: Double
    var animatableData: Double {
        get { rotation }
        set { rotation =  newValue }
    }
    
    init(isFaceUp: Bool){
        rotation = isFaceUp ? 0 : 180
    }
    
    func body(content: Content) -> some View {
        ZStack(alignment: .center) {
            let shape = RoundedRectangle(cornerRadius: DrawingConstants.cornerRadius)
            if rotation < 90{
                shape.fill().foregroundColor(.white)
                shape.strokeBorder(lineWidth: DrawingConstants.lineWidth)
            } else {
                shape.fill()
            }
            content
                .opacity(rotation < 90 ? 1 : 0)
        }
        .rotation3DEffect(Angle.degrees(rotation), axis: (0,1,0))
    }
    
   private struct DrawingConstants {
       static let cornerRadius: CGFloat = 10
       static let lineWidth: CGFloat = 3
   }
}

extension  View{
    func cardify(isFaceUp: Bool) -> some View {
        self.modifier(Cardify(isFaceUp: isFaceUp))
    }
}



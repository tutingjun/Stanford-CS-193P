//
//  AnimatableFontSize.swift
//  EmojiArt
//
//  Created by 涂庭鋆 on 2022/9/7.
//

import SwiftUI

struct AnimatableFontSize: AnimatableModifier{
    var size: CGFloat
    var animatableData: Double {
        get { size }
        set { size =  newValue }
    }
    
    func body(content: Content) -> some View {
        content.font(.system(size: size))
    }
}


extension View{
    func animatableFontSize(size: CGFloat) -> some View {
        self.modifier(AnimatableFontSize(size: size))
    }
}

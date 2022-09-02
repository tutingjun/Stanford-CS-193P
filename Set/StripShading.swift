//
//  StripShading.swift
//  Set
//
//  Created by 涂庭鋆 on 2022/9/2.
//

import SwiftUI

struct StripShading<SymbolShape>: View where SymbolShape:Shape {
    let shape: SymbolShape
    let color: Color
    
    var body: some View {
        HStack(spacing: 0.5){
            ForEach(0..<16){_ in
                color
                Color.white
            }
        }
        .mask(shape)
        .overlay(shape.stroke(color, lineWidth: 2))
    }
}

struct StripShading_Previews: PreviewProvider {
    static var previews: some View {
        StripShading(shape: Diamond(), color: .blue)
    }
}

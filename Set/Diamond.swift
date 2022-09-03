//
//  Diamond.swift
//  Set
//
//  Created by 涂庭鋆 on 2022/9/1.
//

import SwiftUI

struct Diamond: Shape{
//    var width: CGFloat
//    var height: CGFloat
    func path(in rect: CGRect) -> Path {
        let width = rect.size.width
        let height = rect.size.height
        
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let start = CGPoint(
            x: center.x,
            y: center.y - height/2
        )
        let left = CGPoint(
            x: center.x - width/2,
            y: center.y
        )
        let button = CGPoint(
            x: start.x,
            y: start.y + height
        )
        let right = CGPoint(
            x: left.x + width,
            y: left.y
        )
        let end = CGPoint(
            x: start.x-1,
            y: start.y
        )
        
        let coordinate = [start, left, button, right, end]
        
        var p = Path()
        p.move(to: start)
        p.addLines(coordinate)
        
        return p
    }
    
    
}

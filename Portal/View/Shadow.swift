//
//  Shadow.swift
//  Portal
//
//  Created by Cristian Ames on 7/11/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//
import UIKit

public struct Shadow {
    
    public var color: Color
    public var opacity: Float
    public var offset: Offset
    public var radius: Float
    public var shouldRasterize: Bool
    
    public init(
        color: Color = .clear,
        opacity: Float = 0,
        offset: Offset = Offset(),
        radius: Float = 0,
        shouldRasterize: Bool = true
        ) {
        self.color = color
        self.opacity = opacity
        self.offset = offset
        self.radius = radius
        self.shouldRasterize = shouldRasterize
    }
    
}

public struct Offset {
    
    public var posX: Float
    public var posY: Float
    
    internal var asCGSize: CGSize {
        return CGSize(width: CGFloat(posX), height: CGFloat(posY))
    }
    
    public init(posX: Float = 0, posY: Float = 0) {
        self.posX = posX
        self.posY = posY
    }
}

public func shadow(configure: (inout Shadow) -> Void = { _ in }) -> Shadow {
    var base = Shadow()
    configure(&base)
    return base
}

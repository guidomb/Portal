//
//  Shadow.swift
//  Portal
//
//  Created by Cristian Ames on 7/11/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//

public struct Shadow: AutoPropertyDiffable, AutoEquatable {
    
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

// swiftlint:disable identifier_name
public struct Offset: AutoEquatable {
    
    public var x: Float
    public var y: Float
    
    public init(x: Float = 0, y: Float = 0) {
        self.x = x
        self.y = y
    }
}

public func shadow(configure: (inout Shadow) -> Void = { _ in }) -> Shadow {
    var base = Shadow()
    configure(&base)
    return base
}

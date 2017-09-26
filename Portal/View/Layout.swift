//
//  Layout.swift
//  Portal
//
//  Created by Guido Marucci Blas on 12/10/16.
//  Copyright © 2016 Guido Marucci Blas. All rights reserved.
//

import Foundation

public enum FlexDirection {

    case column
    case row
    case columnReverse
    case rowReverse

}

public enum JustifyContent {

    case flexStart
    case flexEnd
    case center
    case spaceBetween
    case spaceAround

}

public enum FlexWrap {

    case nowrap
    case wrap

}

public enum AlignItems {

    case stretch
    case flexStart
    case flexEnd
    case center

}

public enum AlignSelf {

    case stretch
    case flexStart
    case flexEnd
    case center

}

public enum AlignContent {

    case flexStart
    case flexEnd
    case center
    case stretch
    case spaceAround

}

public enum Margin: AutoEquatable {
    
    case all(value: UInt)
    case by(edge: Edge) // swiftlint:disable:this identifier_name
    
}

public enum Border: AutoEquatable {
    
    case all(value: UInt)
    case by(edge: Edge) // swiftlint:disable:this identifier_name
    
}

public enum Padding: AutoEquatable {
    
    case all(value: UInt)
    case by(edge: Edge) // swiftlint:disable:this identifier_name
    
}

public enum Direction {
    
    case inherit
    case leftToRight
    case rightToLeft
    
}

public struct Edge: AutoEquatable {

    public var left: UInt?
    public var top: UInt?
    public var right: UInt?
    public var bottom: UInt?
    public var start: UInt?
    public var end: UInt?
    public var horizontal: UInt?
    public var vertical: UInt?
    
    public init(
        left: UInt? = .none,
        top: UInt? = .none,
        right: UInt? = .none,
        bottom: UInt? = .none,
        start: UInt? = .none,
        end: UInt? = .none,
        horizontal: UInt? = .none,
        vertical: UInt? = .none
    ) {
        self.left = left
        self.top = top
        self.right = right
        self.bottom = bottom
        self.start = start
        self.end = end
        self.start = start
        self.end = end
        self.horizontal = horizontal
        self.vertical = vertical
    }

}

public enum Position: AutoEquatable {

    case relative
    case absolute(forEdge: Edge)

}

public struct Alignment: AutoPropertyDiffable {

    public var content: AlignContent
    public var `self`: AlignSelf?
    public var items: AlignItems
    
    public init(
        content: AlignContent = .flexStart,
        `self` alignSelf: AlignSelf? = .none,
        items: AlignItems = .stretch) {
        self.content = content
        self.`self` = alignSelf
        self.items = items
    }

}

public struct FlexValue: RawRepresentable, AutoEquatable {

    public var rawValue: Double

    public static var zero = FlexValue(rawValue: 0)!
    public static var one = FlexValue(rawValue: 1)!
    public static var two = FlexValue(rawValue: 2)!
    public static var three = FlexValue(rawValue: 3)!
    public static var four = FlexValue(rawValue: 4)!
    public static var five = FlexValue(rawValue: 5)!
    public static var six = FlexValue(rawValue: 6)!
    public static var seven = FlexValue(rawValue: 7)!
    public static var eight = FlexValue(rawValue: 8)!
    public static var nine = FlexValue(rawValue: 9)!
    public static var ten = FlexValue(rawValue: 10)!

    public init?(rawValue: Double) {
        guard rawValue >= 0 else { return nil }
        self.rawValue = rawValue
    }

}

public struct Flex: AutoPropertyDiffable {

    public var direction: FlexDirection
    public var grow: FlexValue
    public var shrink: FlexValue
    public var wrap: FlexWrap
    public var basis: UInt?
    
    public init(
        direction: FlexDirection = .column,
        grow: FlexValue = .zero,
        shrink: FlexValue = .zero,
        wrap: FlexWrap = .nowrap,
        basis: UInt? = .none) {
        
        self.direction = direction
        self.grow = grow
        self.shrink = shrink
        self.wrap = wrap
        self.basis = basis
    }

}

public struct Dimension: AutoPropertyDiffable {

    public var minimum: UInt?
    public var maximum: UInt?
    public var value: UInt?
    
    public init(value: UInt? = .none, minimum: UInt? = .none, maximum: UInt? = .none) {
        self.value = value
        self.minimum = minimum
        self.maximum = maximum
    }
    
}

public struct AspectRatio: RawRepresentable, AutoEquatable {

    public var rawValue: Double

    public init?(rawValue: Double) {
        guard rawValue > 0 else { return nil }
        self.rawValue = rawValue
    }

}

public struct Layout: AutoPropertyDiffable {

    public var flex: Flex
    public var justifyContent: JustifyContent
    public var width: Dimension?
    public var height: Dimension?
    public var alignment: Alignment
    public var position: Position
    public var margin: Margin?
    public var padding: Padding?
    public var border: Border?
    public var aspectRatio: AspectRatio?
    public var direction: Direction

    fileprivate init(
        flex: Flex = Flex(),
        justifyContent: JustifyContent = .flexStart,
        width: Dimension? = .none,
        height: Dimension? = .none,
        alignment: Alignment = Alignment(),
        position: Position = .relative,
        margin: Margin? = .none,
        padding: Padding? = .none,
        border: Border? = .none,
        aspectRatio: AspectRatio? = .none,
        direction: Direction = .inherit
    ) {
      self.flex = flex
      self.justifyContent = justifyContent
      self.width = width
      self.height = height
      self.alignment = alignment
      self.position = position
      self.margin = margin
      self.padding = padding
      self.border = border
      self.aspectRatio = aspectRatio
      self.direction = direction
    }

}

public func layout(configure: (inout Layout) -> Void = { _ in }) -> Layout {
    var object = Layout()
    configure(&object)
    return object
}

public func flex(configure: (inout Flex) -> Void = { _ in }) -> Flex {
    var object = Flex()
    configure(&object)
    return object
}

public func dimension(configure: (inout Dimension) -> Void = { _ in }) -> Dimension {
    var object = Dimension()
    configure(&object)
    return object
}

public func alignment(configure: (inout Alignment) -> Void = { _ in }) -> Alignment {
    var object = Alignment()
    configure(&object)
    return object
}

public func edge(configure: (inout Edge) -> Void = { _ in }) -> Edge {
    var object = Edge()
    configure(&object)
    return object
}

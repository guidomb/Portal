//
//  LayoutEngine.swift
//  Portal
//
//  Created by Guido Marucci Blas on 12/11/16.
//  Copyright © 2016 Guido Marucci Blas. All rights reserved.
//
import UIKit

public protocol LayoutEngine {

    func layout(view: UIView, inside container: UIView)

    func apply(layout: Layout, to view: UIView)

}

internal struct YogaLayoutEngine : LayoutEngine {

    func layout(view: UIView, inside container: UIView) {
        container.yoga.isEnabled = true
        container.yoga.width = container.bounds.size.width
        container.yoga.height = container.bounds.size.height
        container.addSubview(view)
        container.yoga.applyLayout(preservingOrigin: true)
    }

    func apply(layout: Layout, to view: UIView) {
        view.yoga.isEnabled = true

        apply(flex: layout.flex, to: view)
        apply(justifyContent: layout.justifyContent, to: view)
        apply(alignment: layout.alignment, to: view)
        apply(position: layout.position, to: view)
        apply(direction: layout.direction, to: view)

        layout.width        |> { apply(width: $0, to: view) }
        layout.height       |> { apply(height: $0, to: view) }
        layout.margin       |> { apply(margin: $0, to: view) }
        layout.padding      |> { apply(padding: $0, to: view) }
        layout.border       |> { apply(border: $0, to: view) }
        layout.aspectRatio  |> { apply(aspectRation: $0, to: view) }
    }

}

fileprivate extension YogaLayoutEngine {

    fileprivate func apply(flex: Flex, to view: UIView) {
        view.yoga.flexDirection = flex.direction.yg_flexDirection
        view.yoga.flexGrow = CGFloat(flex.grow.rawValue)
        view.yoga.flexShrink = CGFloat(flex.shrink.rawValue)
        view.yoga.flexWrap = flex.wrap.yg_flexWrap
        flex.basis |> { view.yoga.flexBasis = CGFloat($0) }
    }

    fileprivate func apply(justifyContent: JustifyContent, to view: UIView) {
        view.yoga.justifyContent = justifyContent.yg_justifyContent
    }

    fileprivate func apply(width: Dimension, to view: UIView) {
        width.value     |> { view.yoga.width = CGFloat($0) }
        width.minimum   |> { view.yoga.minWidth = CGFloat($0) }
        width.maximum   |> { view.yoga.maxWidth = CGFloat($0) }
    }

    fileprivate func apply(height: Dimension, to view: UIView) {
        height.value    |> { view.yoga.height = CGFloat($0) }
        height.minimum  |> { view.yoga.minHeight = CGFloat($0) }
        height.maximum  |> { view.yoga.maxHeight = CGFloat($0) }
    }

    fileprivate func apply(alignment: Alignment, to view: UIView) {
        view.yoga.alignContent = alignment.content.yg_alignContent
        view.yoga.alignItems = alignment.items.yg_alignItems
        alignment.`self` |> { view.yoga.alignSelf = $0.yg_alignSelf }
    }

    fileprivate func apply(position: Position, to view: UIView) {
        switch position {

        case .absolute(let edge):
            view.yoga.position = .absolute
            edge.left       |> { view.yoga.left = CGFloat($0) }
            edge.right      |> { view.yoga.right = CGFloat($0) }
            edge.top        |> { view.yoga.top = CGFloat($0) }
            edge.bottom     |> { view.yoga.bottom = CGFloat($0) }
            edge.start      |> { view.yoga.start = CGFloat($0) }
            edge.end        |> { view.yoga.end = CGFloat($0) }
            
            // TODO review why this properties are missing
            // edge.horizontal |> { view.yoga.horizontal = CGFloat($0) }
            // edge.vertical   |> { view.yoga.vertical = CGFloat($0) }

        case .relative:
            view.yoga.position = .relative
        }
    }

    fileprivate func apply(margin: Margin, to view: UIView) {
        switch margin {

        case .all(let value):
            view.yoga.margin = CGFloat(value)

        case .by(let edge):
            edge.left       |> { view.yoga.marginLeft = CGFloat($0) }
            edge.right      |> { view.yoga.marginRight = CGFloat($0) }
            edge.top        |> { view.yoga.marginTop = CGFloat($0) }
            edge.bottom     |> { view.yoga.marginBottom = CGFloat($0) }
            edge.start      |> { view.yoga.marginStart = CGFloat($0) }
            edge.end        |> { view.yoga.marginEnd = CGFloat($0) }
            edge.horizontal |> { view.yoga.marginHorizontal = CGFloat($0) }
            edge.vertical   |> { view.yoga.marginVertical = CGFloat($0) }

        }
    }

    fileprivate func apply(padding: Padding, to view: UIView) {
        switch padding {

        case .all(let value):
            view.yoga.padding = CGFloat(value)

        case .by(let edge):
            edge.left       |> { view.yoga.paddingLeft = CGFloat($0) }
            edge.right      |> { view.yoga.paddingRight = CGFloat($0) }
            edge.top        |> { view.yoga.paddingTop = CGFloat($0) }
            edge.bottom     |> { view.yoga.paddingBottom = CGFloat($0) }
            edge.start      |> { view.yoga.paddingStart = CGFloat($0) }
            edge.end        |> { view.yoga.paddingEnd = CGFloat($0) }
            edge.horizontal |> { view.yoga.paddingHorizontal = CGFloat($0) }
            edge.vertical   |> { view.yoga.paddingVertical = CGFloat($0) }
        }
    }

    fileprivate func apply(border: Border, to view: UIView) {
        switch border {

        case .all(let value):
            view.yoga.borderWidth = CGFloat(value)

        case .by(let edge):
            edge.left       |> { view.yoga.borderLeftWidth = CGFloat($0) }
            edge.right      |> { view.yoga.borderRightWidth = CGFloat($0) }
            edge.top        |> { view.yoga.borderTopWidth = CGFloat($0) }
            edge.bottom     |> { view.yoga.borderBottomWidth = CGFloat($0) }
            edge.start      |> { view.yoga.borderStartWidth = CGFloat($0) }
            edge.end        |> { view.yoga.borderEndWidth = CGFloat($0) }
            
            // TODO review why this properties are missing
            // edge.horizontal |> { view.yoga.borderHorizontal = CGFloat($0) }
            // edge.vertical   |> { view.yoga.borderVertical = CGFloat($0) }
        }
    }

    fileprivate func apply(aspectRation: AspectRatio, to view: UIView) {
        view.yoga.aspectRatio = CGFloat(aspectRation.rawValue)
    }

    fileprivate func apply(direction: Direction, to view: UIView) {
        view.yoga.direction = direction.yg_direction
    }

}

fileprivate extension AlignContent {

    fileprivate var yg_alignContent: YGAlign {
        // TODO review this. It seems there is a mismatch betweeen docs
        switch self {
        case .flexStart:
            return .flexStart
        case .flexEnd:
            return .flexEnd
        case .center:
            return .center
        case .stretch:
            return .stretch
        case .spaceAround:
            return .auto
        }
    }

}

fileprivate extension AlignSelf {

    fileprivate var yg_alignSelf: YGAlign {
        switch self {
        case .stretch:
            return .stretch
        case .flexStart:
            return .flexStart
        case .flexEnd:
            return .flexEnd
        case .center:
            return .center
        }
    }

}

fileprivate extension AlignItems {

    fileprivate var yg_alignItems: YGAlign {
        switch self {
        case .stretch:
            return .stretch
        case .flexStart:
            return .flexStart
        case .flexEnd:
            return .flexEnd
        case .center:
            return .center
        }
    }

}

fileprivate extension FlexDirection {

    fileprivate var yg_flexDirection: YGFlexDirection {
        switch self {
        case .row:
            return .row
        case .rowReverse:
            return .rowReverse
        case .column:
            return .column
        case .columnReverse:
            return .columnReverse
        }
    }

}

fileprivate extension FlexWrap {

    fileprivate var yg_flexWrap: YGWrap {
        switch self {
        case .nowrap:
            return .noWrap
        case .wrap:
            return .wrap
        }
    }

}

fileprivate extension JustifyContent {

    fileprivate var yg_justifyContent: YGJustify {
        switch self {
        case .flexStart:
            return .flexStart
        case .flexEnd:
            return .flexEnd
        case .center:
            return .center
        case .spaceAround:
            return .spaceAround
        case .spaceBetween:
            return .spaceBetween
        }
    }

}

fileprivate extension Direction {

    fileprivate var yg_direction: YGDirection {
        switch self {
        case .inherit:
            return .inherit
        case .leftToRight:
            return .LTR
        case .rightToLeft:
            return .RTL
        }
    }

}

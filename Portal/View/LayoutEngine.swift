//
//  LayoutEngine.swift
//  Portal
//
//  Created by Guido Marucci Blas on 12/11/16.
//  Copyright © 2016 Guido Marucci Blas. All rights reserved.
//
// swiftlint:disable file_length
import UIKit

public protocol LayoutEngine {

    func executeLayout(for view: UIView)

    func apply(changeSet: [Layout.Property], to view: UIView)

}

internal struct YogaLayoutEngine: LayoutEngine {

    func executeLayout(for view: UIView) {
        view.yoga.isEnabled = true
        view.yoga.width = view.bounds.size.width
        view.yoga.height = view.bounds.size.height
        view.yoga.applyLayout(preservingOrigin: true)
    }

    // swiftlint:disable cyclomatic_complexity
    func apply(changeSet: [Layout.Property], to view: UIView) {  
        view.yoga.isEnabled = true
        
        for property in changeSet {
            switch property {

            case .flex(let flexChangeSet):
                apply(changeSet: flexChangeSet, to: view)

            case .justifyContent(let justifyContent):
                apply(justifyContent: justifyContent, to: view)

            case .width(let widthChangeSet):
                apply(widthChangeSet: widthChangeSet, to: view)

            case .height(let heightChangeSet):
                apply(heightChangeSet: heightChangeSet, to: view)

            case .alignment(let alignmentChangeSet):
                apply(changeSet: alignmentChangeSet, to: view)

            case .position(let position):
                apply(position: position, to: view)

            case .margin(let margin):
                apply(margin: margin, to: view)

            case .padding(let padding):
                apply(padding: padding, to: view)

            case .border(let border):
                apply(border: border, to: view)
                
            case .aspectRatio(let aspectRatio):
                apply(aspectRatio: aspectRatio, to: view)

            case .direction(let direction):
                apply(direction: direction, to: view)

            }
        }
    }
    // swiftlint:enable cyclomatic_complexity

}

fileprivate extension YogaLayoutEngine {
    
    fileprivate func apply(changeSet: [Flex.Property], to view: UIView) {
        for property in changeSet {
            switch property {
                
            case .basis(let maybeBasis):
                if let basis = maybeBasis {
                    view.yoga.flexBasis = CGFloat(basis)
                } else {
                    view.yoga.flexBasis = .nan
                }
                
            case .direction(let direction):
                view.yoga.flexDirection = direction.yogaFlexDirection
                
            case .grow(let grow):
                view.yoga.flexGrow = CGFloat(grow.rawValue)
                
            case .shrink(let shrink):
                view.yoga.flexShrink = CGFloat(shrink.rawValue)
                
            case .wrap(let wrap):
                view.yoga.flexWrap = wrap.yogaFlexWrap
                
            }
        }
    }

    fileprivate func apply(changeSet: [Alignment.Property], to view: UIView) {
        for property in changeSet {
            switch property {

            case .content(let content):
                view.yoga.alignContent = content.yogaAlignContent

            case .items(let items):
                view.yoga.alignItems = items.yogaAlignItems

            case .self(let maybeAlignSelf):
                if let alignSelf = maybeAlignSelf {
                    view.yoga.alignSelf = alignSelf.yogaAlignSelf
                } else {
                    view.yoga.alignSelf = .auto
                }
            }
        }
    }

    fileprivate func apply(widthChangeSet: [Dimension.Property]?, to view: UIView) {
        apply(
            changeSet: widthChangeSet,
            to: view,
            valueSetter: { $0.yoga.width = $1 },
            minSetter: { $0.yoga.minWidth = $1 },
            maxSetter: { $0.yoga.maxWidth = $1}
        )
    }

    fileprivate func apply(heightChangeSet: [Dimension.Property]?, to view: UIView) {
        apply(
            changeSet: heightChangeSet,
            to: view,
            valueSetter: { $0.yoga.height = $1 },
            minSetter: { $0.yoga.minHeight = $1 },
            maxSetter: { $0.yoga.maxHeight = $1 }
        )
    }

    // XXX we are using `CGFloat.nan` to "unset" width-related properties
    // because Yoga defines `YGUndefined` as `NAN` and `YGUndefined` is
    // the default value for layout dimension properties.
    //
    // This is an implementation detail and may change between Yoga
    // releases. Yoga does not expose a way to set a property to its
    // default value.
    fileprivate func apply(
        changeSet maybeChangeSet: [Dimension.Property]?,
        to view: UIView,
        valueSetter: (UIView, CGFloat) -> Void,
        minSetter: (UIView, CGFloat) -> Void,
        maxSetter: (UIView, CGFloat) -> Void) {
        guard let widthChangeSet = maybeChangeSet else {
            valueSetter(view, .nan)
            minSetter(view, .nan)
            maxSetter(view, .nan)
            return
        }

        for property in widthChangeSet {
            switch property {

            case .value(let maybeValue):
                if let value = maybeValue {
                    valueSetter(view, CGFloat(value))
                } else {
                    valueSetter(view, .nan)
                }

            case .minimum(let maybeMinimum):
                if let minimum = maybeMinimum {
                    minSetter(view, CGFloat(minimum))
                } else {
                    minSetter(view, .nan)
                }

            case .maximum(let maybeMaximum):
                if let maximum = maybeMaximum {
                    maxSetter(view, CGFloat(maximum))
                } else {
                    maxSetter(view, .nan)
                }

            }
        }
    }

    fileprivate func apply(justifyContent: JustifyContent, to view: UIView) {
        view.yoga.justifyContent = justifyContent.yogaJustifyContent
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

    fileprivate func apply(margin maybeMargin: Margin?, to view: UIView) {
        guard let margin = maybeMargin else {
            view.yoga.margin = .nan
            view.yoga.marginLeft = .nan
            view.yoga.marginRight = .nan
            view.yoga.marginTop = .nan
            view.yoga.marginBottom = .nan
            view.yoga.marginStart = .nan
            view.yoga.marginEnd = .nan
            view.yoga.marginHorizontal = .nan
            view.yoga.marginVertical = .nan
            return
        }

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

    fileprivate func apply(padding maybePadding: Padding?, to view: UIView) {
        guard let padding = maybePadding else {
            view.yoga.padding = .nan
            view.yoga.paddingLeft = .nan
            view.yoga.paddingRight = .nan
            view.yoga.paddingTop = .nan
            view.yoga.paddingBottom = .nan
            view.yoga.paddingStart = .nan
            view.yoga.paddingEnd = .nan
            view.yoga.paddingHorizontal = .nan
            view.yoga.paddingVertical = .nan
            return
        }

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

    fileprivate func apply(border maybeBorder: Border?, to view: UIView) {
        guard let border = maybeBorder else {
            view.yoga.borderWidth = .nan 
            view.yoga.borderLeftWidth = .nan
            view.yoga.borderRightWidth = .nan
            view.yoga.borderTopWidth = .nan
            view.yoga.borderBottomWidth = .nan
            view.yoga.borderStartWidth = .nan
            view.yoga.borderEndWidth = .nan
            return
        }

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

    fileprivate func apply(aspectRatio maybeAspectRatio: AspectRatio?, to view: UIView) {
        if let aspectRatio = maybeAspectRatio {
            view.yoga.aspectRatio = CGFloat(aspectRatio.rawValue)
        } else {
            view.yoga.aspectRatio = .nan
        }
    }

    fileprivate func apply(direction: Direction, to view: UIView) {
        view.yoga.direction = direction.yogaDirection
    }

}

fileprivate extension AlignContent {

    fileprivate var yogaAlignContent: YGAlign {
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

    fileprivate var yogaAlignSelf: YGAlign {
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

    fileprivate var yogaAlignItems: YGAlign {
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

    fileprivate var yogaFlexDirection: YGFlexDirection {
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

    fileprivate var yogaFlexWrap: YGWrap {
        switch self {
        case .nowrap:
            return .noWrap
        case .wrap:
            return .wrap
        }
    }

}

fileprivate extension JustifyContent {

    fileprivate var yogaJustifyContent: YGJustify {
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

    fileprivate var yogaDirection: YGDirection {
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

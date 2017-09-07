//
//  Label.swift
//  PortalView
//
//  Created by Guido Marucci Blas on 1/27/17.
//
//

import Foundation

public struct LabelProperties: AutoPropertyDiffable {
    
    public let text: String
    public let textAfterLayout: String?
    
    fileprivate init(text: String, textAfterLayout: String?) {
        self.text = text
        self.textAfterLayout = textAfterLayout
    }
    
}

public func label<MessageType>(
    text: String = "",
    style: StyleSheet<LabelStyleSheet> = LabelStyleSheet.`default`,
    layout: Layout = layout()) -> Component<MessageType> {
    return .label(properties(text: text), style, layout)
}

public func label<MessageType>(
    properties: LabelProperties = properties(),
    style: StyleSheet<LabelStyleSheet> = LabelStyleSheet.`default`,
    layout: Layout = layout()) -> Component<MessageType> {
    return .label(properties, style, layout)
}

public func properties(
    text: String = "",
    textAfterLayout: String? = .none) -> LabelProperties {
    return LabelProperties(text: text, textAfterLayout: textAfterLayout)
}

// MARK: - Style sheet

public struct LabelStyleSheet: AutoPropertyDiffable {
    
    static let `default` = StyleSheet<LabelStyleSheet>(component: LabelStyleSheet())
    
    public var textColor: Color
    public var textFont: Font
    public var textSize: UInt
    public var textAligment: TextAligment
    public var adjustToFitWidth: Bool
    public var numberOfLines: UInt
    public var minimumScaleFactor: Float
    
    public init(
        textColor: Color = .black,
        textFont: Font = defaultFont,
        textSize: UInt = defaultButtonFontSize,
        textAligment: TextAligment = .natural,
        adjustToFitWidth: Bool = false,
        numberOfLines: UInt = 0,
        minimumScaleFactor: Float = 0) {
        self.textColor = textColor
        self.textFont = textFont
        self.textSize = textSize
        self.textAligment = textAligment
        self.adjustToFitWidth = adjustToFitWidth
        self.numberOfLines = numberOfLines
        self.minimumScaleFactor = minimumScaleFactor
    }
    
}

public func labelStyleSheet(
    configure: (inout BaseStyleSheet, inout LabelStyleSheet) -> Void = { _ in }) -> StyleSheet<LabelStyleSheet> {
    var base = BaseStyleSheet()
    var component = LabelStyleSheet()
    configure(&base, &component)
    return StyleSheet(component: component, base: base)
}

// MARK: - Change set

internal struct LabelChangeSet {
    
    static func fullChangeSet(
        properties: LabelProperties,
        styleSheet: StyleSheet<LabelStyleSheet>,
        layout: Layout) -> LabelChangeSet {
        return LabelChangeSet(
            properties: properties.fullChangeSet,
            baseStyleSheet: styleSheet.base.fullChangeSet,
            labelStyleSheet: styleSheet.component.fullChangeSet,
            layout: layout.fullChangeSet
        )
    }
    
    let properties: [LabelProperties.Property]
    let baseStyleSheet: [BaseStyleSheet.Property]
    let labelStyleSheet: [LabelStyleSheet.Property]
    let layout: [Layout.Property]
    
    init(
        properties: [LabelProperties.Property] = [],
        baseStyleSheet: [BaseStyleSheet.Property] = [],
        labelStyleSheet: [LabelStyleSheet.Property] = [],
        layout: [Layout.Property] = []) {
        self.properties = properties
        self.baseStyleSheet = baseStyleSheet
        self.labelStyleSheet = labelStyleSheet
        self.layout = layout
    }
    
}

//
//  TextView.swift
//  Portal
//
//  Created by Cristian Ames on 7/18/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//

import Foundation

public enum Text: AutoEquatable {
    
    case regular(String)
    case attributed(NSAttributedString)
    
}

public func textView<MessageType>(
    properties: TextViewProperties = TextViewProperties(),
    style: StyleSheet<TextViewStyleSheet> = TextViewStyleSheet.`default`,
    layout: Layout = layout()) -> Component<MessageType> {
    return .textView(properties, style, layout)
}

public struct TextViewProperties: AutoPropertyDiffable {
    
    public var text: Text
    public var isScrollEnabled: Bool
    public var isEditable: Bool
    
    public init(text: Text = .regular(""), isScrollEnabled: Bool = false, isEditable: Bool = false) {
        self.text = text
        self.isScrollEnabled = isScrollEnabled
        self.isEditable = isEditable
    }
    
}

public func properties(
    configure: (inout TextViewProperties) -> Void) -> TextViewProperties {
    var properties = TextViewProperties()
    configure(&properties)
    return properties
}

// MARK: - Style sheet

public struct TextViewStyleSheet: AutoPropertyDiffable {
    
    public static let `default` = StyleSheet<TextViewStyleSheet>(component: TextViewStyleSheet())
    
    public var textColor: Color
    public var textFont: Font
    public var textSize: UInt
    public var textAligment: TextAligment
    
    public init(
        textColor: Color = .black,
        textFont: Font = defaultFont,
        textSize: UInt = defaultButtonFontSize,
        textAligment: TextAligment = .natural ) {
        self.textColor = textColor
        self.textFont = textFont
        self.textSize = textSize
        self.textAligment = textAligment
    }
    
}

public func textViewStyleSheet(
    configure: (inout BaseStyleSheet, inout TextViewStyleSheet) -> Void = { _, _ in }
    ) -> StyleSheet<TextViewStyleSheet> {
    var base = BaseStyleSheet()
    var component = TextViewStyleSheet()
    configure(&base, &component)
    return StyleSheet(component: component, base: base)
}

// MARK: - Change set

public struct TextViewChangeSet {
    
    static func fullChangeSet(
        properties: TextViewProperties,
        style: StyleSheet<TextViewStyleSheet>,
        layout: Layout) -> TextViewChangeSet {
        return TextViewChangeSet(
            properties: properties.fullChangeSet,
            baseStyleSheet: style.base.fullChangeSet,
            textViewStyleSheet: style.component.fullChangeSet,
            layout: layout.fullChangeSet
        )
    }
    
    let properties: [TextViewProperties.Property]
    let baseStyleSheet: [BaseStyleSheet.Property]
    let textViewStyleSheet: [TextViewStyleSheet.Property]
    let layout: [Layout.Property]
    
    var isEmpty: Bool {
        return  properties.isEmpty          &&
                baseStyleSheet.isEmpty      &&
                textViewStyleSheet.isEmpty  &&
                layout.isEmpty
    }
    
    init(
        properties: [TextViewProperties.Property],
        baseStyleSheet: [BaseStyleSheet.Property] = [],
        textViewStyleSheet: [TextViewStyleSheet.Property] = [],
        layout: [Layout.Property] = []) {
        self.properties = properties
        self.baseStyleSheet = baseStyleSheet
        self.textViewStyleSheet = textViewStyleSheet
        self.layout = layout
    }
    
}

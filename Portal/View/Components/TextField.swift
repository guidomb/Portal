//
//  TextField.swift
//  PortalView
//
//  Created by Juan Franco Caracciolo on 4/10/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//

import Foundation

public struct TextFieldProperties<MessageType>: AutoPropertyDiffable {
    
    public var text: String?
    public var placeholder: String?
    // sourcery: skipDiff
    public var onEvents: TextFieldEvents<MessageType>
    
    fileprivate init(
        text: String? = .none,
        placeholder: String? = .none,
        onEvents: TextFieldEvents<MessageType> = TextFieldEvents<MessageType>()) {
        self.text = text
        self.placeholder = placeholder
        self.onEvents = onEvents
    }
    
    public func map<NewMessageType>(
        _ transform: (MessageType) -> NewMessageType) -> TextFieldProperties<NewMessageType> {
        return TextFieldProperties<NewMessageType>(
            text: self.text,
            placeholder: self.placeholder,
            onEvents: self.onEvents.map(transform)
        )
    }
    
}

public struct TextFieldEvents<MessageType> {
    
    public var onEditingBegin: MessageType?
    public var onEditingChanged: MessageType?
    public var onEditingEnd: MessageType?
    
    public init(
        onEditingBegin: MessageType? = .none,
        onEditingChanged: MessageType? = .none,
        onEditingEnd: MessageType? = .none) {
        self.onEditingBegin = onEditingBegin
        self.onEditingChanged = onEditingChanged
        self.onEditingEnd = onEditingEnd
    }
    
    public func map<NewMessageType>(_ transform: (MessageType) -> NewMessageType) -> TextFieldEvents<NewMessageType> {
        return TextFieldEvents<NewMessageType>(
            onEditingBegin: onEditingBegin.map(transform),
            onEditingChanged: onEditingChanged.map(transform),
            onEditingEnd: onEditingEnd.map(transform)
        )
    }
    
}

public func textFieldEvents<MessageType>(
    configure: (inout TextFieldEvents<MessageType>) -> Void) -> TextFieldEvents<MessageType> {
    var events = TextFieldEvents<MessageType>()
    configure(&events)
    return events
}

public func textField<MessageType>(
    properties: TextFieldProperties<MessageType> = TextFieldProperties(),
    style: StyleSheet<TextFieldStyleSheet> = TextFieldStyleSheet.`default`,
    layout: Layout = layout()) -> Component<MessageType> {
    return .textField(properties, style, layout)
}

public func properties<MessageType>(
    configure: (inout TextFieldProperties<MessageType>) -> Void) -> TextFieldProperties<MessageType> {
    var properties = TextFieldProperties<MessageType>()
    configure(&properties)
    return properties
}

// MARK: - Style sheet

public struct TextFieldStyleSheet: AutoPropertyDiffable {
    
    static let `default` = StyleSheet<TextFieldStyleSheet>(component: TextFieldStyleSheet())
    
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

public func textFieldStyleSheet(
    configure: (inout BaseStyleSheet, inout TextFieldStyleSheet) -> Void = { _ in }
    ) -> StyleSheet<TextFieldStyleSheet> {
    var base = BaseStyleSheet()
    var component = TextFieldStyleSheet()
    configure(&base, &component)
    return StyleSheet(component: component, base: base)
}

// MARK: - Change set

internal struct TextFieldChangeSet<MessageType> {
    
    static func fullChangeSet(
        properties: TextFieldProperties<MessageType>,
        style: StyleSheet<TextFieldStyleSheet>,
        layout: Layout) -> TextFieldChangeSet<MessageType> {
        return TextFieldChangeSet(
            properties: properties.fullChangeSet,
            baseStyleSheet: style.base.fullChangeSet,
            textFieldStyleSheet: style.component.fullChangeSet,
            layout: layout.fullChangeSet
        )
    }
    
    let properties: [TextFieldProperties<MessageType>.Property]
    let baseStyleSheet: [BaseStyleSheet.Property]
    let textFieldStyleSheet: [TextFieldStyleSheet.Property]
    let layout: [Layout.Property]
    
    init(
        properties: [TextFieldProperties<MessageType>.Property] = [],
        baseStyleSheet: [BaseStyleSheet.Property] = [],
        textFieldStyleSheet: [TextFieldStyleSheet.Property] = [],
        layout: [Layout.Property] = []) {
        self.properties = properties
        self.baseStyleSheet = baseStyleSheet
        self.textFieldStyleSheet = textFieldStyleSheet
        self.layout = layout
    }
    
}

//
//  TextField.swift
//  PortalView
//
//  Created by Juan Franco Caracciolo on 4/10/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//

import Foundation

public struct TextFieldProperties<MessageType> {
    
    public var text: String?
    public var placeholder: String?
    public var isSecureTextEntry: Bool
    public var shouldReturn: Bool
    public var onEvents: (TextFieldEvents) -> MessageType?

    fileprivate init(
        text: String? = .none,
        placeholder: String? = .none,
        isSecureTextEntry: Bool = false,
        shouldReturn: Bool = false,
        onEvents: @escaping (TextFieldEvents) -> MessageType? = { _ in return .none}) {
        self.text = text
        self.placeholder = placeholder
        self.onEvents = onEvents
        self.isSecureTextEntry = isSecureTextEntry
        self.shouldReturn = shouldReturn
    }
    
    public func map<NewMessageType>(
        _ transform: @escaping (MessageType) -> NewMessageType) -> TextFieldProperties<NewMessageType> {
        return TextFieldProperties<NewMessageType>(
            text: self.text,
            placeholder: self.placeholder,
            isSecureTextEntry: isSecureTextEntry,
            onEvents:  { return self.onEvents($0).map(transform) }
        )
    }
    
}

public enum TextFieldEvents {
    case onEditingBegin(text: String)
    case onEditingChanged(text: String)
    case onEditingEnd(text: String)
    
    static func fromUI(_ event: UIControlEvents, text: String) -> TextFieldEvents? {
        
        switch(event) {
            
        case .editingDidBegin:
            return .onEditingBegin(text: text)
        case .editingChanged:
            return .onEditingChanged(text: text)
        case .editingDidEnd:
            return .onEditingEnd(text: text)
        default:
            return .none
            
        }
        
    }
    
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

public struct TextFieldStyleSheet {
    
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

//
//  TextFieldRenderer.swift
//  PortalView
//
//  Created by Juan Franco Caracciolo on 4/10/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//

import UIKit

internal struct TextFieldRenderer<MessageType, RouteType: Route>: UIKitRenderer {
    
    typealias ActionType = Action<RouteType, MessageType>
    
    let properties: TextFieldProperties<ActionType>
    let style: StyleSheet<TextFieldStyleSheet>
    let layout: Layout
    
    func render(with layoutEngine: LayoutEngine, isDebugModeEnabled: Bool) -> Render<ActionType> {
        let textField = UITextField()
        textField.placeholder = properties.placeholder
        textField.text = properties.text
        textField.isSecureTextEntry = properties.isSecureTextEntry
        
        textField.apply(style: style.base)
        textField.apply(style: style.component)
        layoutEngine.apply(layout: layout, to: textField)
        
        textField.unregisterDispatchers()
        textField.removeTarget(.none, action: .none, for: .editingDidBegin)
        textField.removeTarget(.none, action: .none, for: .editingChanged)
        textField.removeTarget(.none, action: .none, for: .editingDidEnd)
        if properties.shouldReturn {
            textField.delegate = TextFieldDelegate()
        }

        let dispatcher: (Mailbox<ActionType>) -> Void = { mailbox in
            _ = textField.dispatch(onEvent: self.properties.onEvents, for: .editingDidBegin, with: mailbox)
            _ = textField.dispatch(onEvent: self.properties.onEvents, for: .editingChanged, with: mailbox)
            _ = textField.dispatch(onEvent: self.properties.onEvents, for: .editingDidEnd, with: mailbox)
        }
        
        let mailbox = textField.bindMessageDispatcher(binder: dispatcher)
        
        return Render(view: textField, mailbox: mailbox)
    }
    
}

fileprivate class TextFieldDelegate: NSObject, UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }
}

extension UITextField {
    
    fileprivate func apply(style: TextFieldStyleSheet) {
        let size = CGFloat(style.textSize)
        style.textFont.uiFont(withSize: size)     |> { self.font = $0 }
        style.textColor                           |> { self.textColor = $0.asUIColor }
        style.textAligment                        |> { self.textAlignment = $0.asNSTextAligment }
    }
    
}

extension UITextField {
    
    fileprivate func dispatch<MessageType>(
        onEvent: @escaping (TextFieldEvents) -> MessageType?,
        for event: UIControlEvents,
        with mailbox: Mailbox<MessageType> = Mailbox()) -> Mailbox<MessageType> {
        
        let dispatcher = MessageDispatcher(mailbox: mailbox) { sender in
            guard let textField = sender as? UITextField else { return .none }
            guard let textFieldEvent = TextFieldEvents.fromUI(event, text: textField.text ?? "") else { return .none }
            return onEvent(textFieldEvent)
        }
        
        self.register(dispatcher: dispatcher)
        self.addTarget(dispatcher, action: dispatcher.selector, for: event)
        return dispatcher.mailbox
    }
    
}

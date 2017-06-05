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
        
        textField.apply(style: style.base)
        textField.apply(style: style.component)
        layoutEngine.apply(layout: layout, to: textField)
        
        textField.unregisterDispatchers()
        textField.removeTarget(.none, action: .none, for: .editingDidBegin)
        textField.removeTarget(.none, action: .none, for: .editingChanged)
        textField.removeTarget(.none, action: .none, for: .editingDidEnd)

        let mailbox: Mailbox<ActionType> = textField.bindMessageDispatcher { mailbox in
            properties.onEvents.onEditingBegin |> { _ = textField.dispatch(
                message: $0,
                for: .editingDidBegin,
                with: mailbox)
            }
            properties.onEvents.onEditingChanged |> { _ = textField.dispatch(
                message: $0,
                for: .editingChanged,
                with: mailbox)
            }
            properties.onEvents.onEditingEnd |> { _ = textField.dispatch(
                message: $0,
                for: .editingDidEnd,
                with: mailbox)
            }
        }
        
        return Render(view: textField, mailbox: mailbox)
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
        message: MessageType,
        for event: UIControlEvents,
        with mailbox: Mailbox<MessageType> = Mailbox()) -> Mailbox<MessageType> {
        
        let dispatcher = MessageDispatcher(mailbox: mailbox, message: message)
        self.register(dispatcher: dispatcher)
        self.addTarget(dispatcher, action: dispatcher.selector, for: event)
        return dispatcher.mailbox
    }
    
}

//
//  TextFieldRenderer.swift
//  PortalView
//
//  Created by Juan Franco Caracciolo on 4/10/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//

import UIKit

public let defaultTextFieldFontSize = UInt(UIFont.systemFontSize)

internal struct TextFieldRenderer<MessageType, RouteType: Route>: UIKitRenderer {
    
    typealias ActionType = Action<RouteType, MessageType>
    
    let properties: TextFieldProperties<ActionType>
    let style: StyleSheet<TextFieldStyleSheet>
    let layout: Layout
    
    func render(with layoutEngine: LayoutEngine, isDebugModeEnabled: Bool) -> Render<ActionType> {
        let textField = UITextField()
        let changeSet = TextFieldChangeSet.fullChangeSet(properties: properties, styleSheet: style, layout: layout)
        
        return textField.apply(changeSet: changeSet, layoutEngine: layoutEngine)
    }
    
}

extension UITextField: MessageHandler {
    
    internal func apply<MessageType>(
        changeSet: TextFieldChangeSet<MessageType>,
        layoutEngine: LayoutEngine) -> Render<MessageType> {
        
        apply(changeSet: changeSet.properties)
        apply(changeSet: changeSet.baseStyleSheet)
        apply(changeSet: changeSet.textFieldStyleSheet)
        layoutEngine.apply(changeSet: changeSet.layout, to: self)
        
        return Render(view: self, mailbox: getMailbox(mailboxKey: &mailboxAssociationKey), executeAfterLayout: .none)
    }
    
}

fileprivate var messageDispatcherAssociationKey = 0
fileprivate var mailboxAssociationKey = 1

fileprivate extension UITextField {
    
    fileprivate func apply<MessageType>(changeSet: [TextFieldProperties<MessageType>.Property]) {
        for propertie in changeSet {
            switch propertie {
                
            case .text(let text):
                self.text = text
            
            case .placeholder(let placeholder):
                self.placeholder = placeholder
                
            case .onEvents(let events):
                apply(events: events)
            }
        }
    }
    
    fileprivate func apply<MessageType>(events: TextFieldEvents<MessageType>) {
        for maybeEvent in events.toArray() {
            let event = maybeEvent.0
            if let message = maybeEvent.1 {
                _ = self.on(
                    event: event, dispatch: message,
                    dispatcherKey: &messageDispatcherAssociationKey, mailboxKey: &mailboxAssociationKey)
            } else {
                _ = self.unregisterDispatcher(
                    for: event,
                    dispatcherKey: &messageDispatcherAssociationKey) as MessageDispatcher<MessageType>?
            }
        }
    }
    
    fileprivate func apply(changeSet: [TextFieldStyleSheet.Property]) {
        for propertie in changeSet {
            switch propertie {
                
            case .textAligment(let aligment):
                self.textAlignment = aligment.asNSTextAligment
            
            case .textColor(let color):
                self.textColor = color.asUIColor
                
            case .textFont(let font):
                let fontSize = self.font?.pointSize ?? CGFloat(defaultTextFieldFontSize)
                self.font = font.uiFont(withSize: fontSize)
                
            case .textSize(let textSize):
                let fontName = self.font?.fontName
                fontName |> { self.font = UIFont(name: $0, size: CGFloat(textSize)) }
            }
        }
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

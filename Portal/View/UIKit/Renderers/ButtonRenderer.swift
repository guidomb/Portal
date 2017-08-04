//
//  ButtonRenderer.swift
//  PortalView
//
//  Created by Guido Marucci Blas on 2/14/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//

import UIKit

public let defaultButtonFontSize = UInt(UIFont.buttonFontSize)

internal struct ButtonRenderer<MessageType, RouteType: Route>: UIKitRenderer {
    
    static func apply<RouteType, MessageType>(
        changeSet: [ButtonProperties<Action<RouteType, MessageType>>.Property],
        to button: UIButton) -> Render<Action<RouteType, MessageType>> {
        
        var mailbox: Mailbox<Action<RouteType, MessageType>>?
        for property in changeSet {
            switch property {
                
            case .text(let text):
                button.setTitle(text, for: .normal)
                
            case .icon(let icon):
                let image = icon.map { $0.asUIImage }
                button.setImage(image, for: .normal)
                
            case .isActive(let isActive):
                button.isSelected = isActive
                
            case .onTap(let onTap):
                if let message = onTap {
                    mailbox = button.dispatch(message: message, for: .touchUpInside)
                } else {
                    _ = button.unregisterDispatcher(for: .touchUpInside) as MessageDispatcher<MessageType>?
                }
                
            }
        }
        
        return Render(view: button, mailbox: mailbox, executeAfterLayout: .none)
    }
    
    typealias ActionType = Action<RouteType, MessageType>
    
    let properties: ButtonProperties<ActionType>
    let style: StyleSheet<ButtonStyleSheet>
    let layout: Layout
    
    func render(with layoutEngine: LayoutEngine, isDebugModeEnabled: Bool) -> Render<ActionType> {
        let button = UIButton()
        
        let result = ButtonRenderer.apply(changeSet: properties.fullChangeSet, to: button)
        button.apply(style: style.base)
        button.apply(style: style.component)
        layoutEngine.apply(layout: layout, to: button)
        
        return result
    }
    
}

fileprivate var messageDispatcherAssociationKey = 0

extension UIButton {
    
    fileprivate func dispatch<MessageType>(
        message: MessageType,
        for event: UIControlEvents) -> Mailbox<MessageType> {
        
        let mailbox: Mailbox<MessageType>
        if let oldDispatcher = getDispatcher(for: event) as MessageDispatcher<MessageType>? {
            mailbox = oldDispatcher.mailbox
            self.removeTarget(oldDispatcher, action: oldDispatcher.selector, for: event)
        } else {
            mailbox = Mailbox<MessageType>()
        }
        
        let dispatcher = MessageDispatcher(mailbox: mailbox, message: message)
        self.register(dispatcher: dispatcher, for: event)
        self.addTarget(dispatcher, action: dispatcher.selector, for: event)
        
        return dispatcher.mailbox
    }
    
    fileprivate func register<MessageType>(
        dispatcher: MessageDispatcher<MessageType>,
        for event: UIControlEvents) {
        
        var dispatchers = objc_getAssociatedObject(self, &messageDispatcherAssociationKey)
            as? [UInt : MessageDispatcher<MessageType>] ?? [:]
        dispatchers[event.rawValue] = dispatcher
        objc_setAssociatedObject(self, &messageDispatcherAssociationKey, dispatchers,
                                 .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    fileprivate func unregisterDispatcher<MessageType>(
        for event: UIControlEvents) -> MessageDispatcher<MessageType>? {
        
        guard var dispatchers = objc_getAssociatedObject(self, &messageDispatcherAssociationKey)
            as? [UInt : MessageDispatcher<MessageType>] else { return .none }
        let dispatcher = dispatchers.removeValue(forKey: event.rawValue)
        objc_setAssociatedObject(self, &messageDispatcherAssociationKey, dispatchers,
                                 .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return dispatcher
    }
    
    fileprivate func getDispatcher<MessageType>(for event: UIControlEvents) -> MessageDispatcher<MessageType>? {
        let dispatchers = objc_getAssociatedObject(self, &messageDispatcherAssociationKey)
            as? [UInt : MessageDispatcher<MessageType>] ?? [:]
        return dispatchers[event.rawValue]
    }
    
}

extension UIButton {
    
    fileprivate func apply(style: ButtonStyleSheet) {
        self.setTitleColor(style.textColor.asUIColor, for: .normal)
        style.textFont.uiFont(withSize: style.textSize) |> { self.titleLabel?.font = $0 }
    }
    
}

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
                text |> { button.setTitle($0, for: .normal) }
                
            case .icon(let icon):
                icon |> { button.setImage($0.asUIImage, for: .normal) }
                
            case .isActive(let isActive):
                button.isSelected = isActive
                
            case .onTap(let onTap):
                onTap |> {
                    mailbox = button.dispatch(message: $0, for: .touchUpInside)
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
        objc_setAssociatedObject(self, &messageDispatcherAssociationKey, dispatcher,
                                 .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    fileprivate func getDispatcher<MessageType>(for event: UIControlEvents) -> MessageDispatcher<MessageType>? {
        return objc_getAssociatedObject(self, &messageDispatcherAssociationKey)
            as? MessageDispatcher<MessageType>
    }
    
}

extension UIButton {
    
    fileprivate func apply(style: ButtonStyleSheet) {
        self.setTitleColor(style.textColor.asUIColor, for: .normal)
        style.textFont.uiFont(withSize: style.textSize) |> { self.titleLabel?.font = $0 }
    }
    
}

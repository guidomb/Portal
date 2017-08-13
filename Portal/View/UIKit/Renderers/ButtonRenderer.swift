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
    
    typealias ActionType = Action<RouteType, MessageType>
    
    let properties: ButtonProperties<ActionType>
    let style: StyleSheet<ButtonStyleSheet>
    let layout: Layout
    
    func render(with layoutEngine: LayoutEngine, isDebugModeEnabled: Bool) -> Render<ActionType> {
        let button = UIButton()
        
        let changeSet = ButtonChangeSet.fullChangeSet(
            properties: properties,
            style: style,
            layout: layout
        )
        let result = button.apply(changeSet: changeSet, layoutEngine: layoutEngine)
        
        return result
    }
    
}

extension UIButton {
    
    internal func apply<MessageType>(
        changeSet: ButtonChangeSet<MessageType>,
        layoutEngine: LayoutEngine) -> Render<MessageType> {
        
        apply(changeSet: changeSet.properties)
        apply(changeSet: changeSet.baseStyleSheet)
        apply(changeSet: changeSet.buttonStyleSheet)
        layoutEngine.apply(changeSet: changeSet.layout, to: self)
        
        return Render(view: self, mailbox: getMailbox(), executeAfterLayout: .none)
    }
    
}

fileprivate var messageDispatcherAssociationKey = 0
fileprivate var mailboxAssociationKey = 1

fileprivate extension UIButton {
    
    fileprivate func apply<MessageType>(
        changeSet: [ButtonProperties<MessageType>.Property]) {
        
        for property in changeSet {
            switch property {
                
            case .text(let text):
                self.setTitle(text, for: .normal)
                
            case .icon(let icon):
                let image = icon.map { $0.asUIImage }
                self.setImage(image, for: .normal)
                
            case .isActive(let isActive):
                self.isSelected = isActive
                
            case .onTap(let onTap):
                if let message = onTap {
                    _ = self.on(event: .touchUpInside, dispatch: message)
                } else {
                    _ = self.unregisterDispatcher(for: .touchUpInside) as MessageDispatcher<MessageType>?
                }
            }
        }
    }
    
    fileprivate func apply(changeSet: [ButtonStyleSheet.Property]) {
        for property in changeSet {
            switch property {
                
            case .textColor(let textColor):
                self.setTitleColor(textColor.asUIColor, for: .normal)
                
            case .textSize(let textSize):
                let fontName = self.titleLabel?.font.fontName
                fontName |> { self.titleLabel?.font = UIFont(name: $0, size: CGFloat(textSize)) }
                
            case .textFont(let font):
                let fontSize = self.titleLabel?.font.pointSize ?? CGFloat(defaultButtonFontSize)
                self.titleLabel?.font = font.uiFont(withSize: fontSize)
                
            }
        }
    }
    
    fileprivate func on<MessageType>(event: UIControlEvents, dispatch message: MessageType) -> Mailbox<MessageType> {
        
        if let oldDispatcher = getDispatcher(for: event) as MessageDispatcher<MessageType>? {
            self.removeTarget(oldDispatcher, action: oldDispatcher.selector, for: event)
        }
        
        let mailbox: Mailbox<MessageType> = getMailbox()
        let dispatcher = MessageDispatcher(mailbox: mailbox, message: message)
        self.register(dispatcher: dispatcher, for: event)
        self.addTarget(dispatcher, action: dispatcher.selector, for: event)
        
        return mailbox
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
    
    fileprivate func getMailbox<MessageType>() -> Mailbox<MessageType> {
        let associatedObject = objc_getAssociatedObject(self, &mailboxAssociationKey)
        let mailbox: Mailbox<MessageType>
        if associatedObject == nil {
            mailbox = Mailbox()
            objc_setAssociatedObject(self, &mailboxAssociationKey, mailbox,
                                     .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        } else {
            assert(associatedObject is Mailbox<MessageType>,
                   "Associated Mailbox's message type does not match '\(MessageType.self)'")
            mailbox = associatedObject as! Mailbox<MessageType> // swiftlint:disable:this force_cast
        }
        return mailbox
    }
    
}

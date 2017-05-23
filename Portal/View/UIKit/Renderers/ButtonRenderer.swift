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
        
        properties.text |> { button.setTitle($0, for: .normal) }
        properties.icon |> { button.setImage($0.asUIImage, for: .normal) }
        button.isSelected = properties.isActive
        
        button.apply(style: style.base)
        button.apply(style: style.component)
        layoutEngine.apply(layout: layout, to: button)
        
        button.unregisterDispatchers()
        button.removeTarget(.none, action: .none, for: .touchUpInside)
        let mailbox = button.bindMessageDispatcher { mailbox in
            properties.onTap |> { _ = button.dispatch(message: $0, for: .touchUpInside, with: mailbox) }
        }
        
        return Render(view: button, mailbox: mailbox)
    }
    
}

extension UIButton {
    
    fileprivate func dispatch<MessageType>(message: MessageType, for event: UIControlEvents, with mailbox: Mailbox<MessageType> = Mailbox()) -> Mailbox<MessageType> {
        let dispatcher = MessageDispatcher(mailbox: mailbox, message: message)
        self.register(dispatcher: dispatcher)
        self.addTarget(dispatcher, action: dispatcher.selector, for: event)
        return dispatcher.mailbox
    }
    
}

extension UIButton {
    
    fileprivate func apply(style: ButtonStyleSheet) {
        self.setTitleColor(style.textColor.asUIColor, for: .normal)
        style.textFont.uiFont(withSize: style.textSize) |> { self.titleLabel?.font = $0 }
    }
    
}

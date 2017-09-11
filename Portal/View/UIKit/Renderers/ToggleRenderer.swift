//
//  ToggleRenderer.swift
//  Portal
//
//  Created by Juan Franco Caracciolo on 8/16/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//

import UIKit

internal struct ToggleRenderer<MessageType, RouteType: Route>: UIKitRenderer {
    
    typealias ActionType = Action<RouteType, MessageType>
    
    let properties: ToggleProperties<ActionType>
    let style: StyleSheet<ToggleStyleSheet>
    let layout: Layout
    
    func render(with layoutEngine: LayoutEngine, isDebugModeEnabled: Bool) -> Render<ActionType> {
        let toggle = UISwitch()
        
        toggle.isSelected = properties.isActive
        toggle.isEnabled = properties.isEnabled
        toggle.setOn(properties.isOn, animated: false)
        
        toggle.apply(style: style.base)
        toggle.apply(style: style.component)
        layoutEngine.apply(layout: layout, to: toggle)
        
        toggle.unregisterDispatchers()
        toggle.removeTarget(.none, action: .none, for: .touchUpInside)
        
        let dispatcher: (Mailbox<ActionType>) -> Void = { mailbox in
            _ = toggle.dispatch(onSwitch: self.properties.onSwitch, for: .touchUpInside, with: mailbox)
        }
        
        let mailbox = toggle.bindMessageDispatcher(binder: dispatcher)
        
        return Render(view: toggle, mailbox: mailbox)
    }
    
}

extension UISwitch {
    
    fileprivate func dispatch<MessageType>(
        onSwitch: @escaping (Bool) -> MessageType?,
        for event: UIControlEvents,
        with mailbox: Mailbox<MessageType> = Mailbox()) -> Mailbox<MessageType> {
        let dispatcher = MessageDispatcher(mailbox: mailbox) { sender in
            guard let toggle = sender as? UISwitch else { return .none }
            return onSwitch(toggle.isOn)
        }
        self.register(dispatcher: dispatcher)
        self.addTarget(dispatcher, action: dispatcher.selector, for: event)
        return dispatcher.mailbox
    }
    
}

extension UISwitch {
    
    fileprivate func apply(style: ToggleStyleSheet) {
        style.onTintColor |> { self.onTintColor = $0.asUIColor }
        style.tintChangingColor |> { self.tintColor = $0.asUIColor }
        style.thumbTintColor |> { self.thumbTintColor = $0.asUIColor }
    }
    
}

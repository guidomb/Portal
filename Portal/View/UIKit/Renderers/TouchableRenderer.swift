//
//  TouchableRenderer.swift
//  PortalView
//
//  Created by Guido Marucci Blas on 4/3/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//

import UIKit

internal struct TouchableRenderer<
    MessageType,
    RouteType: Route,
    CustomComponentRendererType: UIKitCustomComponentRenderer
    >: UIKitRenderer
    
    where CustomComponentRendererType.MessageType == MessageType, CustomComponentRendererType.RouteType == RouteType {
    
    typealias CustomComponentRendererFactory = () -> CustomComponentRendererType
    typealias ActionType = Action<RouteType, MessageType>
    
    let child: Component<ActionType>
    let gesture: Gesture<ActionType>
    let rendererFactory: CustomComponentRendererFactory
    
    func render(with layoutEngine: LayoutEngine, isDebugModeEnabled: Bool) -> Render<ActionType> {
        let renderer = ComponentRenderer(component: child, rendererFactory: rendererFactory)
        var result = renderer.render(with: layoutEngine, isDebugModeEnabled: isDebugModeEnabled)
        
        result.view.isUserInteractionEnabled = true
        
        switch gesture {
            
        case .tap(let message):
            let dispatcher: MessageDispatcher<ActionType>
            if let mailbox = result.mailbox {
              dispatcher = MessageDispatcher(mailbox: mailbox, message: message)
            } else {
                dispatcher = MessageDispatcher(message: message)
                result = Render(view: result.view, mailbox: dispatcher.mailbox, executeAfterLayout: result.afterLayout)
            }
            result.view.register(dispatcher: dispatcher)
            let recognizer = UITapGestureRecognizer(target: dispatcher, action: dispatcher.selector)
            result.view.addGestureRecognizer(recognizer)
            
        }
        return result
    }
    
}

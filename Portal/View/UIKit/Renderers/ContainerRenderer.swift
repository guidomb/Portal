//
//  ContainerRenderer.swift
//  PortalView
//
//  Created by Guido Marucci Blas on 2/14/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//

import UIKit

internal struct ContainerRenderer<
    MessageType,
    RouteType: Route,
    CustomComponentRendererType: UIKitCustomComponentRenderer
    >: UIKitRenderer
    
    where CustomComponentRendererType.MessageType == MessageType, CustomComponentRendererType.RouteType == RouteType {

    typealias CustomComponentRendererFactory = () -> CustomComponentRendererType
    typealias ActionType = Action<RouteType, MessageType>
    
    let children: [Component<ActionType>]
    let style: StyleSheet<EmptyStyleSheet>
    let layout: Layout
    let rendererFactory: CustomComponentRendererFactory
    
    func render(with layoutEngine: LayoutEngine, isDebugModeEnabled: Bool) -> Render<ActionType> {
        let view = UIView()
        view.managedByPortal = true
        
        var afterLayoutTasks: [AfterLayoutTask] = []
        let mailbox = Mailbox<ActionType>()
        for child in children {
            let renderer = ComponentRenderer(component: child, rendererFactory: rendererFactory)
            let renderResult = renderer.render(with: layoutEngine, isDebugModeEnabled: isDebugModeEnabled)
            renderResult.view.managedByPortal = true
            view.addSubview(renderResult.view)
            renderResult.afterLayout    |> { afterLayoutTasks.append($0) }
            renderResult.mailbox        |> { $0.forward(to: mailbox) }
        }
        
        view.apply(style: self.style.base)
        layoutEngine.apply(layout: self.layout, to: view)
        
        return Render(view: view, mailbox: mailbox) {
            afterLayoutTasks.forEach { $0() }
        }
    }
    
}

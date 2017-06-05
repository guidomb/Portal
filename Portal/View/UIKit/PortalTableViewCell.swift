//
//  PortalTableViewCell.swift
//  PortalView
//
//  Created by Guido Marucci Blas on 2/14/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//

import UIKit

public final class PortalTableViewCell<
    MessageType,
    RouteType: Route,
    CustomComponentRendererType: UIKitCustomComponentRenderer>: UITableViewCell
    
    where CustomComponentRendererType.MessageType == MessageType, CustomComponentRendererType.RouteType == RouteType  {
    
    public typealias CustomComponentRendererFactory = () -> CustomComponentRendererType
    public typealias ActionType = Action<RouteType, MessageType>
    
    public let mailbox = Mailbox<ActionType>()
    public var component: Component<ActionType>? = .none
    public var isDebugModeEnabled: Bool {
        set {
            self.renderer?.isDebugModeEnabled = newValue
        }
        get {
            return self.renderer?.isDebugModeEnabled ?? false
        }
    }
    
    private var renderer: UIKitComponentRenderer<MessageType, RouteType, CustomComponentRendererType>? = .none
    
    public init(
        reuseIdentifier: String,
        layoutEngine: LayoutEngine,
        rendererFactory: @escaping CustomComponentRendererFactory) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        self.renderer = UIKitComponentRenderer(
            containerView: contentView,
            layoutEngine: layoutEngine,
            rendererFactory: rendererFactory
        )
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func render() {
        // TODO check if we need to do something about after layout hooks
        // TODO improve rendering performance by avoiding allocations.
        // Renderers should be able to reuse view objects instead of having
        // to allocate new ones if possible.
        if let component = self.component, let componentMailbox = renderer?.render(component: component) {
            componentMailbox.forward(to: mailbox)
        }
    }
    
    
}

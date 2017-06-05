//
//  NavigationBarTitleRenderer.swift
//  PortalView
//
//  Created by Guido Marucci Blas on 2/14/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//

import UIKit

internal struct NavigationBarTitleRenderer<
    MessageType,
    RouteType: Route,
    CustomComponentRendererType: UIKitCustomComponentRenderer
    >
    
    where CustomComponentRendererType.MessageType == MessageType, CustomComponentRendererType.RouteType == RouteType {
    
    typealias CustomComponentRendererFactory = () -> CustomComponentRendererType
    typealias ActionType = Action<RouteType, MessageType>
    
    let navigationBarTitle: NavigationBarTitle<ActionType>
    let navigationItem: UINavigationItem
    let navigationBarSize: CGSize
    let rendererFactory: CustomComponentRendererFactory
    
    func render(with layoutEngine: LayoutEngine, isDebugModeEnabled: Bool) -> Mailbox<ActionType>? {
        switch navigationBarTitle {
            
        case .text(let title):
            navigationItem.title = title
            return .none
            
        case .image(let image):
            navigationItem.titleView = UIImageView(image: image.asUIImage)
            return .none
            
        case .component(let titleComponent):
            let titleView = UIView(frame: CGRect(origin: .zero, size: navigationBarSize))
            navigationItem.titleView = titleView
            var renderer = UIKitComponentRenderer<MessageType, RouteType, CustomComponentRendererType>(
                containerView: titleView,
                layoutEngine: layoutEngine,
                rendererFactory: rendererFactory
            )
            renderer.isDebugModeEnabled = isDebugModeEnabled
            return renderer.render(component: titleComponent)
        }
        
    }
    
}

extension UINavigationBar {
    
    internal func apply(style: StyleSheet<NavigationBarStyleSheet>) {
        self.barTintColor = style.base.backgroundColor.asUIColor
        self.tintColor = style.component.tintColor.asUIColor
        self.isTranslucent = style.component.isTranslucent
        var titleTextAttributes: [String : Any] = [
            NSForegroundColorAttributeName: style.component.titleTextColor.asUIColor
        ]
        let font = style.component.titleTextFont
        let fontSize = style.component.titleTextSize
        font.uiFont(withSize: fontSize) |> { titleTextAttributes[NSFontAttributeName] = $0 }
        self.titleTextAttributes = titleTextAttributes
    }
    
}

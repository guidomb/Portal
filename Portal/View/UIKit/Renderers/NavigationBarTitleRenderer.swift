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
    RouteType,
    CustomComponentRendererType: UIKitCustomComponentRenderer
    >
    
    where CustomComponentRendererType.MessageType == MessageType, CustomComponentRendererType.RouteType == RouteType {
    
    typealias ActionType = Action<RouteType, MessageType>
    typealias ComponentRenderer = UIKitComponentRenderer<MessageType, RouteType, CustomComponentRendererType>
    
    let renderer: ComponentRenderer
    
    func render(
        title navigationBarTitle: NavigationBarTitle<ActionType>,
        into navigationItem: UINavigationItem,
        navigationBarSize: CGSize) -> Mailbox<ActionType>? {
        switch navigationBarTitle {
            
        case .text(let title):
            navigationItem.title = title
            return .none
            
        case .image(let image):
            navigationItem.titleView = UIImageView(image: image.asUIImage)
            return .none
            
        case .component(let titleComponent):
            if let titleView = navigationItem.titleView {
                renderer.apply(changeSet: titleComponent.fullChangeSet, to: titleView)
                return .none
            } else {
                let titleView = UIView(frame: CGRect(origin: .zero, size: navigationBarSize))
                navigationItem.titleView = titleView
                return renderer.render(component: titleComponent, into: titleView)
            }
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

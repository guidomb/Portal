//
//  TableRenderer.swift
//  PortalView
//
//  Created by Guido Marucci Blas on 2/14/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//

import UIKit

internal struct TableRenderer<
    MessageType,
    RouteType,
    CustomComponentRendererType: UIKitCustomComponentRenderer
    >: UIKitRenderer
    
    where CustomComponentRendererType.MessageType == MessageType, CustomComponentRendererType.RouteType == RouteType {

    typealias CustomComponentRendererFactory = () -> CustomComponentRendererType
    typealias ActionType = Action<RouteType, MessageType>
    
    let properties: TableProperties<ActionType>
    let style: StyleSheet<TableStyleSheet>
    let layout: Layout
    let rendererFactory: CustomComponentRendererFactory
    
    func render(with layoutEngine: LayoutEngine, isDebugModeEnabled: Bool) -> Render<ActionType> {
        let table = PortalTableView<MessageType, RouteType, CustomComponentRendererType>(
            items: properties.items,
            layoutEngine: layoutEngine,
            rendererFactory: rendererFactory
        )
        
        properties.refresh |> {
            table.configRefresh(properties: $0, tintColor: style.component.refreshTintColor)
        }
        
        table.isDebugModeEnabled = isDebugModeEnabled
        table.showsVerticalScrollIndicator = properties.showsVerticalScrollIndicator
        table.showsHorizontalScrollIndicator = properties.showsHorizontalScrollIndicator
        
        table.apply(style: style.base)
        table.apply(style: style.component)
        layoutEngine.apply(layout: layout, to: table)
        
        return Render(view: table, mailbox: table.mailbox)
    }
    
}

extension UITableView {
    
    fileprivate func apply(style: TableStyleSheet) {
        self.separatorColor = style.separatorColor.asUIColor
    }
    
}

extension TableItemSelectionStyle {
    
    internal var asUITableViewCellSelectionStyle: UITableViewCellSelectionStyle {
        switch self {
        case .none:
            return .none
        case .`default`:
            return .`default`
        case .blue:
            return .blue
        case .gray:
            return .gray
        }
    }
    
}

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
    CustomComponentRendererType: UIKitCustomComponentRenderer>: UIKitRenderer
    
    where CustomComponentRendererType.MessageType == MessageType, CustomComponentRendererType.RouteType == RouteType {

    typealias CustomComponentRendererFactory = () -> CustomComponentRendererType
    typealias ActionType = Action<RouteType, MessageType>
    
    let properties: TableProperties<ActionType>
    let style: StyleSheet<TableStyleSheet>
    let layout: Layout
    let rendererFactory: CustomComponentRendererFactory
    
    func render(with layoutEngine: LayoutEngine, isDebugModeEnabled: Bool) -> Render<ActionType> {
        let table = PortalTableView<MessageType, RouteType, CustomComponentRendererType>(
            layoutEngine: layoutEngine,
            rendererFactory: rendererFactory
        )
        table.isDebugModeEnabled = isDebugModeEnabled
        let changeSet = TableChangeSet.fullChangeSet(properties: properties, style: style, layout: layout)
        
        return table.apply(changeSet: changeSet, layoutEngine: layoutEngine)
    }
    
}

extension PortalTableView {
    
    func apply(changeSet: TableChangeSet<ActionType>, layoutEngine: LayoutEngine) -> Render<ActionType> {
        apply(changeSet: changeSet.properties)
        apply(changeSet: changeSet.baseStyleSheet)
        apply(changeSet: changeSet.tableStyleSheet)
        layoutEngine.apply(changeSet: changeSet.layout, to: self)
        
        return Render<ActionType>(view: self, mailbox: mailbox, executeAfterLayout: .none)
    }
    
}

fileprivate extension PortalTableView {
    
    fileprivate func apply(changeSet: [TableProperties<ActionType>.Property]) {
        for property in changeSet {
            switch property {
                
            case .items(let items):
                setItems(items: items)
            
            case .showsHorizontalScrollIndicator(let enabled):
                showsHorizontalScrollIndicator = enabled
                
            case .showsVerticalScrollIndicator(let enabled):
                showsVerticalScrollIndicator = enabled
            }
        }
    }
    
    fileprivate func apply(changeSet: [TableStyleSheet.Property]) {
        for property in changeSet {
            switch property {
                
            case .separatorColor(let color):
                separatorColor = color.asUIColor
            }
        }
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

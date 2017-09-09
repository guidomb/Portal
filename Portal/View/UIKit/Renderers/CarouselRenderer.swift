//
//  CarouselRenderer.swift
//  PortalView
//
//  Created by Cristian Ames on 4/17/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//

import UIKit

internal struct CarouselRenderer<
    MessageType,
    RouteType,
    CustomComponentRendererType: UIKitCustomComponentRenderer
    >: UIKitRenderer
    
    where CustomComponentRendererType.MessageType == MessageType, CustomComponentRendererType.RouteType == RouteType {
    
    typealias CustomComponentRendererFactory = () -> CustomComponentRendererType
    typealias ActionType = Action<RouteType, MessageType>
    
    let properties: CarouselProperties<ActionType>
    let style: StyleSheet<EmptyStyleSheet>
    let layout: Layout
    let rendererFactory: CustomComponentRendererFactory
    
    func render(with layoutEngine: LayoutEngine, isDebugModeEnabled: Bool) -> Render<ActionType> {
        let carousel = PortalCarouselView(
            layoutEngine: layoutEngine,
            rendererFactory: rendererFactory
        )

        carousel.isDebugModeEnabled = isDebugModeEnabled
        let changeSet = CarouselChangeSet.fullChangeSet(properties: properties, style: style, layout: layout)
        
        return carousel.apply(changeSet: changeSet, layoutEngine: layoutEngine)
    }
    
}

extension PortalCarouselView {
    
    func apply(changeSet: CarouselChangeSet<ActionType>, layoutEngine: LayoutEngine) -> Render<ActionType> {
        apply(changeSet: changeSet.properties)
        apply(changeSet: changeSet.baseStyleSheet)
        layoutEngine.apply(changeSet: changeSet.layout, to: self)
        
        return Render<ActionType>(view: self, mailbox: getMailbox(), executeAfterLayout: .none)
    }
    
}

fileprivate extension PortalCarouselView {
    
    fileprivate func apply(changeSet: [CarouselProperties<ActionType>.Property]) {
        guard let layout = collectionViewLayout as? UICollectionViewFlowLayout else { return }
        
        for property in changeSet {
            switch property {
                
            case .isSnapToCellEnabled(let isSnapToCellEnabled):
                self.isSnapToCellEnabled = isSnapToCellEnabled
                
            case .items(let items):
                if let items = items {
                    setItems(items: items)
                } else {
                    setItems(items: [])
                }
                reloadData()
                
            case .itemsSize(let itemsSize):
                layout.itemSize = CGSize(width: CGFloat(itemsSize.width), height: CGFloat(itemsSize.height))
            
            case .minimumInteritemSpacing(let minimumInteritemSpacing):
                layout.minimumInteritemSpacing = CGFloat(minimumInteritemSpacing)
                
            case .minimumLineSpacing(let minimumLineSpacing):
                layout.minimumLineSpacing = CGFloat(minimumLineSpacing)
                
            case .onSelectionChange(let onSelectionChange):
                self.onSelectionChange = onSelectionChange
                
            case .sectionInset(let sectionInset):
                layout.sectionInset = UIEdgeInsets(
                    top: CGFloat(sectionInset.top),
                    left: CGFloat(sectionInset.left),
                    bottom: CGFloat(sectionInset.bottom),
                    right: CGFloat(sectionInset.right)
                )
                
            case .showsScrollIndicator(let showsScrollIndicator):
                self.showsHorizontalScrollIndicator = showsScrollIndicator
            }
        }
        
        layout.scrollDirection = .horizontal
        collectionViewLayout = layout
        showsVerticalScrollIndicator = false
    }
    
}

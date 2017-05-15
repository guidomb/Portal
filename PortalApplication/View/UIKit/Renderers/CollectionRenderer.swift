//
//  PortalCollectionView.swift
//  PortalView
//
//  Created by Argentino Ducret on 4/4/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//

import UIKit

internal struct CollectionRenderer<MessageType, CustomComponentRendererType: UIKitCustomComponentRenderer>: UIKitRenderer
    where CustomComponentRendererType.MessageType == MessageType {
    
    typealias CustomComponentRendererFactory = () -> CustomComponentRendererType
    
    let properties: CollectionProperties<MessageType>
    let style: StyleSheet<EmptyStyleSheet>
    let layout: Layout
    let rendererFactory: CustomComponentRendererFactory
    
    func render(with layoutEngine: LayoutEngine, isDebugModeEnabled: Bool) -> Render<MessageType> {
        let collectionView = PortalCollectionView(
            items: properties.items,
            layoutEngine: layoutEngine,
            layout: createFlowLayout(),
            rendererFactory: rendererFactory
        )
        
        collectionView.isDebugModeEnabled = isDebugModeEnabled
        collectionView.showsHorizontalScrollIndicator = properties.showsHorizontalScrollIndicator
        collectionView.showsVerticalScrollIndicator = properties.showsVerticalScrollIndicator
        
        collectionView.apply(style: style.base)
        layoutEngine.apply(layout: layout, to: collectionView)
        
        return Render(view: collectionView, mailbox: collectionView.mailbox)
    }
    
    func createFlowLayout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: CGFloat(properties.itemsWidth), height: CGFloat(properties.itemsHeight))
        layout.minimumInteritemSpacing = CGFloat(properties.minimumInteritemSpacing)
        layout.minimumLineSpacing = CGFloat(properties.minimumLineSpacing)
        layout.sectionInset = UIEdgeInsets(
            top: CGFloat(properties.sectionInset.top),
            left: CGFloat(properties.sectionInset.left),
            bottom: CGFloat(properties.sectionInset.bottom),
            right: CGFloat(properties.sectionInset.right)
        )
        
        switch properties.scrollDirection {
        case .horizontal:
            layout.scrollDirection = .horizontal
        default:
            layout.scrollDirection = .vertical
        }
        
        return layout
    }
}


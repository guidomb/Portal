//
//  CarouselRenderer.swift
//  PortalView
//
//  Created by Cristian Ames on 4/17/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//

import UIKit

extension PortalCarouselView {
    
    func apply(changeSet: CarouselChangeSet<ActionType>, layoutEngine: LayoutEngine) -> Render<ActionType> {
        apply(changeSet: changeSet.properties)
        apply(changeSet: changeSet.baseStyleSheet)
        layoutEngine.apply(changeSet: changeSet.layout, to: self)
        
        return Render<ActionType>(view: self, mailbox: mailbox, executeAfterLayout: .none)
    }
    
}

fileprivate extension PortalCarouselView {
    
    // swiftlint:disable cyclomatic_complexity
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
    // swiftlint:enable cyclomatic_complexity
    
}

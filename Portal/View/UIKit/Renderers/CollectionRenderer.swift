//
//  PortalCollectionView.swift
//  PortalView
//
//  Created by Argentino Ducret on 4/4/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//

import UIKit

extension PortalCollectionView {
    
    func apply(
        changeSet: CollectionChangeSet<ActionType>,
        layoutEngine: LayoutEngine) -> Render<ActionType> {
        
        apply(changeSet: changeSet.properties)
        apply(changeSet: changeSet.baseStyleSheet)
        apply(changeSet: changeSet.collectionStyleSheet)
        layoutEngine.apply(changeSet: changeSet.layout, to: self)

        return Render<ActionType>(view: self, mailbox: mailbox, executeAfterLayout: .none)
    }
    
}

fileprivate extension PortalCollectionView {
    
    // swiftlint:disable cyclomatic_complexity
    fileprivate func apply(changeSet: [CollectionProperties<ActionType>.Property]) {
        guard let layout = collectionViewLayout as? UICollectionViewFlowLayout else { return }

        for propertiy in changeSet {
            switch propertiy {
                
            case .items(let items):
                setItems(items: items)
                reloadData()
                
            case .itemsSize(let itemsSize):
                layout.itemSize = CGSize(width: CGFloat(itemsSize.width), height: CGFloat(itemsSize.height))
                
            case .minimumInteritemSpacing(let minimumInteritemSpacing):
                layout.minimumInteritemSpacing = CGFloat(minimumInteritemSpacing)
                
            case .minimumLineSpacing(let minimumLineSpacing):
                layout.minimumLineSpacing = CGFloat(minimumLineSpacing)
                
            case .scrollDirection(let scrollDirection):
                switch scrollDirection {
                
                case .horizontal:
                    layout.scrollDirection = .horizontal
                
                case .vertical:
                    layout.scrollDirection = .vertical
                }
                
            case .sectionInset(let sectionInset):
                layout.sectionInset = UIEdgeInsets(
                    top: CGFloat(sectionInset.top),
                    left: CGFloat(sectionInset.left),
                    bottom: CGFloat(sectionInset.bottom),
                    right: CGFloat(sectionInset.right)
                )
                
            case .showsHorizontalScrollIndicator(let showsHorizontalScrollIndicator):
                self.showsHorizontalScrollIndicator = showsHorizontalScrollIndicator
                
            case .showsVerticalScrollIndicator(let showsVerticalScrollIndicator):
                self.showsVerticalScrollIndicator = showsVerticalScrollIndicator
                
            case .refresh(let maybeRefreshProperties):
                if let refreshProperties = maybeRefreshProperties {
                    self.configure(pullToRefresh: refreshProperties, offset: scrollView.contentOffset)
                } else {
                    self.removePullToRefresh()
                }
            
            case .paging(let isPagingEnabled):
                self.isPagingEnabled = isPagingEnabled
            }
        }

        if layout.scrollDirection == .horizontal {
            removePullToRefresh()
            alwaysBounceVertical = false
        }
    
        collectionViewLayout = layout
    }
    // swiftlint:enable cyclomatic_complexity
    
    fileprivate func apply(changeSet: [CollectionStyleSheet.Property]) {
        for property in changeSet {
            switch property {
                
            case .refreshTintColor(let refreshTintColor):
                self.scrollView.refreshControl?.tintColor = refreshTintColor.asUIColor
                
            }
        }
    }
    
}

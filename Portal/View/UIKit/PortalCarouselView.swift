//
//  PortalCarouselView.swift
//  PortalView
//
//  Created by Cristian Ames on 4/17/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//
import UIKit

public final class PortalCarouselView<
    MessageType,
    RouteType,
    CustomComponentRendererType: UIKitCustomComponentRenderer
    >: PortalCollectionView<MessageType, RouteType, CustomComponentRendererType>
    
    where CustomComponentRendererType.MessageType == MessageType, CustomComponentRendererType.RouteType == RouteType {
    
    public typealias ActionType = Action<RouteType, MessageType>
    
    public var isSnapToCellEnabled: Bool = false
    public var onSelectionChange: (ZipListShiftOperation) -> ActionType? = { _ in .none }
    
    fileprivate var lastOffset: CGFloat = 0
    fileprivate var selectedIndex: Int = 0
    
    public override init(renderer: ComponentRenderer) {
        super.init(renderer: renderer)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func setItems(items: ZipList<CarouselItemProperties<ActionType>>) {
        setItems(items: items.map(transform))
        selectedIndex = Int(items.centerIndex)
        scrollToItem(self.selectedIndex, animated: false)
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        lastOffset = scrollView.contentOffset.x
    }
    
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint,
                                          targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        // At this moment we only support the message feature with the snap mode on.
        // TODO: Add support for messaging regardless the snap mode. 
        // To do this feature we should detect the item selected not by adding or 
        // supressing one to the index but searching the active item in the screen 
        // at that moment. We could use `indexPathForItemAtPoint` for this purpose.
        guard isSnapToCellEnabled else { return }
        
        let currentOffset = CGFloat(scrollView.contentOffset.x)
        
        if currentOffset == lastOffset {
            return
        }
       
        let lastPosition = selectedIndex
        if currentOffset > lastOffset {
            if lastPosition < items.count - 1 {
                selectedIndex = lastPosition + 1
                scrollToItem(selectedIndex, animated: true) // Move to the right
                onSelectionChange(.left(count: 1)) |> { mailbox.dispatch(message: $0) }
            }
        } else if currentOffset < lastOffset {
            if lastPosition >= 1 {
                selectedIndex = lastPosition - 1
                scrollToItem(selectedIndex, animated: true) // Move to the left
                onSelectionChange(.right(count: 1)) |> { mailbox.dispatch(message: $0) }
            }
        }
    }
    
}

fileprivate extension PortalCarouselView {
    
    fileprivate func scrollToItem(_ position: Int, animated: Bool) {
        DispatchQueue.main.async {
            let indexPath = IndexPath(item: position, section: 0)
            self.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: animated)
        }
    }
    
    fileprivate func shiftDirection(actual: Int, old: Int) -> ZipListShiftOperation? {
        if actual < old {
            return ZipListShiftOperation.left(count: UInt(old - actual))
        } else if actual > old {
            return ZipListShiftOperation.right(count: UInt(actual - old))
        } else {
            return .none
        }
    }
    
    fileprivate func transform(item: CarouselItemProperties<ActionType>) -> CollectionItemProperties<ActionType> {
        return collectionItem(
            onTap: item.onTap,
            identifier: item.identifier,
            renderer: item.renderer
        )
    }
    
}

//
//  PortalCollectionView.swift
//  PortalView
//
//  Created by Argentino Ducret on 4/4/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//

import UIKit

public class PortalCollectionView<
    MessageType,
    RouteType,
    CustomComponentRendererType: UIKitCustomComponentRenderer
    >: UICollectionView, UICollectionViewDataSource, UICollectionViewDelegate, PullToRefreshable
    
    where CustomComponentRendererType.MessageType == MessageType, CustomComponentRendererType.RouteType == RouteType {
    
    public typealias ActionType = Action<RouteType, MessageType>
    public typealias ComponentRenderer = UIKitComponentRenderer<MessageType, RouteType, CustomComponentRendererType>
    
    public let mailbox = Mailbox<ActionType>()
    
    internal private(set) var items: [CollectionItemProperties<ActionType>]
    
    fileprivate let renderer: ComponentRenderer
    
    public init(renderer: ComponentRenderer) {
        self.items = []
        self.renderer = renderer
        super.init(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
   
        self.dataSource = self
        self.delegate = self
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    internal func setItems(items: [CollectionItemProperties<ActionType>]) {
        self.items = items
        
        let identifiers = Set(items.map { $0.identifier })
        identifiers.forEach { register(UICollectionViewCell.self, forCellWithReuseIdentifier: $0) }
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    public func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let item = items[indexPath.row]
        let cell = dequeueReusableCell(withReuseIdentifier: item.identifier, for: indexPath)
        cell.forwardMailbox(to: mailbox)
        let cellComponent = itemRender(at: indexPath)
        _ = renderer.render(component: cellComponent, into: cell.contentView)
        
        return cell
    }
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = items[indexPath.row]
        item.onTap |> { mailbox.dispatch(message: $0) }
    }
    
    //These empty methods are required to be overriten to allow child classes to implement them
    //It seems to be a bug in swift's dispatching system where half the delegate's methods are in the
    //parent class and the second half on the child class, the child class methods are never called
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView,
                                          withVelocity velocity: CGPoint,
                                          targetContentOffset: UnsafeMutablePointer<CGPoint>) {
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
    }
    
}

fileprivate extension PortalCollectionView {
    
    fileprivate func itemRender(at indexPath: IndexPath) -> Component<ActionType> {
        // TODO cache the result of calling renderer. Once the diff algorithm is implemented find a way to only
        // replace items that have changed.
        // IGListKit uses some library or algorithm to diff array. Maybe that can be used to make the array diff
        // more efficient.
        //
        // https://github.com/Instagram/IGListKit
        //
        // Check the video of the talk that presents IGListKit to find the array diff algorithm.
        // Also there is Dwifft which seems to be based in the same algorithm:
        //
        // https://github.com/jflinter/Dwifft
        //
        let item = items[indexPath.row]
        return item.renderer()
    }
    
}

private let isMailboxForwardedTagValue = 10101

fileprivate extension UICollectionViewCell {
    
    var isMailboxForwarded: Bool {
        get {
            return self.tag == isMailboxForwardedTagValue
        }
        set {
            self.tag = newValue ? isMailboxForwardedTagValue : 0
        }
    }
    
    func forwardMailbox<MessageType>(to mailbox: Mailbox<MessageType>) {
        guard !isMailboxForwarded else { return }
        self.contentView.getMailbox().forward(to: mailbox)
        self.isMailboxForwarded = true
    }
    
}

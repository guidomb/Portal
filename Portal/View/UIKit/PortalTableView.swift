//
//  PortalTableView.swift
//  PortalView
//
//  Created by Guido Marucci Blas on 2/14/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//

import UIKit

public final class PortalTableView<
    MessageType,
    RouteType: Route,
    CustomComponentRendererType: UIKitCustomComponentRenderer
    >: UITableView, UITableViewDataSource, UITableViewDelegate
    
where CustomComponentRendererType.MessageType == MessageType, CustomComponentRendererType.RouteType == RouteType {
    
    public typealias CustomComponentRendererFactory = () -> CustomComponentRendererType
    public typealias ActionType = Action<RouteType, MessageType>
    public typealias TableViewCell = PortalTableViewCell<MessageType, RouteType, CustomComponentRendererType>
    
    public let mailbox = Mailbox<ActionType>()
    public var isDebugModeEnabled: Bool = false
    
    fileprivate let rendererFactory: CustomComponentRendererFactory
    fileprivate let layoutEngine: LayoutEngine
    fileprivate let items: [TableItemProperties<ActionType>]
    
    // Used to cache cell actual height after rendering table
    // item component. Caching cell height is usefull when
    // cells have dynamic height.
    fileprivate var cellHeights: [CGFloat?]
    
    public init(
        items: [TableItemProperties<ActionType>],
        layoutEngine: LayoutEngine,
        rendererFactory: @escaping CustomComponentRendererFactory) {
        self.rendererFactory = rendererFactory
        self.items = items
        self.layoutEngine = layoutEngine
        self.cellHeights = Array(repeating: .none, count: items.count)
        
        super.init(frame: .zero, style: .plain)
        
        self.dataSource = self
        self.delegate = self
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = items[indexPath.row]
        let cellRender = itemRender(at: indexPath)
        let cell = dequeueReusableCell(with: cellRender.typeIdentifier)
        cell.component = cellRender.component
        
        let componentHeight = cell.component?.layout.height
        if componentHeight?.value == .none && componentHeight?.maximum == .none {
            print(  "WARNING: Table item component with identifier '\(cellRender.typeIdentifier)' does not " +
                    "specify layout height! You need to either set layout.height.value or layout.height.maximum")
        }
        
        // For some reason the first page loads its cells with smaller bounds.
        // This forces the cell to have the width of its parent view.
        if let width = self.superview?.bounds.width {
            let baseHeight = itemBaseHeight(at: indexPath)
            cell.bounds.size.width = width
            cell.bounds.size.height = baseHeight
            cell.contentView.bounds.size.width = width
            cell.contentView.bounds.size.height = baseHeight
        }
        
        cell.selectionStyle = item.onTap.map { _ in item.selectionStyle.asUITableViewCellSelectionStyle } ?? .none
        cell.isDebugModeEnabled = isDebugModeEnabled
        cell.render()
        
        // After rendering the cell, the parent view returned by rendering the
        // item component has the actual height calculated after applying layout.
        // This height needs to be cached in order to be returned in the
        // UITableViewCellDelegate's method tableView(_,heightForRowAt:)
        let actualCellHeight = cell.contentView.subviews[0].bounds.height
        cellHeights[indexPath.row] = actualCellHeight
        cell.bounds.size.height = actualCellHeight
        cell.contentView.bounds.size.height = actualCellHeight
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return itemBaseHeight(at: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = items[indexPath.row]
        item.onTap |> { mailbox.dispatch(message: $0) }
    }
    
}

fileprivate extension PortalTableView {
    
    fileprivate func dequeueReusableCell(with identifier: String) ->
        PortalTableViewCell<MessageType, RouteType, CustomComponentRendererType> {
            
        if let cell = dequeueReusableCell(withIdentifier: identifier) as? TableViewCell {
            return cell
        } else {
            let cell = TableViewCell(
                reuseIdentifier: identifier,
                layoutEngine: layoutEngine,
                rendererFactory: rendererFactory
            )
            cell.mailbox.forward(to: mailbox)
            return cell
        }
    }
    
    fileprivate func itemRender(at indexPath: IndexPath) -> TableItemRender<ActionType> {
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
        return item.renderer(item.height)
    }
    
    fileprivate func itemMaxHeight(at indexPath: IndexPath) -> CGFloat {
        return CGFloat(items[indexPath.row].height)
    }
    
    /// Returns the cached actual height for the item at the given `indexPath`.
    /// Actual heights are cached using the `cellHeights` instance variable and
    /// are calculated after rending the item component inside the table view cell.
    /// This is usefull when cells have dynamic height.
    ///
    /// - Parameter indexPath: The item's index path.
    /// - Returns: The cached actual item height.
    fileprivate func itemActualHeight(at indexPath: IndexPath) -> CGFloat? {
        return cellHeights[indexPath.row]
    }
    
    /// Returns the item's cached actual height if available. Otherwise it
    /// returns the item's max height.
    ///
    /// - Parameter indexPath: The item's index path.
    /// - Returns: the item's cached actual height or its max height.
    fileprivate func itemBaseHeight(at indexPath: IndexPath) -> CGFloat {
        return itemActualHeight(at: indexPath) ?? itemMaxHeight(at: indexPath)
    }
    
}

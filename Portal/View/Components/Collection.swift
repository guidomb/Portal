//
//  CollectionView.swift
//  PortalView
//
//  Created by Argentino Ducret on 4/4/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//

import Foundation
import UIKit

public class SectionInset {
    public static let zero = SectionInset(top: 0, left: 0, bottom: 0, right: 0)
    
    public var bottom: UInt
    public var top: UInt
    public var left: UInt
    public var right: UInt
    
    public init(top: UInt, left: UInt, bottom: UInt, right: UInt) {
        self.bottom = bottom
        self.top = top
        self.left = left
        self.right = right
    }
    
}

public enum CollectionScrollDirection {
    case horizontal
    case vertical
}

public struct CollectionProperties<MessageType> {
    
    public var items: [CollectionItemProperties<MessageType>]
    public var showsVerticalScrollIndicator: Bool
    public var showsHorizontalScrollIndicator: Bool
    
    // Layout properties
    public var itemsWidth: UInt
    public var itemsHeight: UInt
    public var minimumInteritemSpacing: UInt
    public var minimumLineSpacing: UInt
    public var scrollDirection: CollectionScrollDirection
    public var sectionInset: SectionInset
    
    fileprivate init(
        items: [CollectionItemProperties<MessageType>] = [],
        showsVerticalScrollIndicator: Bool = false,
        showsHorizontalScrollIndicator: Bool = false,
        itemsWidth: UInt,
        itemsHeight: UInt,
        minimumInteritemSpacing: UInt = 0,
        minimumLineSpacing: UInt = 0,
        scrollDirection: CollectionScrollDirection = .vertical,
        sectionInset: SectionInset = .zero) {
        self.items = items
        self.showsVerticalScrollIndicator = showsVerticalScrollIndicator
        self.showsHorizontalScrollIndicator = showsHorizontalScrollIndicator
        self.itemsWidth = itemsWidth
        self.itemsHeight = itemsHeight
        self.minimumLineSpacing = minimumLineSpacing
        self.minimumInteritemSpacing = minimumInteritemSpacing
        self.sectionInset = sectionInset
        self.scrollDirection = scrollDirection
    }
    
    public func map<NewMessageType>(
        _ transform: @escaping (MessageType) -> NewMessageType) -> CollectionProperties<NewMessageType> {
        return CollectionProperties<NewMessageType>(
            items: self.items.map { $0.map(transform) },
            showsVerticalScrollIndicator: self.showsVerticalScrollIndicator,
            showsHorizontalScrollIndicator: self.showsHorizontalScrollIndicator,
            itemsWidth: self.itemsWidth,
            itemsHeight: self.itemsHeight,
            minimumInteritemSpacing: self.minimumInteritemSpacing,
            minimumLineSpacing: self.minimumLineSpacing,
            scrollDirection: self.scrollDirection,
            sectionInset: self.sectionInset)
    }
    
}

public struct CollectionItemProperties<MessageType> {
    
    public typealias Renderer = () -> Component<MessageType>
    
    public let onTap: MessageType?
    public let renderer: Renderer
    public let identifier: String
    
    fileprivate init(
        onTap: MessageType?,
        identifier: String,
        renderer: @escaping Renderer) {
        self.onTap = onTap
        self.renderer = renderer
        self.identifier = identifier
    }
    
}

extension CollectionItemProperties {
    
    public func map<NewMessageType>(
        _ transform: @escaping (MessageType) -> NewMessageType) -> CollectionItemProperties<NewMessageType> {
        return CollectionItemProperties<NewMessageType>(
            onTap: self.onTap.map(transform),
            identifier: self.identifier,
            renderer: { self.renderer().map(transform) }
        )
    }
    
}

public func collection<MessageType>(
    properties: CollectionProperties<MessageType>,
    style: StyleSheet<EmptyStyleSheet> = EmptyStyleSheet.default,
    layout: Layout = layout()) -> Component<MessageType> {
    return .collection(properties, style, layout)
}

public func collectionItem<MessageType>(
    onTap: MessageType? = .none,
    identifier: String,
    renderer: @escaping CollectionItemProperties<MessageType>.Renderer) -> CollectionItemProperties<MessageType> {
    return CollectionItemProperties(onTap: onTap, identifier: identifier, renderer: renderer)
}

public func properties<MessageType>(
    itemsWidth: UInt,
    itemsHeight: UInt,
    configure: (inout CollectionProperties<MessageType>) -> ()) -> CollectionProperties<MessageType> {
    var properties = CollectionProperties<MessageType>(itemsWidth: itemsWidth, itemsHeight: itemsHeight)
    configure(&properties)
    return properties
}

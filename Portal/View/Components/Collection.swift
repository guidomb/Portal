//
//  CollectionView.swift
//  PortalView
//
//  Created by Argentino Ducret on 4/4/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//

import Foundation
import UIKit

public class SectionInset: AutoEquatable {
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

public struct CollectionProperties<MessageType>: AutoPropertyDiffable {
    
    // sourcery: skipDiff
    public var items: [CollectionItemProperties<MessageType>]
    public var showsVerticalScrollIndicator: Bool
    public var showsHorizontalScrollIndicator: Bool
    // sourcery: skipDiff
    public var refresh: RefreshProperties<MessageType>?
    
    // Layout properties
    public var itemsSize: Size
    public var minimumInteritemSpacing: UInt
    public var minimumLineSpacing: UInt
    public var scrollDirection: CollectionScrollDirection
    public var sectionInset: SectionInset
    public var paging: Bool
    
    fileprivate init(
        items: [CollectionItemProperties<MessageType>] = [],
        showsVerticalScrollIndicator: Bool = false,
        showsHorizontalScrollIndicator: Bool = false,
        itemsSize: Size,
        refresh: RefreshProperties<MessageType>? = .none,
        minimumInteritemSpacing: UInt = 0,
        minimumLineSpacing: UInt = 0,
        scrollDirection: CollectionScrollDirection = .vertical,
        sectionInset: SectionInset = .zero,
        paging: Bool = false) {
        self.items = items
        self.showsVerticalScrollIndicator = showsVerticalScrollIndicator
        self.showsHorizontalScrollIndicator = showsHorizontalScrollIndicator
        self.itemsSize = itemsSize
        self.refresh = refresh
        self.minimumLineSpacing = minimumLineSpacing
        self.minimumInteritemSpacing = minimumInteritemSpacing
        self.sectionInset = sectionInset
        self.scrollDirection = scrollDirection
        self.paging = paging
    }
    
    public func map<NewMessageType>(
        _ transform: @escaping (MessageType) -> NewMessageType) -> CollectionProperties<NewMessageType> {
        return CollectionProperties<NewMessageType>(
            items: self.items.map { $0.map(transform) },
            showsVerticalScrollIndicator: self.showsVerticalScrollIndicator,
            showsHorizontalScrollIndicator: self.showsHorizontalScrollIndicator,
            itemsSize: self.itemsSize,
            refresh: self.refresh.map { $0.map(transform) },
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
    style: StyleSheet<CollectionStyleSheet> = CollectionStyleSheet.default,
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
    configure: (inout CollectionProperties<MessageType>) -> Void) -> CollectionProperties<MessageType> {
    var properties = CollectionProperties<MessageType>(
        itemsSize: Size(width: itemsWidth, height: itemsHeight)
    )
    configure(&properties)
    return properties
}

// MARK: - Style sheet

public struct CollectionStyleSheet: AutoPropertyDiffable {
    
    public static let `default` = StyleSheet<CollectionStyleSheet>(component: CollectionStyleSheet())
    
    public var refreshTintColor: Color
    
    fileprivate init(refreshTintColor: Color = .gray) {
        self.refreshTintColor = refreshTintColor
    }
    
}

public func collectionStyleSheet(
    configure: (inout BaseStyleSheet, inout CollectionStyleSheet) -> Void = { _ in })
    -> StyleSheet<CollectionStyleSheet> {
    var base = BaseStyleSheet()
    var component = CollectionStyleSheet()
    configure(&base, &component)
    return StyleSheet(component: component, base: base)
}

// MARK: - ChangeSet

public struct CollectionChangeSet<MessageType> {
    
    static func fullChangeSet(
        properties: CollectionProperties<MessageType>,
        style: StyleSheet<CollectionStyleSheet>,
        layout: Layout) -> CollectionChangeSet<MessageType> {
        return CollectionChangeSet(
            properties: properties.fullChangeSet,
            baseStyleSheet: style.base.fullChangeSet,
            collectionStyleSheet: style.component.fullChangeSet,
            layout: layout.fullChangeSet
        )
    }
    
    let properties: [CollectionProperties<MessageType>.Property]
    let baseStyleSheet: [BaseStyleSheet.Property]
    let collectionStyleSheet: [CollectionStyleSheet.Property]
    let layout: [Layout.Property]
    
    var isEmpty: Bool {
        return  properties.isEmpty              &&
                baseStyleSheet.isEmpty          &&
                collectionStyleSheet.isEmpty    &&
                layout.isEmpty
    }
    
    init(
        properties: [CollectionProperties<MessageType>.Property] = [],
        baseStyleSheet: [BaseStyleSheet.Property] = [],
        collectionStyleSheet: [CollectionStyleSheet.Property] = [],
        layout: [Layout.Property] = []) {
        self.properties = properties
        self.baseStyleSheet = baseStyleSheet
        self.collectionStyleSheet = collectionStyleSheet
        self.layout = layout
    }
    
}

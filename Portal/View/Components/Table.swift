//
//  Table.swift
//  PortalView
//
//  Created by Guido Marucci Blas on 1/27/17.
//
//

import Foundation

public enum TableItemSelectionStyle {
    
    case none
    case `default`
    case blue
    case gray
    
}

public struct TableProperties<MessageType> {
    
    public var items: [TableItemProperties<MessageType>]
    public var showsVerticalScrollIndicator: Bool
    public var showsHorizontalScrollIndicator: Bool
    
    fileprivate init(
        items: [TableItemProperties<MessageType>] = [],
        showsVerticalScrollIndicator: Bool = true,
        showsHorizontalScrollIndicator: Bool = true) {
        self.items = items
        self.showsHorizontalScrollIndicator = showsHorizontalScrollIndicator
        self.showsVerticalScrollIndicator = showsVerticalScrollIndicator
    }
    
    public func map<NewMessageType>(
        _ transform: @escaping (MessageType) -> NewMessageType) -> TableProperties<NewMessageType> {
        return TableProperties<NewMessageType>(items: self.items.map { $0.map(transform) })
    }
    
}

public struct TableItemProperties<MessageType> {
    
    public typealias Renderer = (UInt) -> TableItemRender<MessageType>
    
    public let height: UInt
    public let onTap: MessageType?
    public let selectionStyle: TableItemSelectionStyle
    public let renderer: Renderer
    
    fileprivate init(
        height: UInt,
        onTap: MessageType?,
        selectionStyle: TableItemSelectionStyle,
        renderer: @escaping Renderer) {
        self.height = height
        self.onTap = onTap
        self.selectionStyle = selectionStyle
        self.renderer = renderer
    }
    
}

extension TableItemProperties {

    public func map<NewMessageType>(
        _ transform: @escaping (MessageType) -> NewMessageType) -> TableItemProperties<NewMessageType> {
        return TableItemProperties<NewMessageType>(
            height: height,
            onTap: self.onTap.map(transform),
            selectionStyle: selectionStyle,
            renderer: { self.renderer($0).map(transform) }
        )
    }
    
}

public struct TableItemRender<MessageType> {
    
    public let component: Component<MessageType>
    public let typeIdentifier: String
    
    public init(component: Component<MessageType>, typeIdentifier: String) {
        self.component = component
        self.typeIdentifier = typeIdentifier
    }
    
}

extension TableItemRender {

    public func map<NewMessageType>(
        _ transform: @escaping (MessageType) -> NewMessageType) -> TableItemRender<NewMessageType> {
        return TableItemRender<NewMessageType>(
            component: self.component.map(transform),
            typeIdentifier: self.typeIdentifier
        )
    }
    
}

public func table<MessageType>(
    properties: TableProperties<MessageType> = TableProperties(),
    style: StyleSheet<TableStyleSheet> = TableStyleSheet.default,
    layout: Layout = layout()) -> Component<MessageType> {
    return .table(properties, style, layout)
}

public func table<MessageType>(
    items: [TableItemProperties<MessageType>] = [],
    style: StyleSheet<TableStyleSheet> = TableStyleSheet.default,
    layout: Layout = layout()) -> Component<MessageType> {
    return .table(TableProperties(items: items), style, layout)
}

public func tableItem<MessageType>(
    height: UInt,
    onTap: MessageType? = .none,
    selectionStyle: TableItemSelectionStyle = .`default`,
    renderer: @escaping TableItemProperties<MessageType>.Renderer) -> TableItemProperties<MessageType> {
    return TableItemProperties(height: height, onTap: onTap, selectionStyle: selectionStyle, renderer: renderer)
}

public func properties<MessageType>(
    configure: (inout TableProperties<MessageType>) -> ()) -> TableProperties<MessageType> {
    var properties = TableProperties<MessageType>()
    configure(&properties)
    return properties
}

// MARK: - Style sheet

public struct TableStyleSheet {
    
    public static let `default` = StyleSheet<TableStyleSheet>(component: TableStyleSheet())
    
    public var separatorColor: Color
    
    fileprivate init(separatorColor: Color = Color.clear) {
        self.separatorColor = separatorColor
    }
    
}

public func tableStyleSheet(
    configure: (inout BaseStyleSheet, inout TableStyleSheet) -> () = { _ in }) -> StyleSheet<TableStyleSheet> {
    var base = BaseStyleSheet()
    var component = TableStyleSheet()
    configure(&base, &component)
    return StyleSheet(component: component, base: base)
}

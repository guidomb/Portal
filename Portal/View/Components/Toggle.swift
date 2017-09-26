//
//  Toggle.swift
//  Portal
//
//  Created by Juan Franco Caracciolo on 8/16/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//

import Foundation

public struct ToggleProperties<MessageType>: AutoPropertyDiffable {
    
    public var isOn: Bool
    public var isActive: Bool
    public var isEnabled: Bool
    // sourcery: skipDiff
    public var onSwitch: (Bool) -> MessageType?
    
    fileprivate init(
        isOn: Bool = false,
        isActive: Bool = false,
        isEnabled: Bool = true,
        onSwitch: @escaping (Bool) -> MessageType? = { _ in return .none }
        ) {
        self.isOn = isOn
        self.isActive = isActive
        self.isEnabled = isEnabled
        self.onSwitch = onSwitch 
    }
    
}

public extension ToggleProperties {
    
    public func map<NewMessageType>(
        _ transform: @escaping (MessageType) -> NewMessageType) -> ToggleProperties<NewMessageType> {
        return ToggleProperties<NewMessageType>(
            isOn: self.isOn,
            isActive: self.isActive,
            isEnabled: self.isEnabled,
            onSwitch: { self.onSwitch($0).map(transform) }
        )
    }
    
}

public func toggle<MessageType>(
        isOn: Bool,
        onSwitch: @escaping (Bool) -> MessageType? = { _ in return .none },
        style: StyleSheet<ToggleStyleSheet> = ToggleStyleSheet.defaultStyleSheet,
        layout: Layout = layout()) -> Component<MessageType> {
    return .toggle(ToggleProperties<MessageType>(isOn: isOn, onSwitch: onSwitch), style, layout)
}

public func toggle<MessageType>(
    properties: ToggleProperties<MessageType>,
    style: StyleSheet<ToggleStyleSheet> = ToggleStyleSheet.defaultStyleSheet,
    layout: Layout = layout()) -> Component<MessageType> {
    return .toggle(properties, style, layout)
}

public func properties<MessageType>(
    configure: (inout ToggleProperties<MessageType>) -> Void) -> ToggleProperties<MessageType> {
    var properties = ToggleProperties<MessageType>()
    configure(&properties)
    return properties
}

public struct ToggleStyleSheet: AutoPropertyDiffable {
    
    public static let defaultStyleSheet = StyleSheet<ToggleStyleSheet>(component: ToggleStyleSheet())
    
    public var onTintColor: Color?
    public var tintChangingColor: Color?
    public var thumbTintColor: Color?
    
    public init(
        onTintColor: Color? = .none,
        tintChangingColor: Color? = .none,
        thumbTintColor: Color? = .none
        ) {
        self.onTintColor = onTintColor
        self.tintChangingColor = tintChangingColor
        self.thumbTintColor = thumbTintColor
    }
    
}

public func toggleStyleSheet(
    configure: (inout BaseStyleSheet, inout ToggleStyleSheet) -> Void) -> StyleSheet<ToggleStyleSheet> {
    var base = BaseStyleSheet()
    var custom = ToggleStyleSheet()
    configure(&base, &custom)
    return StyleSheet(component: custom, base: base)
}

// MARK: - Change set

public struct ToggleChangeSet<MessageType> {
    
    static func fullChangeSet(
        properties: ToggleProperties<MessageType>,
        style: StyleSheet<ToggleStyleSheet>,
        layout: Layout) -> ToggleChangeSet<MessageType> {
        return ToggleChangeSet(
            properties: properties.fullChangeSet,
            baseStyleSheet: style.base.fullChangeSet,
            toggleStyleSheet: style.component.fullChangeSet,
            layout: layout.fullChangeSet
        )
    }
    
    let properties: [ToggleProperties<MessageType>.Property]
    let baseStyleSheet: [BaseStyleSheet.Property]
    let toggleStyleSheet: [ToggleStyleSheet.Property]
    let layout: [Layout.Property]
    
    var isEmpty: Bool {
        return  properties.isEmpty      &&
            baseStyleSheet.isEmpty      &&
            toggleStyleSheet.isEmpty    &&
            layout.isEmpty
    }
    
    init(
        properties: [ToggleProperties<MessageType>.Property] = [],
        baseStyleSheet: [BaseStyleSheet.Property] = [],
        toggleStyleSheet: [ToggleStyleSheet.Property] = [],
        layout: [Layout.Property] = []) {
        self.properties = properties
        self.baseStyleSheet = baseStyleSheet
        self.toggleStyleSheet = toggleStyleSheet
        self.layout = layout
    }
    
}

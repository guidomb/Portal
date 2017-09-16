//
//  MapView.swift
//  Portal
//
//  Created by Guido Marucci Blas on 12/19/16.
//  Copyright © 2016 Guido Marucci Blas. All rights reserved.
//

import Foundation

public struct Coordinates: AutoEquatable {
    
    public var latitude: Double
    public var longitude: Double
    
    public init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
    
}

public struct MapPlacemark: AutoEquatable {
    
    public let coordinates: Coordinates
    public let icon: Image?
    
    public init(coordinates: Coordinates, icon: Image? = .none) {
        self.coordinates = coordinates
        self.icon = icon
    }
    
}

public struct MapProperties: AutoPropertyDiffable {
    
    public var placemarks: [MapPlacemark]
    public var center: Coordinates?
    public var isZoomEnabled: Bool
    public var zoomLevel: Double
    public var isScrollEnabled: Bool
    
    public init(
        placemarks: [MapPlacemark] = [],
        center: Coordinates? = .none,
        isZoomEnabled: Bool = true,
        zoomLevel: Double = 1.0,
        isScrollEnabled: Bool = true) {
        self.placemarks = placemarks
        self.isZoomEnabled = isZoomEnabled
        self.zoomLevel = zoomLevel
        self.center = center
        self.isScrollEnabled = isScrollEnabled
    }
    
}

public func mapView<MessageType>(
    properties: MapProperties = MapProperties(),
    style: StyleSheet<EmptyStyleSheet> = EmptyStyleSheet.`default`,
    layout: Layout = layout()) -> Component<MessageType> {
    return .mapView(properties, style, layout)
}

public func mapView<MessageType>(
    placemarks: [MapPlacemark] = [],
    style: StyleSheet<EmptyStyleSheet> = EmptyStyleSheet.`default`,
    layout: Layout = layout()) -> Component<MessageType> {
    return .mapView(MapProperties(placemarks: placemarks), style, layout)
}

public func properties(configure: (inout MapProperties) -> Void) -> MapProperties {
    var properties = MapProperties()
    configure(&properties)
    return properties
}

// MARK: - ChangeSet

public struct MapViewChangeSet {
    
    static func fullChangeSet(
        properties: MapProperties,
        style: StyleSheet<EmptyStyleSheet>,
        layout: Layout) -> MapViewChangeSet {
        return MapViewChangeSet(
            properties: properties.fullChangeSet,
            baseStyleSheet: style.base.fullChangeSet,
            layout: layout.fullChangeSet
        )
    }
    
    let properties: [MapProperties.Property]
    let baseStyleSheet: [BaseStyleSheet.Property]
    let layout: [Layout.Property]
    
    var isEmpty: Bool {
        return  properties.isEmpty          &&
                baseStyleSheet.isEmpty      &&
                layout.isEmpty
    }
    
    init(
        properties: [MapProperties.Property] = [],
        baseStyleSheet: [BaseStyleSheet.Property] = [],
        layout: [Layout.Property] = []) {
        self.properties = properties
        self.baseStyleSheet = baseStyleSheet
        self.layout = layout
    }
    
}

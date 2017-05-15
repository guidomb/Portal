//
//  MapView.swift
//  Portal
//
//  Created by Guido Marucci Blas on 12/19/16.
//  Copyright © 2016 Guido Marucci Blas. All rights reserved.
//

import Foundation

public struct Coordinates {
    
    public var latitude: Double
    public var longitude: Double
    
    public init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
    
}

public struct MapPlacemark {
    
    public let coordinates: Coordinates
    public let icon: Image?
    
    public init(coordinates: Coordinates, icon: Image? = .none) {
        self.coordinates = coordinates
        self.icon = icon
    }
    
}

public struct MapProperties {
    
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

public func properties(configure: (inout MapProperties) -> ()) -> MapProperties {
    var properties = MapProperties()
    configure(&properties)
    return properties
}

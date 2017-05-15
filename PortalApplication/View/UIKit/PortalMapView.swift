//
//  MapView.swift
//  Portal
//
//  Created by Guido Marucci Blas on 12/18/16.
//  Copyright © 2016 Guido Marucci Blas. All rights reserved.
//

import UIKit
import MapKit

fileprivate let PortalMapViewAnnotationIdentifier = "PortalMapViewAnnotation"

internal final class PortalMapView: MKMapView {
    
    fileprivate var placemarks: [MapPlacemarkAnnotation : MapPlacemark] = [:]
    
    init(placemarks: [MapPlacemark]) {
        super.init(frame: CGRect.zero)
        for placemark in placemarks {
            let annotation = MapPlacemarkAnnotation(placemark: placemark)
            self.addAnnotation(annotation)
            self.placemarks[annotation] = placemark
        }
        self.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension PortalMapView: MKMapViewDelegate {
    
    public func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard
            let annotation = annotation as? MapPlacemarkAnnotation,
            let placemark = placemark(for: annotation)
        else { return .none }
        
        let annotationView = dequeueReusableAnnotationView(for: annotation)
        annotationView.image = placemark.icon?.asUIImage
        
        return annotationView
    }
    
}

extension PortalMapView {
    
    fileprivate func placemark(for annotation: MapPlacemarkAnnotation) -> MapPlacemark? {
        return placemarks[annotation]
    }
    
    fileprivate func dequeueReusableAnnotationView(for annotation: MapPlacemarkAnnotation) -> MKAnnotationView {
        if let annotationView = dequeueReusableAnnotationView(withIdentifier: PortalMapViewAnnotationIdentifier) {
            return annotationView
        } else {
            return MKAnnotationView(annotation: annotation, reuseIdentifier: PortalMapViewAnnotationIdentifier)
        }
    }
    
}

fileprivate final class MapPlacemarkAnnotation: NSObject, MKAnnotation {
    
    let coordinate: CLLocationCoordinate2D
    
    init(placemark: MapPlacemark) {
        self.coordinate = CLLocationCoordinate2D(
            latitude: placemark.coordinates.latitude,
            longitude: placemark.coordinates.longitude
        )
    }
    
}

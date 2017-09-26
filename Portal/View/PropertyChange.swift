//
//  PropertyChange.swift
//  Portal
//
//  Created by Argentino Ducret on 8/29/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//

enum PropertyChange<T> {
    
    case change(to: T)
    case noChange
    
}

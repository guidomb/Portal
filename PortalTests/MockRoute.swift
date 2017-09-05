//
//  MockRoute.swift
//  PortalTests
//
//  Created by Argentino Ducret on 9/5/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//

@testable import Portal

enum MockRoute: Route {
    
    var previous: MockRoute? {
        return .none
    }
    
    case test
    
}

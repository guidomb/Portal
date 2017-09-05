//
//  MockContainerController.swift
//  PortalTests
//
//  Created by Argentino Ducret on 9/5/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//

@testable import Portal

class MockContainerController: ContainerController {
    
    var containerView: UIView = UIView()
    
    func attachChildController(_ controller: UIViewController) {
        
    }
    
    func registerDisposer(for identifier: String, disposer: @escaping () -> Void) {
        
    }
    
}

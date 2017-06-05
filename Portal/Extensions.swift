//
//  Extensions.swift
//  Portal
//
//  Created by Guido Marucci Blas on 12/16/16.
//  Copyright © 2016 Guido Marucci Blas. All rights reserved.
//

import Foundation

precedencegroup ForwardApplication {
    /// Associates to the left so that pipeline behaves as expected.
    associativity: left
    higherThan: AssignmentPrecedence
}

infix operator |>: ForwardApplication

internal func |> <A>(lhs: A?, rhs: (A) -> Void) {
    lhs.apply(function: rhs)
}

extension Optional {
    
    internal func apply(function: (Wrapped) -> Void) {
        if let value = self {
            function(value)
        }
    }
    
}

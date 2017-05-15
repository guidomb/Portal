//
//  Middleware.swift
//  Portal
//
//  Created by Guido Marucci Blas on 3/21/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//

import Foundation

public protocol MiddlewareProtocol {
    
    associatedtype MessageType
    associatedtype StateType
    associatedtype CommandType
    
    typealias Transition = (StateType, CommandType?)?
    typealias NextMiddleware = (StateType, MessageType, CommandType?) -> Transition
    
    func call(state: StateType, message: MessageType, command: CommandType?, next: NextMiddleware) -> Transition
    
}

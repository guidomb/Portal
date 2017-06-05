//
//  TimeLogger.swift
//  Portal
//
//  Created by Guido Marucci Blas on 4/12/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//

import Foundation

public final class TimeLogger<StateType, MessageType, CommandType>: MiddlewareProtocol {
    
    public typealias Transition = (StateType, CommandType?)?
    public typealias NextMiddleware = (StateType, MessageType, CommandType?) -> Transition
    public typealias Logger = (String) -> Void
    
    public var log: Logger
    public var isEnabled: Bool = true
    
    public init(log: @escaping Logger = { print($0) }) {
        self.log = log
    }
    
    public func call(
        state: StateType,
        message: MessageType,
        command: CommandType?,
        next: NextMiddleware) -> Transition {
        
        let timestamp = Date.timeIntervalSinceReferenceDate
        let result = next(state, message, command)
        let dispatchTime = ((Date.timeIntervalSinceReferenceDate - timestamp) * 100000).rounded() / 100
        
        if isEnabled {
            log("Dispatch time \(dispatchTime)ms")
        }
        
        return result
    }
    
}

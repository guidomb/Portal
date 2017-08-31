//
//  View.swift
//  Portal
//
//  Created by Guido Marucci Blas on 12/9/16.
//  Copyright © 2016 Guido Marucci Blas. All rights reserved.
//

import Foundation

public struct Font: AutoEquatable {
    
    let name: String
    
    public init(name: String) {
        self.name = name
    }
    
}

public struct TabBar<MessageType> {
    
}

public protocol Renderer {
    
    associatedtype MessageType
    
    var isDebugModeEnabled: Bool { get set }
    
    func render(component: Component<MessageType>) -> Mailbox<MessageType>
        
}

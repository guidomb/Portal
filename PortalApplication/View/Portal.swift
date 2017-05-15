//
//  View.swift
//  Portal
//
//  Created by Guido Marucci Blas on 12/9/16.
//  Copyright © 2016 Guido Marucci Blas. All rights reserved.
//

import Foundation

public protocol Font {
    
    var name: String { get }
    
}

public struct TabBar<MessageType> {
    
}


public protocol Renderer {
    
    associatedtype MessageType
    
    var isDebugModeEnabled: Bool { get set }
    
    func render(component: Component<MessageType>) -> Mailbox<MessageType>
        
}

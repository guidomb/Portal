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

public struct RendererDebugConfiguration {
    
    public var showViewFrame: Bool
    public var showViewChangeAnimation: Bool
    public var viewChangeAnimationDuration: TimeInterval
    public var viewChangeAnimationColor: Color
    
    public init(
        showViewFrame: Bool = false,
        showViewChangeAnimation: Bool = true,
        viewChangeAnimationDuration: TimeInterval = 0.5,
        viewChangeAnimationColor: Color = .red) {
        self.showViewFrame = showViewFrame
        self.showViewChangeAnimation = showViewChangeAnimation
        self.viewChangeAnimationDuration = viewChangeAnimationDuration
        self.viewChangeAnimationColor = viewChangeAnimationColor
    }
    
}

public protocol Renderer {
    
    associatedtype MessageType
    
    var isDebugModeEnabled: Bool { get set }
    
    var debugConfiguration: RendererDebugConfiguration { get set }
    
    func render(component: Component<MessageType>, into containerView: UIView) -> Mailbox<MessageType>
    
    func apply(changeSet: ComponentChangeSet<MessageType>, to containerView: UIView)
        
}

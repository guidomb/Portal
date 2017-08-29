//
//  ImageViewRenderer.swift
//  PortalView
//
//  Created by Guido Marucci Blas on 2/14/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//

import UIKit

internal struct ImageViewRenderer<MessageType, RouteType: Route>: UIKitRenderer {
    
    typealias ActionType = Action<RouteType, MessageType>
    
    let image: Image
    let style: StyleSheet<EmptyStyleSheet>
    let layout: Layout
    
    func render(with layoutEngine: LayoutEngine, isDebugModeEnabled: Bool) -> Render<ActionType> {
        let imageView = UIImageView()

        let changeSet = ImageViewChangeSet.fullChangeSet(image: image, style: style, layout: layout)
        
        return imageView.apply(changeSet: changeSet, layoutEngine: layoutEngine)
    }
    
}

extension UIImageView: MessageForwarder {
    
    func apply<MessageType>(changeSet: ImageViewChangeSet, layoutEngine: LayoutEngine) -> Render<MessageType> {
        apply(image: changeSet.image)
        apply(changeSet: changeSet.baseStyleSheet)
        layoutEngine.apply(changeSet: changeSet.layout, to: self)
        
        return Render(view: self, mailbox: getMailbox(), executeAfterLayout: .none)
    }
    
}

fileprivate extension UIImageView {
    
    fileprivate func apply(image: PropertyChange<Image?>) {
        if case .change(let value) = image {
            self.image = value?.asUIImage
        }
    }
    
}

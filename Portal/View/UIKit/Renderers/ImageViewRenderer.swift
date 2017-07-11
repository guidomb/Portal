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
    let clipToBounds: Bool
    let style: StyleSheet<EmptyStyleSheet>
    let layout: Layout
    
    func render(with layoutEngine: LayoutEngine, isDebugModeEnabled: Bool) -> Render<ActionType> {
        let imageView = UIImageView(image: image.asUIImage)
        imageView.clipsToBounds = clipToBounds
        
        imageView.apply(style: style.base)
        layoutEngine.apply(layout: layout, to: imageView)
        
        return Render(view: imageView)
    }
    
}

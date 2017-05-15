//
//  ImageViewRenderer.swift
//  PortalView
//
//  Created by Guido Marucci Blas on 2/14/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//

import UIKit

internal struct ImageViewRenderer<MessageType>: UIKitRenderer {
    
    let image: Image
    let style: StyleSheet<EmptyStyleSheet>
    let layout: Layout
    
    func render(with layoutEngine: LayoutEngine, isDebugModeEnabled: Bool) -> Render<MessageType> {
        let imageView = UIImageView(image: image.asUIImage)
        imageView.clipsToBounds = true
        
        imageView.apply(style: style.base)
        layoutEngine.apply(layout: layout, to: imageView)
        
        return Render(view: imageView)
    }
    
}

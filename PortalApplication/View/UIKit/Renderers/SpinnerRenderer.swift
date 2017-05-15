//
//  SpinnerRenderer.swift
//  PortalView
//
//  Created by Cristian Ames on 4/21/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//

import UIKit

internal struct SpinnerRenderer<MessageType>: UIKitRenderer {
    
    let isActive: Bool
    let style: StyleSheet<SpinnerStyleSheet>
    let layout: Layout
    
    func render(with layoutEngine: LayoutEngine, isDebugModeEnabled: Bool) -> Render<MessageType> {
        let spinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        
        spinner.hidesWhenStopped = false
        if isActive {
            spinner.startAnimating()
        }
        
        spinner.apply(style: style.base)
        spinner.apply(style: style.component)
        layoutEngine.apply(layout: layout, to: spinner)
        
        return Render(view: spinner)
    }
    
}

extension UIActivityIndicatorView {
    
    fileprivate func apply(style: SpinnerStyleSheet) {
        self.color = style.color.asUIColor
    }
    
}

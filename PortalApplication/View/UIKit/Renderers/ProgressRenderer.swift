//
//  ProgressRenderer.swift
//  PortalView
//
//  Created by Cristian Ames on 4/11/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//

import UIKit

public let defaultTrackColor = Color.gray
public let defaultProgressColor = Color.blue

internal struct ProgressRenderer<MessageType>: UIKitRenderer {
    
    let progress: ProgressCounter
    let style: StyleSheet<ProgressStyleSheet>
    let layout: Layout
    
    func render(with layoutEngine: LayoutEngine, isDebugModeEnabled: Bool) -> Render<MessageType> {
        let progressBar = UIProgressView(progressViewStyle: .default)
        progressBar.progress = progress.progress
        
        progressBar.apply(style: style.base)
        progressBar.apply(style: style.component)
        layoutEngine.apply(layout: layout, to: progressBar)
        
        return Render(view: progressBar)
    }
    
}

extension UIProgressView {
    
    fileprivate func apply(style: ProgressStyleSheet) {
        switch style.progressStyle {
            
        case .color(let color):
            progressTintColor = color.asUIColor
            
        case .image(let image):
            progressImage = image.asUIImage
        }
        
        switch style.trackStyle {
            
        case .color(let color):
            trackTintColor = color.asUIColor
            
        case .image(let image):
            trackImage = image.asUIImage
        }
    }
    
}

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

extension UIProgressView {
    
    func apply<MessageType>(changeSet: ProgressChangeSet, layoutEngine: LayoutEngine) -> Render<MessageType> {
        apply(changeSet: changeSet.progress)
        apply(changeSet: changeSet.baseStyleSheet)
        apply(changeSet: changeSet.progressStyleSheet)
        layoutEngine.apply(changeSet: changeSet.layout, to: self)
        
        return Render(view: self, mailbox: getMailbox(), executeAfterLayout: .none)
    }
    
}

fileprivate extension UIProgressView {

    fileprivate func apply(changeSet: PropertyChange<ProgressCounter>) {
        guard case .change(let progressCounter) = changeSet else { return }
        
        self.progress = progressCounter.progress
    }
    
    fileprivate func apply(changeSet: [ProgressStyleSheet.Property]) {
        for property in changeSet {
            switch property {
                
            case .progressStyle(let progressStyle):
                switch progressStyle {
                    
                case .color(let color):
                    progressTintColor = color.asUIColor
                    
                case .image(let image):
                    progressImage = image.asUIImage
                }

            case .trackStyle(let trackStyle):
                switch trackStyle {
                    
                case .color(let color):
                    trackTintColor = color.asUIColor
                    
                case .image(let image):
                    trackImage = image.asUIImage
                }

            }
        }
    }
    
}

//
//  SpinnerRenderer.swift
//  PortalView
//
//  Created by Cristian Ames on 4/21/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//

import UIKit

internal struct SpinnerRenderer<MessageType, RouteType: Route>: UIKitRenderer {
    
    typealias ActionType = Action<RouteType, MessageType>
    
    let isActive: Bool
    let style: StyleSheet<SpinnerStyleSheet>
    let layout: Layout
    
    func render(with layoutEngine: LayoutEngine, isDebugModeEnabled: Bool) -> Render<ActionType> {
        let spinner = UIActivityIndicatorView()
        spinner.hidesWhenStopped = false
        
        let changeSet = SpinnerChangeSet.fullChangeSet(isActive: isActive, style: style, layout: layout)
        
        return spinner.apply(changeSet: changeSet, layoutEngine: layoutEngine)
    }
    
}

extension UIActivityIndicatorView: MessageForwarder {

    func apply<MessageType>(changeSet: SpinnerChangeSet, layoutEngine: LayoutEngine) -> Render<MessageType> {
        apply(isActive: changeSet.isActive)
        apply(changeSet: changeSet.baseStyleSheet)
        apply(changeSet: changeSet.spinnerStyleSheet)
        layoutEngine.apply(changeSet: changeSet.layout, to: self)
        
        return Render<MessageType>(view: self, mailbox: getMailbox(), executeAfterLayout: .none)
    }
    
}

fileprivate extension UIActivityIndicatorView {
    
    fileprivate func apply(isActive: PropertyChange<Bool>) {
        guard case .change(let isActive) = isActive else { return }
        
        if isActive {
            startAnimating()
        } else {
            stopAnimating()
        }
    }
    
    fileprivate func apply(changeSet: [SpinnerStyleSheet.Property]) {
        for property in changeSet {
            switch property {
                
            case .color(let color):
                self.color = color.asUIColor
            }
        }
    }
    
}

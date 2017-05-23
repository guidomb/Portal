//
//  LabelRenderer.swift
//  PortalView
//
//  Created by Guido Marucci Blas on 2/14/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//

import UIKit

internal struct LabelRenderer<MessageType, RouteType: Route>: UIKitRenderer {
    
    typealias ActionType = Action<RouteType, MessageType>
    
    let properties: LabelProperties
    let style: StyleSheet<LabelStyleSheet>
    let layout: Layout
    
    func render(with layoutEngine: LayoutEngine, isDebugModeEnabled: Bool) -> Render<ActionType> {
        let label = UILabel()
        label.text = properties.text
        
        label.apply(style: style.base)
        label.apply(style: style.component)
        layoutEngine.apply(layout: layout, to: label)
        
        return Render(view: label) {
            if let textAfterLayout = self.properties.textAfterLayout, let size = label.maximumFontSizeForWidth() {
                label.text = textAfterLayout
                label.font = label.font.withSize(size)
                label.adjustsFontSizeToFitWidth = false
                label.minimumScaleFactor = 0.0
            }
        }
    }
    
}

extension UILabel {
    
    fileprivate func apply(style: LabelStyleSheet) {
        let size = CGFloat(style.textSize)
        style.textFont.uiFont(withSize: size)     |> { self.font = $0 }
        style.textColor                           |> { self.textColor = $0.asUIColor }
        self.textAlignment = style.textAligment.asNSTextAligment
        self.adjustsFontSizeToFitWidth = style.adjustToFitWidth
        self.numberOfLines = Int(style.numberOfLines)
        self.minimumScaleFactor = CGFloat(style.minimumScaleFactor)
    }
    
}

extension UILabel {
    
    fileprivate func maximumFontSizeForWidth() -> CGFloat? {
        guard let text = self.text else { return .none }
        return text.maximumFontSize(forWidth: self.frame.width, font: self.font)
    }
    
}

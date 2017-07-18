//
//  TextViewRenderer.swift
//  Portal
//
//  Created by Cristian Ames on 7/18/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//

import UIKit

internal struct TextViewRenderer<MessageType, RouteType: Route>: UIKitRenderer {
    
    typealias ActionType = Action<RouteType, MessageType>
    
    let textType: TextType
    let style: StyleSheet<TextViewStyleSheet>
    let layout: Layout
    
    func render(with layoutEngine: LayoutEngine, isDebugModeEnabled: Bool) -> Render<ActionType> {
        let textView = UITextView()
        
        textView.apply(style: style.component)
        textView.isEditable = false
        textView.isUserInteractionEnabled = true
        textView.isScrollEnabled = false
        
        switch textType {
            
        case .regular(let text):
            textView.text = text
            
        case .attributed(let attributedText):
            textView.attributedText = attributedText
            
        }
        
        textView.apply(style: style.base)
        layoutEngine.apply(layout: layout, to: textView)
        
        return Render(view: textView)
    }
    
}

extension UITextView {
    
    fileprivate func apply(style: TextViewStyleSheet) {
        let size = CGFloat(style.textSize)
        style.textFont.uiFont(withSize: size)     |> { self.font = $0 }
        style.textColor                           |> { self.textColor = $0.asUIColor }
        style.textAligment                        |> { self.textAlignment = $0.asNSTextAligment }
    }
    
}

//
//  TextViewRenderer.swift
//  Portal
//
//  Created by Cristian Ames on 7/18/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//

import UIKit

public let defaultTextViewFontSize = UInt(UIFont.systemFontSize)

internal struct TextViewRenderer<MessageType, RouteType: Route>: UIKitRenderer {
    
    typealias ActionType = Action<RouteType, MessageType>
    
    let textType: TextType
    let style: StyleSheet<TextViewStyleSheet>
    let layout: Layout
    
    func render(with layoutEngine: LayoutEngine, isDebugModeEnabled: Bool) -> Render<ActionType> {
        let textView = UITextView()
        let changeSet = TextViewChangeSet.fullChangeSet(textType: textType, style: style, layout: layout)
        
        return textView.apply(changeSet: changeSet, layoutEngine: layoutEngine)
    }
    
}

extension UITextView: MessageForwarder {
    
    func apply<MessageType>(changeSet: TextViewChangeSet, layoutEngine: LayoutEngine) -> Render<MessageType> {
        apply(changeSet: changeSet.baseStyle)
        apply(changeSet: changeSet.textViewStyle)
        apply(textType: changeSet.textType)
        layoutEngine.apply(changeSet: changeSet.layout, to: self)
        
        return Render(view: self, mailbox: .none, executeAfterLayout: .none)
    }
    
}

fileprivate extension UITextView {
    
    fileprivate func apply(changeSet: [TextViewStyleSheet.Property]) {
        for property in changeSet {
            switch property {
                
            case .textColor(let color):
                self.textColor = color.asUIColor
                
            case .textAligment(let aligment):
                self.textAlignment = aligment.asNSTextAligment
                
            case .textSize(let textSize):
                let fontName = self.font?.fontName
                fontName |> { self.font = UIFont(name: $0, size: CGFloat(textSize)) }
                
            case .textFont(let font):
                let fontSize = self.font?.pointSize ?? CGFloat(defaultTextViewFontSize)
                self.font = font.uiFont(withSize: fontSize)
            }
        }
    }
    
    fileprivate func apply(textType: TextType) {
        switch textType {
        
        case .regular(let text):
            self.text = text
        
        case .attributed(let attributedText):
            self.attributedText = attributedText
        }
    }
    
}

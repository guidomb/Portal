//
//  TextViewRenderer.swift
//  Portal
//
//  Created by Cristian Ames on 7/18/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//

import UIKit

public let defaultTextViewFontSize = UInt(UIFont.systemFontSize)

extension UITextView {
    
    func apply<MessageType>(changeSet: TextViewChangeSet, layoutEngine: LayoutEngine) -> Render<MessageType> {
        apply(changeSet: changeSet.baseStyleSheet)
        apply(changeSet: changeSet.textViewStyleSheet)
        apply(changeSet: changeSet.properties)
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
    
    fileprivate func apply(changeSet: [TextViewProperties.Property]) {
        for property in changeSet {
            switch property {
                
            case .text(let value):
                switch value {
                    
                case .regular(let text):
                    self.text = text
                    
                case .attributed(let attributedText):
                    self.attributedText = attributedText
                }
                
            case .isScrollEnabled(let isScrollEnabled):
                self.isScrollEnabled = isScrollEnabled
                
            case .isEditable(let isEditable):
                self.isEditable = isEditable
                
            }
        }
    }
    
}

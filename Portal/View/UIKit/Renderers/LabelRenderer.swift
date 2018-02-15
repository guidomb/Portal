//
//  LabelRenderer.swift
//  PortalView
//
//  Created by Guido Marucci Blas on 2/14/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//

import UIKit

public let defaultLabelFontSize = UInt(UIFont.labelFontSize)

extension UILabel {
    
    internal func apply<MessageType>(
        changeSet: LabelChangeSet,
        layoutEngine: LayoutEngine) -> Render<MessageType> {
        
        apply(changeSet: changeSet.properties)
        apply(changeSet: changeSet.baseStyleSheet)
        apply(changeSet: changeSet.labelStyleSheet)
        layoutEngine.apply(changeSet: changeSet.layout, to: self)
        
        return Render(view: self, mailbox: .none) {
            for property in changeSet.properties {
                guard case .textAfterLayout(.some(let textAfterLayout)) = property else { continue }
                guard let size = self.maximumFontSizeForWidth() else { continue }
                
                self.text = textAfterLayout
                self.font = self.font.withSize(size)
                self.adjustsFontSizeToFitWidth = false
                self.minimumScaleFactor = 0.0
            }
        }
        
    }
    
}

fileprivate extension UILabel {
    
    fileprivate func apply(changeSet: [LabelProperties.Property]) {
        for property in changeSet {
            switch property {
                
            case .text(let text):
                self.text = text
                
            case .textAfterLayout:
                continue
            }
        }
    }
    
    fileprivate func apply(changeSet: [LabelStyleSheet.Property]) {
        for property in changeSet {
            switch property {
                
            case .textAlignment(let alignment):
                self.textAlignment = alignment.asNSTextAlignment
                
            case .textColor(let color):
                self.textColor = color.asUIColor
                
            case .textFont(let font):
                let fontSize = self.font?.pointSize ?? CGFloat(defaultLabelFontSize)
                self.font = font.uiFont(withSize: fontSize)
                
            case .textSize(let textSize):
                let fontName = self.font?.fontName
                fontName |> { self.font = UIFont(name: $0, size: CGFloat(textSize)) }
            
            case .adjustToFitWidth(let adjustToFitWidth):
                self.adjustsFontSizeToFitWidth = adjustToFitWidth
                
            case .numberOfLines(let numberOfLines):
                self.numberOfLines = Int(numberOfLines)
                
            case .minimumScaleFactor(let minimumScaleFactor):
                self.minimumScaleFactor = CGFloat(minimumScaleFactor)
            }
        }
    }
    
}

fileprivate extension UILabel {
    
    fileprivate func maximumFontSizeForWidth() -> CGFloat? {
        guard let text = self.text else { return .none }
        return text.maximumFontSize(forWidth: self.frame.width, font: self.font)
    }
    
}

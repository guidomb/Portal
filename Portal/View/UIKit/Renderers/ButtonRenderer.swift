//
//  ButtonRenderer.swift
//  PortalView
//
//  Created by Guido Marucci Blas on 2/14/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//

import UIKit

public let defaultButtonFontSize = UInt(UIFont.buttonFontSize)

extension UIButton: MessageProducer {
    
    internal func apply<MessageType>(
        changeSet: ButtonChangeSet<MessageType>,
        layoutEngine: LayoutEngine) -> Render<MessageType> {
        
        apply(changeSet: changeSet.properties)
        apply(changeSet: changeSet.baseStyleSheet)
        apply(changeSet: changeSet.buttonStyleSheet)
        layoutEngine.apply(changeSet: changeSet.layout, to: self)
        
        return Render(view: self, mailbox: getMailbox(), executeAfterLayout: .none)
    }
    
}

fileprivate extension UIButton {
    
    fileprivate func apply<MessageType>(changeSet: [ButtonProperties<MessageType>.Property]) {
        for property in changeSet {
            switch property {
                
            case .text(let text):
                self.setTitle(text, for: .normal)
                
            case .icon(let icon):
                let image = icon.map { $0.asUIImage }
                self.setImage(image, for: .normal)
                
            case .isActive(let isActive):
                self.isSelected = isActive
                
            case .onTap(let onTap):
                if let message = onTap {
                    _ = self.on(event: .touchUpInside, dispatch: message)
                } else {
                    _ = self.unregisterDispatcher(for: .touchUpInside) as MessageDispatcher<MessageType>?
                }
            }
        }
    }
    
    fileprivate func apply(changeSet: [ButtonStyleSheet.Property]) {
        for property in changeSet {
            switch property {
                
            case .textColor(let textColor):
                self.setTitleColor(textColor.asUIColor, for: .normal)
                
            case .textSize(let textSize):
                let fontName = self.titleLabel?.font.fontName
                fontName |> { self.titleLabel?.font = UIFont(name: $0, size: CGFloat(textSize)) }
                
            case .textFont(let font):
                let fontSize = self.titleLabel?.font.pointSize ?? CGFloat(defaultButtonFontSize)
                self.titleLabel?.font = font.uiFont(withSize: fontSize)
            }
        }
    }
    
}

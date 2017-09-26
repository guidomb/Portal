//
//  ToggleRenderer.swift
//  Portal
//
//  Created by Juan Franco Caracciolo on 8/16/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//
import UIKit

extension UISwitch: MessageProducer {
    
    internal func apply<MessageType>(
        changeSet: ToggleChangeSet<MessageType>,
        layoutEngine: LayoutEngine) -> Render<MessageType> {
    
        apply(changeSet: changeSet.properties)
        apply(changeSet: changeSet.baseStyleSheet)
        apply(changeSet: changeSet.toggleStyleSheet)
        layoutEngine.apply(changeSet: changeSet.layout, to: self)
        
        return Render(view: self, mailbox: getMailbox())
    }
}

fileprivate extension UISwitch {
    
    fileprivate func apply<MessageType>(changeSet: [ToggleProperties<MessageType>.Property]) {
        for property in changeSet {
            switch property {
            
            case .isActive(let isActive):
                self.isSelected = isActive
                
            case .isEnabled(let isEnabled):
                self.isEnabled = isEnabled
                
            case .isOn(let isOn):
                self.setOn(isOn, animated: false)
                
            case .onSwitch(let onSwitch):
                let _: Mailbox<MessageType> = self.on(event: .touchUpInside) { sender in
                    guard let toggle = sender as? UISwitch else { return .none }
                    return onSwitch(toggle.isOn)
                }
                
            }
        }
    }
    
    fileprivate func apply(changeSet: [ToggleStyleSheet.Property]) {
        for property in changeSet {
            switch property {
                
            case .onTintColor(let tintColor):
                self.onTintColor = tintColor?.asUIColor
                
            case .thumbTintColor(let thumbTintColor):
                self.thumbTintColor = thumbTintColor?.asUIColor
                
            case .tintChangingColor(let tintChangingColor):
                self.tintColor = tintChangingColor?.asUIColor
            }
        }
    }
    
}

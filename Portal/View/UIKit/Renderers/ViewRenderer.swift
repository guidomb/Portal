//
//  ViewRenderer.swift
//  Portal
//
//  Created by Guido Marucci Blas on 9/16/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//

import UIKit

extension UIView {
    
    internal func apply(changeSet: [BaseStyleSheet.Property]) {
        for property in changeSet {
            switch property {
                
            case .alpha(let alpha):
                alpha |> { self.alpha = CGFloat($0) }
                
            case .backgroundColor(let backgroundColor):
                backgroundColor |> { self.backgroundColor = $0.asUIColor }
                
            case .cornerRadius(let cornerRadius):
                cornerRadius |> { self.layer.cornerRadius = CGFloat($0) }
                
            case .borderColor(let borderColor):
                borderColor |> { self.layer.borderColor = $0.asUIColor.cgColor }
                
            case .borderWidth(let borderWidth):
                borderWidth |> { self.layer.borderWidth = CGFloat($0) }
                
            case .contentMode(let contentMode):
                contentMode |> { self.contentMode = $0.toUIViewContentMode }
                
            case .clipToBounds(let clipToBounds):
                clipToBounds |> { self.clipsToBounds = $0 }
                
            case .shadow(let shadowChangeSet):
                self.layer.apply(changeSet: shadowChangeSet)
            }
        }
    }
    
    internal func apply(style: BaseStyleSheet) {
        style.backgroundColor   |> { self.backgroundColor = $0.asUIColor }
        style.cornerRadius      |> { self.layer.cornerRadius = CGFloat($0) }
        style.borderColor       |> { self.layer.borderColor = $0.asUIColor.cgColor }
        style.borderWidth       |> { self.layer.borderWidth = CGFloat($0) }
        style.alpha             |> { self.alpha = CGFloat($0) }
        style.contentMode       |> { self.contentMode = $0.toUIViewContentMode }
        style.clipToBounds      |> { self.clipsToBounds = $0 }
        style.shadow            |> { shadow in
            self.layer.shadowColor = shadow.color.asUIColor.cgColor
            self.layer.shadowOpacity = shadow.opacity
            self.layer.shadowOffset = shadow.offset.asCGSize
            self.layer.shadowRadius = CGFloat(shadow.radius)
            self.layer.shouldRasterize = shadow.shouldRasterize
        }
        
    }
    
}

private let defaultLayer = CALayer()

fileprivate extension CALayer {
    
    fileprivate func apply(changeSet: [Shadow.Property]?) {
        if let changeSet = changeSet {
            for property in changeSet {
                switch property {
                    
                case .color(let shadowColor):
                    self.shadowColor = shadowColor.asUIColor.cgColor
                    
                case .opacity(let shadowOpacity):
                    self.shadowOpacity = shadowOpacity
                    
                case .offset(let shadowOffset):
                    self.shadowOffset = shadowOffset.asCGSize
                    
                case .radius(let shadowRadius):
                    self.shadowRadius = CGFloat(shadowRadius)
                    
                case .shouldRasterize(let shouldRasterize):
                    self.shouldRasterize = shouldRasterize
                    
                }
            }
        } else {
            self.shadowColor = defaultLayer.shadowColor
            self.shadowOpacity = defaultLayer.shadowOpacity
            self.shadowOffset = defaultLayer.shadowOffset
            self.shadowRadius = defaultLayer.shadowRadius
            self.shouldRasterize = defaultLayer.shouldRasterize
        }
    }
    
}

fileprivate extension ContentMode {
    
    var toUIViewContentMode: UIViewContentMode {
        switch self {
            
        case .scaleToFill:
            return UIViewContentMode.scaleToFill
            
        case .scaleAspectFill:
            return UIViewContentMode.scaleAspectFill
            
        case .scaleAspectFit:
            return UIViewContentMode.scaleAspectFit
            
        }
    }
    
}

extension SupportedOrientations {
    
    var uiInterfaceOrientation: UIInterfaceOrientationMask {
        switch self {
        case .all:
            return .all
        case .landscape:
            return .landscape
        case .portrait:
            return .portrait
        }
    }
    
}

extension Offset {
    
    internal var asCGSize: CGSize {
        return CGSize(width: CGFloat(x), height: CGFloat(y))
    }
    
}

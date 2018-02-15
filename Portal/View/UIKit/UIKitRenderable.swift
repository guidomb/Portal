//
//  UIKit.swift
//  Portal
//
//  Created by Guido Marucci Blas on 12/13/16.
//  Copyright © 2016 Guido Marucci Blas. All rights reserved.
//

import UIKit

extension StatusBarStyle {
    
    internal var asUIStatusBarStyle: UIStatusBarStyle {
        switch self {
        case .`default`:
            return .`default`
        case .lightContent:
            return .`lightContent`
        }
    }
    
}

internal protocol UIColorConvertible {
    
    var asUIColor: UIColor { get }
    
}

extension Color: UIColorConvertible {
    
    var asUIColor: UIColor {
        return UIColor(red: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha: CGFloat(alpha))
    }
    
}

extension TextAlignment {
    
    var asNSTextAlignment: NSTextAlignment {
        switch self {
        case .left:
            return .left
        case .center:
            return .center
        case .right:
            return .right
        case .justified:
            return .justified
        case .natural:
            return .natural
        }
    }
    
}

extension String {
    
    func maximumFontSize(forWidth width: CGFloat, font: UIFont) -> CGFloat {
        let text = self as NSString
        let minimumBoundingRect = text.size(withAttributes: [.font: font])
        return width * font.pointSize / minimumBoundingRect.width
    }
    
}

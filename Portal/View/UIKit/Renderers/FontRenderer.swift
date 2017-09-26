//
//  FontRenderer.swift
//  PortalView
//
//  Created by Guido Marucci Blas on 2/14/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//

import UIKit

public let defaultFont: Font = {
    let font = UIFont.systemFont(ofSize: UIFont.buttonFontSize)
    return Font(name: font.fontName)
}()

public extension Font {
    
    public func register(using bundle: Bundle = Bundle.main) -> Bool {
        guard let fontURL = bundle.url(forResource: self.name, withExtension: "ttf") else { return false }
        var error: Unmanaged<CFError>?
        return CTFontManagerRegisterFontsForURL(fontURL as CFURL, .process, &error)
    }
    
}

extension Font {
    
    internal func uiFont(withSize size: CGFloat) -> UIFont? {
        return UIFont(name: self.name, size: size)
    }
    
    internal func uiFont(withSize size: UInt) -> UIFont? {
        return uiFont(withSize: CGFloat(size))
    }
    
}

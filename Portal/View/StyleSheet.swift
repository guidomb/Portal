//
//  StyleSheet.swift
//  Portal
//
//  Created by Guido Marucci Blas on 12/13/16.
//  Copyright © 2016 Guido Marucci Blas. All rights reserved.
//

import Foundation

public struct Color {
    
    public static var red: Color {
        return Color(hex: 0xFF0000)!
    }
    
    public static var green: Color {
        return Color(hex: 0x00FF00)!
    }
    
    public static var blue: Color {
        return Color(hex: 0x0000FF)!
    }
    
    public static var yellow: Color {
        return Color(hex: 0xFFFF00)!
    }
    
    public static var black: Color {
        return Color(hex: 0x000000)!
    }
    
    public static var white: Color {
        return Color(hex: 0xFFFFFF)!
    }
    
    public static var gray: Color {
        return Color(hex: 0x808080)!
    }
    
    public static var clear: Color {
        return Color(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)!
    }
    
    public let red: Float
    public let green: Float
    public let blue: Float
    public let alpha: Float
    
    public init?(red: Float, green: Float, blue: Float, alpha: Float = 1.0) {
        guard alpha >= 0.0 && alpha <= 1.0 else { return nil }
        
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }
    
    public init?(red: Int, green: Int, blue: Int) {
        guard   red >= 0 && red <= 255,
                green >= 0 && green <= 255,
                blue >= 0 && blue <= 255
        else { return nil }
        
        self.init(red: Float(red) / 255.0, green: Float(green) / 255.0, blue: Float(blue) / 255.0, alpha: 1.0)
    }
    
    public init?(hex: Int) {
        self.init(red:(hex >> 16) & 0xff, green:(hex >> 8) & 0xff, blue:hex & 0xff)
    }
    
}

public struct StyleSheet<ComponentStyleSheet> {
    
    public var base: BaseStyleSheet
    public var component: ComponentStyleSheet
    
    internal init(component: ComponentStyleSheet, base: BaseStyleSheet = BaseStyleSheet()) {
        self.component = component
        self.base = base
    }
    
}

public enum ContentMode {
    
    case scaleToFill
    case scaleAspectFit
    case scaleAspectFill
    
}

public struct BaseStyleSheet {
    
    public var backgroundColor: Color
    public var cornerRadius: Float?
    public var borderColor: Color
    public var borderWidth: Float
    public var alpha: Float
    public var contentMode: ContentMode?
    
    public init(
        backgroundColor: Color = .clear,
        cornerRadius: Float? = .none,
        borderColor: Color = .clear,
        borderWidth: Float = 0.0,
        alpha: Float = 1.0,
        contentMode: ContentMode? = .none
    ) {
        self.backgroundColor = backgroundColor
        self.cornerRadius = cornerRadius
        self.borderColor = borderColor
        self.borderWidth = borderWidth
        self.alpha = alpha
        self.contentMode = contentMode
    }
    
}

public enum TextAligment {
    
    case left
    case center
    case right
    case justified
    case natural
    
}

public struct EmptyStyleSheet {
    
    static public let `default` = StyleSheet<EmptyStyleSheet>(component: EmptyStyleSheet())
    
}

public enum StatusBarStyle {
    
    case `default`
    case lightContent
    
}

public func styleSheet(configure: (inout BaseStyleSheet) -> Void = { _ in }) -> StyleSheet<EmptyStyleSheet> {
    var base = BaseStyleSheet()
    configure(&base)
    return StyleSheet(component: EmptyStyleSheet(), base: base)
}

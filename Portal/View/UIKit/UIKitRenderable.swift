//
//  UIKit.swift
//  Portal
//
//  Created by Guido Marucci Blas on 12/13/16.
//  Copyright © 2016 Guido Marucci Blas. All rights reserved.
//

import UIKit

internal protocol UIImageConvertible {
    
    var asUIImage: UIImage { get }
    
}

public typealias Image = UIImageContainer

public struct UIImageContainer: ImageType, UIImageConvertible {
    
    public static func loadImage(named imageName: String, from bundle: Bundle = .main) -> UIImageContainer? {
        return UIImage(named: imageName, in: bundle, compatibleWith: .none).map(UIImageContainer.init)
    }
    
    public var size: Size {
        return Size(width: UInt(image.size.width), height: UInt(image.size.height))
    }
    
    public func applyMask(_ mask: UIImageContainer) -> UIImageContainer? {
        guard let maskRef = mask.asUIImage.cgImage,
            let provider = mask.asUIImage.cgImage?.dataProvider,
            let cgImage = image.cgImage else { return .none }
        
        let mask = CGImage(
            maskWidth: maskRef.width,
            height: maskRef.height,
            bitsPerComponent: maskRef.bitsPerComponent,
            bitsPerPixel: maskRef.bitsPerPixel,
            bytesPerRow: maskRef.bytesPerRow,
            provider: provider,
            decode: nil,
            shouldInterpolate: false
        )
        let maskedImage = mask
            .flatMap(cgImage.masking)
            .map(UIImage.init)
            .map(UIImageContainer.init)
        
        return maskedImage
    }
    
    var asUIImage: UIImage {
        return image
    }
    
    fileprivate let image: UIImage
    
    public init(image: UIImage) {
        self.image = image
    }
    
}

extension UIImageContainer: Equatable {
    
    public static func ==(lhs: UIImageContainer, rhs: UIImageContainer) -> Bool {
        return lhs.image == rhs.image
    }
    
}

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

extension TextAligment {
    
    var asNSTextAligment: NSTextAlignment {
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
        let minimumBoundingRect = text.size(attributes: [NSFontAttributeName: font])
        return width * font.pointSize / minimumBoundingRect.width
    }
    
}

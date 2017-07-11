//
//  Image.swift
//  PortalView
//
//  Created by Guido Marucci Blas on 1/27/17.
//
//

import Foundation

public struct Size {
    
    public var width: UInt
    public var height: UInt
    
}

public protocol ImageType {
    
    var size: Size { get }
    
}

public func imageView<MessageType>(
    image: Image,
    clipToBounds: Bool = false,
    style: StyleSheet<EmptyStyleSheet> = EmptyStyleSheet.`default`,
    layout: Layout = layout()) -> Component<MessageType> {
    return .imageView(image, clipToBounds, style, layout)
}

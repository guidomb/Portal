//
//  Image.swift
//  PortalView
//
//  Created by Guido Marucci Blas on 1/27/17.
//
//

import Foundation

public enum Image {
    
    case localImage(named: String)
    case blob(data: Data)
    
}

extension Image: AutoEquatable {}

public func imageView<MessageType>(
    image: Image,
    style: StyleSheet<EmptyStyleSheet> = EmptyStyleSheet.`default`,
    layout: Layout = layout()) -> Component<MessageType> {
    return .imageView(image, style, layout)
}

// MARK: - ChangeSet

public struct ImageViewChangeSet {
    
    static func fullChangeSet(
        image: Image,
        style: StyleSheet<EmptyStyleSheet>,
        layout: Layout) -> ImageViewChangeSet {
        return ImageViewChangeSet(
            image: .change(to: image),
            baseStyleSheet: style.base.fullChangeSet,
            layout: layout.fullChangeSet
        )
    }
    
    let image: PropertyChange<Image?>
    let baseStyleSheet: [BaseStyleSheet.Property]
    let layout: [Layout.Property]
    
    var isEmpty: Bool {
        guard case .noChange = image else { return false }
        return  baseStyleSheet.isEmpty      &&
                layout.isEmpty
    }
    
    init(
        image: PropertyChange<Image?> = .noChange,
        baseStyleSheet: [BaseStyleSheet.Property] = [],
        layout: [Layout.Property] = []) {
        self.image = image
        self.baseStyleSheet = baseStyleSheet
        self.layout = layout
    }
    
}

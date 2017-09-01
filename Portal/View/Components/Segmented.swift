//
//  Segmented.swift
//  PortalView
//
//  Created by Cristian Ames on 4/4/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//

import UIKit

public enum SegmentContentType {
    
    case title(String)
    case image(Image)
    
}

public struct SegmentProperties<MessageType> {
    
    public let content: SegmentContentType
    public let onTap: MessageType?
    public let isEnabled: Bool
    
    fileprivate init(
        content: SegmentContentType,
        onTap: MessageType? = .none,
        isEnabled: Bool = true) {
        self.content = content
        self.onTap = onTap
        self.isEnabled = isEnabled
    }
    
}

extension SegmentProperties {
    
    public func map<NewMessageType>(_ transform: (MessageType) -> NewMessageType) -> SegmentProperties<NewMessageType> {
        return SegmentProperties<NewMessageType>(content: content, onTap: onTap.map(transform), isEnabled: isEnabled)
    }
    
}

public func segmented<MessageType>(
    segments: ZipList<SegmentProperties<MessageType>>,
    style: StyleSheet<SegmentedStyleSheet> = SegmentedStyleSheet.default,
    layout: Layout = layout()) -> Component<MessageType> {
    return .segmented(segments, style, layout)
}

public func segment<MessageType>(
    title: String,
    onTap: MessageType? = .none,
    isEnabled: Bool = true) -> SegmentProperties<MessageType> {
    return SegmentProperties(content: .title(title), onTap: onTap, isEnabled: isEnabled)
}

public func segment<MessageType>(
    image: Image,
    onTap: MessageType? = .none,
    isEnabled: Bool = true) -> SegmentProperties<MessageType> {
    return SegmentProperties(content: .image(image), onTap: onTap, isEnabled: isEnabled)
}

// MARK: - Style sheet

public struct SegmentedStyleSheet: AutoPropertyDiffable {
    
    public static let `default` = StyleSheet<SegmentedStyleSheet>(component: SegmentedStyleSheet())
    
    public var textFont: Font
    public var textSize: UInt
    public var textColor: Color
    public var borderColor: Color
    
    public init(
        textFont: Font = defaultFont,
        textSize: UInt = defaultButtonFontSize,
        textColor: Color = .blue,
        borderColor: Color = .blue) {
        self.textFont = textFont
        self.textSize = textSize
        self.textColor = textColor
        self.borderColor = borderColor
    }
    
}

public func segmentedStyleSheet(
    configure: (inout BaseStyleSheet, inout SegmentedStyleSheet) -> Void) -> StyleSheet<SegmentedStyleSheet> {
    var base = BaseStyleSheet()
    var custom = SegmentedStyleSheet()
    configure(&base, &custom)
    return StyleSheet(component: custom, base: base)
}

// MARK: - ChangeSet

internal struct SegmentedChangeSet<MessageType> {
    
    static func fullChangeSet(
        segments: ZipList<SegmentProperties<MessageType>>,
        style: StyleSheet<SegmentedStyleSheet>,
        layout: Layout) -> SegmentedChangeSet<MessageType> {
        return SegmentedChangeSet(
            segments: .change(to: segments),
            baseStyle: style.base.fullChangeSet,
            segmentedStyle: style.component.fullChangeSet,
            layout: layout.fullChangeSet
        )
    }
    
    let segments: PropertyChange<ZipList<SegmentProperties<MessageType>>>
    let baseStyle: [BaseStyleSheet.Property]
    let segmentedStyle: [SegmentedStyleSheet.Property]
    let layout: [Layout.Property]
    
    init(
        segments: PropertyChange<ZipList<SegmentProperties<MessageType>>> = .noChange,
        baseStyle: [BaseStyleSheet.Property] = [],
        segmentedStyle: [SegmentedStyleSheet.Property] = [],
        layout: [Layout.Property] = []) {
        self.segments = segments
        self.baseStyle = baseStyle
        self.segmentedStyle = segmentedStyle
        self.layout = layout
    }
    
}
